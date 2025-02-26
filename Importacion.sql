USE Com1353G06

/*
CHECK_CONSTRAINTS,	   -- Verifica las restricciones de la tabla al insertar los datos
FORMAT = 'CSV',		   -- Especifica que el archivo que se está importando está en formato CSV permitiendo que SQL Server maneje automáticamente la coma como delimitador y considere comillas dobles para los valores con caracteres especiales.
CODEPAGE = '65001',	   -- indica que SQL Server debe utilizar UTF-8 como la página de códigos, al leer el archivo
FIRSTROW = 2,		   -- Omitir la primera fila si el archivo tiene encabezados
FIELDTERMINATOR = ',', -- Define el delimitador de campos
ROWTERMINATOR = '0x0A') -- Define el delimitador de filas
*/

USE [master] 

GO 

EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

GO 

EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

GO 

--Creamos SP para importar la sucursal

CREATE OR ALTER PROCEDURE Venta.SucursalImportar
    @data_file_path VARCHAR(1000)
AS
BEGIN
    CREATE TABLE #sucursal
    (
        Localidad      VARCHAR(40) COLLATE Modern_Spanish_CI_AS,
        reemplazar     VARCHAR(40) COLLATE Modern_Spanish_CI_AS,  
        direccion      VARCHAR(150) COLLATE Modern_Spanish_CI_AS,
        horario        VARCHAR(50) COLLATE Modern_Spanish_CI_AS,
        telefono       CHAR(9) COLLATE Modern_Spanish_CI_AS
    );

    DECLARE @sql NVARCHAR(MAX);

    SET @sql = N'
    INSERT INTO #sucursal
    SELECT *
    FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
                    ''Excel 12.0 Xml;Database=' + @data_file_path + ''',
                    ''SELECT * FROM [sucursal$]'');';
	
    EXEC sp_executesql @sql;

    -- Limpiar el campo 'horario'
	
    UPDATE #sucursal
    SET horario = REPLACE(
							REPLACE(
									REPLACE(
										REPLACE(
											REPLACE(LTRIM(RTRIM(horario)), '?', ' '),  -- Reemplazar el carácter '?' por un espacio
												 '-', '–'  -- Reemplazar el guion corto con guion largo
												),
											 'a.m.', 'a.m.'  -- Asegurar que no haya espacios dentro de 'a.m.'
											),
									 'p.m.', 'p.m.'  -- Asegurar que no haya espacios dentro de 'p.m.'
									 ),
						'–', ' – '  -- Asegurar espacios antes y después del guion largo
						);

	INSERT INTO  Venta.sucursal(Localidad_Ori,direccion,Localidad_Real,horario,telefono) --agregamos los estudios nuevos a la tabla de estudios.
	SELECT DISTINCT s.Localidad, s.direccion, s.reemplazar, s.horario, s.telefono
	FROM #sucursal s

	DROP TABLE #sucursal

END;
GO


select *
from Venta.sucursal


EXEC Venta.SucursalImportar
	@data_file_path = 'C:\Temp\Informacion_complementaria.xlsx';
GO


CREATE OR ALTER PROCEDURE Persona.EmpleadosImportar
	@data_file_path VARCHAR(MAX)
AS
BEGIN
	BEGIN TRY

		IF OBJECT_ID('tempdb..#tmpEmpleado') IS NOT NULL
			DROP TABLE #tmpEmpleado;

		CREATE TABLE #tmpEmpleado (
			Legajo INT,
			Nombre VARCHAR(100),
			Apellido VARCHAR(100),
			DNI INT,
			Direccion VARCHAR(100),
			emailpersonal VARCHAR(100),
			emailempresa VARCHAR(100),
			CUIL INT,
			Cargo VARCHAR(20),
			Ciudad_sucursal VARCHAR(100),
			Turno VARCHAR(18)
		);

		SET NOCOUNT ON;

		DECLARE @sql NVARCHAR(MAX);

		SET @sql = '
			INSERT INTO #tmpEmpleado (Legajo,Nombre,Apellido,DNI,Direccion,emailpersonal,emailempresa,CUIL,Cargo,Ciudad_sucursal,Turno)
			SELECT * 
			FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
			 ''Excel 12.0;Database='++ @data_file_path ++''',
			 ''select * from [Empleados$]'');
		';
		EXEC sp_executesql @sql;
		
		UPDATE #tmpEmpleado
		SET Turno = Case
			WHEN Turno = 'Jornada completa' THEN 'JC'
			ELSE Turno
			END;
		
		INSERT INTO Persona.empleado(Legajo,Nombre,Apellido,DNI,Direccion,Email_Personal,Email_Empresa,CUIL,Cargo,Turno,Id_Suc)
			(SELECT tmp.Legajo,
					REPLACE(tmp.Nombre, CHAR(9), ' '),
					REPLACE(tmp.Apellido, CHAR(9), ' '),
					tmp.DNI,
					tmp.Direccion,
					REPLACE(REPLACE(tmp.emailpersonal, ' ', ''), CHAR(9), ''),
					REPLACE(REPLACE(tmp.emailempresa, ' ', ''), CHAR(9), ''),
					tmp.DNI,
					tmp.Cargo,
					tmp.Turno,
					(SELECT Id_Suc FROM Venta.sucursal WHERE Localidad_Real = tmp.Ciudad_sucursal COLLATE Modern_Spanish_CS_AS)
		FROM #tmpEmpleado tmp 
		WHERE tmp.Legajo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Persona.empleado e WHERE tmp.Legajo = e.Legajo))

	END TRY
	BEGIN CATCH
		PRINT 'Error al importar Excel Empleados' + ERROR_MESSAGE();
	END CATCH

		DROP TABLE IF EXISTS #tmpEmpleado;
END;
GO


 select *
 from Persona.Empleado


EXEC Persona.EmpleadosImportar
	@data_file_path = 'C:\Temp\Informacion_complementaria.xlsx';
GO

ROUND(((99 - 1) * RAND() + 1), 0) +  + ROUND(((9 - 1) * RAND() + 1), 0)





CREATE OR ALTER PROCEDURE importar.CategoriaImportar
	@data_file_path VARCHAR(MAX)
AS
BEGIN
		BEGIN TRY

			IF OBJECT_ID('tempdb..#tmpCategoria') IS NOT NULL
				DROP TABLE #tmpCategoria;

			CREATE TABLE #tmpCategoria (
				Linea_De_Producto VARCHAR(100),
				Producto VARCHAR(100),
				);

			SET NOCOUNT ON;

			DECLARE @sql NVARCHAR(MAX);

			SET @sql = '
				INSERT INTO #tmpCategoria(Linea_De_Producto,Producto)
				SELECT * 
				FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
				 ''Excel 12.0;Database='++ @data_file_path ++''',
				 ''select * from [Clasificacion productos$]'');
			';
			EXEC sp_executesql @sql;

			INSERT INTO Articulo.categoria(Linea_De_Producto,Descripcion)
			(
				SELECT tmp.Linea_De_Producto, tmp.Producto
				FROM #tmpCategoria tmp
				WHERE NOT EXISTS(
					SELECT 1
					FROM Articulo.categoria c
					WHERE tmp.Producto = c.Descripcion COLLATE Modern_Spanish_CI_AS)
			)
		END TRY

	BEGIN CATCH
		PRINT 'Error al importar Excel Categoria' + ERROR_MESSAGE();
	END CATCH
		DROP TABLE IF EXISTS #tmpCategoria;
END;
GO

 select *
 from Articulo.categoria


EXEC importar.CategoriaImportar
	@data_file_path = 'C:\Temp\Informacion_complementaria.xlsx';
GO









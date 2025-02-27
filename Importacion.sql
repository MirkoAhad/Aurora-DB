--TODO IMPORTADO
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

USE Com1353G06
GO

--Importacion de sucursal

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

EXEC Venta.SucursalImportar
	@data_file_path = 'C:\Temp\Informacion_complementaria.xlsx';
GO

select *
from Venta.sucursal


--Importacion de empleados

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
			 ''Excel 12.0;Database=' + @data_file_path + ''',
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

EXEC Persona.EmpleadosImportar
	@data_file_path = 'C:\Temp\Informacion_complementaria.xlsx';
GO

 select *
 from Persona.Empleado


ROUND(((99 - 1) * RAND() + 1), 0) +  + ROUND(((9 - 1) * RAND() + 1), 0) --Para que?

--Importamos las categorias

CREATE OR ALTER PROCEDURE Articulo.CategoriaImportar
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

EXEC Articulo.CategoriaImportar
	@data_file_path = 'C:\Temp\Informacion_complementaria.xlsx';
GO

 select *
 from Articulo.categoria



 --Importamos clientes

CREATE OR ALTER PROCEDURE Persona.ClienteImportar
	@data_file_path VARCHAR(MAX)
AS
BEGIN
		BEGIN TRY

			IF OBJECT_ID('tempdb..#tmpCliente') IS NOT NULL
				DROP TABLE #tmpCliente;

			CREATE TABLE #tmpCliente (
				Nombre VARCHAR(50),
				Genero VARCHAR(6),
				DNI int,
				Tipo varchar(7)
				);

			SET NOCOUNT ON;

			DECLARE @sql NVARCHAR(MAX);

			SET @sql = '
				INSERT INTO #tmpCliente(Nombre,Genero,DNI,TIpo)
				SELECT * 
				FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
				 ''Excel 12.0;Database='++ @data_file_path ++''',
				 ''select * from [Datos$]'');
			';
			EXEC sp_executesql @sql;

		insert Persona.Cliente (Nombre,Genero,DNI,Tipo)
		SELECT tmp.Nombre, tmp.Genero,tmp.DNI,tmp.Tipo
				FROM #tmpCliente tmp

	END TRY
	BEGIN CATCH
		PRINT 'Error al importar Excel Clientes' + ERROR_MESSAGE();
	END CATCH
		DROP TABLE IF EXISTS #tmpCliente;
END;
GO

Exec Persona.ClienteImportar 'C:\Temp\Clientes.xlsx';
go
	
select *
from Persona.Cliente


--IMPORTAR CATALOGO--

CREATE OR ALTER PROCEDURE Articulo.CatalogoImportar
	@data_file_path VARCHAR(MAX)
AS
BEGIN
		BEGIN TRY

			IF OBJECT_ID('tempdb..#tmpCatalogo') IS NOT NULL
				DROP TABLE #tmpCatalogo;

			CREATE TABLE #tmpCatalogo (
				ID INT,
				Category VARCHAR(50),
				Nombre VARCHAR(100),
				Price DECIMAL(20,2),
				Reference_price DECIMAL(20,2),
				Reference_unit VARCHAR(10),
				Fecha DATETIME
			);
			
	SET NOCOUNT ON; -- nos evitamos mensajes que generan trafico de red.
    
    DECLARE @sql NVARCHAR(MAX); -- creo de forma dinamica el ingreso, usando @sql

	SET @sql = '
		BULK INSERT #tmpCatalogo
		FROM ''' + @data_file_path + '''
		WITH(
				CHECK_CONSTRAINTS,
				FORMAT = ''CSV'',		   
				CODEPAGE = ''65001'',
				FIRSTROW = 2,		   
				FIELDTERMINATOR = '','',
				ROWTERMINATOR = ''0x0A''
			);
	';
	EXEC sp_executesql @sql;

	WITH cte_Dup
	AS
	(
		SELECT tmp.ID, ROW_NUMBER() OVER (PARTITION BY tmp.Nombre, tmp.Reference_price, tmp.Reference_unit, tmp.Price ORDER BY tmp.Fecha) as Duplicados
		FROM #tmpCatalogo tmp
	)

	/*SELECT *
	FROM cte_Dup
	WHERE Duplicados > 1
	
	DELETE FROM #tmpCatalogo
	WHERE ID in (
		SELECT ID FROM cte_dup WHERE DUPLICADOS > 1
		)
	
	--UPDATE #tmpCatalogo*/ -- HAY QUE VER COMO ARREGLAR LOS DUPLICADOS 

	INSERT INTO Articulo.producto(Nombre,Precio_Actual,Precio_Referencia,Unidad_Referencia,Fecha_Hora,ID_Cat)
	(
		SELECT tmp.Nombre,tmp.Price,tmp.Reference_price,tmp.Reference_unit,tmp.Fecha,
		(SELECT c.ID_Cat
			FROM Articulo.categoria c
			WHERE c.Descripcion = tmp.Category COLLATE Modern_Spanish_CI_AS)
		FROM #tmpCatalogo tmp
		WHERE NOT EXISTS(
			SELECT 1
				FROM Articulo.producto p
				WHERE p.Nombre = tmp.Nombre COLLATE Modern_Spanish_CI_AS
				AND p.Precio_Actual = tmp.Price
				AND p.Precio_Referencia = tmp.Reference_price
				AND p.Unidad_Referencia = tmp.Reference_unit COLLATE Modern_Spanish_CI_AS)
	)

	END TRY
	BEGIN CATCH
		PRINT 'Error al importar Excel Catalogo' + ERROR_MESSAGE();
	END CATCH
		DROP TABLE IF EXISTS #tmpCatalogo;
END;
GO

Exec Articulo.CatalogoImportar 'C:\Temp\catalogo.csv';
go

Select * from Articulo.Producto

DELETE FROM Articulo.Producto

--_____________________________PRODUCTOS IMPORTADOS__________________________

	CREATE OR ALTER PROCEDURE Articulo.Productos_ImpImportar
		@data_file_path VARCHAR(MAX)
	AS
	BEGIN
			BEGIN TRY
				IF OBJECT_ID('tempdb..#tmpProductos') IS NOT NULL
					DROP TABLE #tmpProductos;

				CREATE TABLE #tmpProductos (
					IdProducto INT,
					NombreProducto VARCHAR(100),
					Proveedor VARCHAR(100),
					Categoria VARCHAR(100),
					CantidadPorUnidad VARCHAR(100),
					PrecioUnidad DECIMAL(20,2)
				);
				SET NOCOUNT ON;

				DECLARE @sql NVARCHAR(MAX);

				SET @sql = '
					INSERT INTO #tmpProductos(IdProducto,NombreProducto,Proveedor,Categoria,CantidadPorUnidad,PrecioUnidad)
					SELECT * 
					FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
					 ''Excel 12.0;Database='++ @data_file_path ++''',
					 ''select * from [Listado de Productos$]'');
				';
				EXEC sp_executesql @sql;

				--UPDATE #tmpProductos
				--SET Categoria = CONCAT('importado_',Categoria)

				INSERT INTO Articulo.categoria(Descripcion,Linea_De_Producto)
				(
					SELECT DISTINCT tmp.Categoria,'Importado'
						FROM #tmpProductos tmp
						WHERE NOT EXISTS 
						(
							SELECT 1
								FROM Articulo.categoria c
								WHERE c.Descripcion = tmp.Categoria COLLATE Modern_Spanish_CI_AS
						)
				)

				INSERT INTO Articulo.producto(Nombre,Precio_Actual, ID_Cat)
				SELECT tmp.NombreProducto,tmp.PrecioUnidad,
					(SELECT c.ID_Cat
					FROM Articulo.categoria c
					WHERE c.Descripcion = tmp.Categoria COLLATE Modern_Spanish_CI_AS)
				FROM #tmpProductos tmp
				WHERE NOT EXISTS(
					SELECT 1
						FROM Articulo.producto p
						WHERE p.Nombre = tmp.NombreProducto COLLATE Modern_Spanish_CI_AS
						AND p.Precio_Actual = tmp.PrecioUnidad
				)
			END TRY
			BEGIN CATCH
				PRINT 'Error al importar Excel Productos Importados' + ERROR_MESSAGE();
			END CATCH
				DROP TABLE IF EXISTS #tmpProductos;
	END;
	go

Exec Articulo.Productos_ImpImportar 'C:\Temp\Productos_importados.xlsx';
go



select * FROM Articulo.Categoria
select * from articulo.Producto



------PRODUCTOS Electronicos-------

	CREATE OR ALTER PROCEDURE Articulo.ElectronicosImportar
		@data_file_path VARCHAR(MAX)
	AS
	BEGIN
			BEGIN TRY
				IF OBJECT_ID('tempdb..#tmpElectronicos') IS NOT NULL
					DROP TABLE #tmpElectronicos;

				CREATE TABLE #tmpElectronicos (
					NombreProducto VARCHAR(100),
					PrecioUnidad DECIMAL(20,2)
				);
				SET NOCOUNT ON;

				DECLARE @sql NVARCHAR(MAX);

				SET @sql = '
					INSERT INTO #tmpElectronicos(NombreProducto,PrecioUnidad)
					SELECT * 
					FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
					 ''Excel 12.0;Database='++ @data_file_path ++''',
					 ''select * from [Sheet1$]'');
				';
				EXEC sp_executesql @sql;

				--UPDATE #tmpProductos
				--SET Categoria = CONCAT('importado_',Categoria)
				UPDATE #tmpElectronicos
				SET PrecioUnidad = PrecioUnidad * 1220

				INSERT INTO Articulo.categoria(Linea_De_Producto)
					SELECT DISTINCT 'Electrodomesticos'

				INSERT INTO Articulo.producto(Nombre,Precio_Actual)
				SELECT tmp.NombreProducto,tmp.PrecioUnidad
				FROM #tmpElectronicos tmp
				WHERE NOT EXISTS(
					SELECT 1
						FROM Articulo.producto p
						WHERE p.Nombre = tmp.NombreProducto COLLATE Modern_Spanish_CI_AS
						AND p.Precio_Actual = tmp.PrecioUnidad
				)
			END TRY
			BEGIN CATCH
				PRINT 'Error al importar Excel Electronicos ' + ERROR_MESSAGE();
			END CATCH
				DROP TABLE IF EXISTS #tmpElectronicos;
	END;
	go

Exec Articulo.ElectronicosImportar 'C:\Temp\Electronic accessories.xlsx';
go

select * FROM Articulo.Categoria
select * from articulo.Producto


--IMPORTAR MEDIOS DE PAGO--

CREATE OR ALTER PROCEDURE Venta.MediodePagoImportar
	@data_file_path VARCHAR(MAX)
AS
BEGIN
		BEGIN TRY

			IF OBJECT_ID('tempdb..#tmpMedio') IS NOT NULL
				DROP TABLE #tmpMedio;

			CREATE TABLE #tmpMedio (
				Vacio VARCHAR(30) NULL,
				Ingles VARCHAR(30),
				Español VARCHAR(30))

			SET NOCOUNT ON;

			DECLARE @sql NVARCHAR(MAX);

			SET @sql = '
				INSERT INTO #tmpMedio(Vacio,Ingles,Español)
				SELECT * 
				FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
				 ''Excel 12.0;Database='++ @data_file_path ++''',
				 ''select * from [medios de pago$]'');
			';
			EXEC sp_executesql @sql;

			INSERT INTO Venta.Medio_Pago(nombre)
				SELECT tmp.Ingles
				FROM #tmpMedio tmp
		END TRY

	BEGIN CATCH
		PRINT 'Error al importar Excel Medios de Pago' + ERROR_MESSAGE();
	END CATCH
		DROP TABLE IF EXISTS #tmpMedio;
END;
GO

EXEC Venta.MediodePagoImportar
	@data_file_path = 'C:\Temp\Informacion_complementaria.xlsx';
GO

select * from Venta.Medio_Pago



--VENTAS REGISTRADAS--
CREATE OR ALTER PROCEDURE Venta.VentasImportar
	@data_file_path VARCHAR(MAX)
AS
BEGIN
		BEGIN TRY
			IF OBJECT_ID('tempdb..#tmpVentas') IS NOT NULL
				DROP TABLE #tmpVentas;

			CREATE TABLE #tmpVentas (
				IDFactura CHAR(11) COLLATE Modern_Spanish_CI_AS,
				TipoFactura CHAR(1),
				Ciudad VARCHAR(40) COLLATE Modern_Spanish_CI_AS,
				TipoCliente VARCHAR(6) COLLATE Modern_Spanish_CI_AS,
				Genero VARCHAR(6) COLLATE Modern_Spanish_CI_AS,
				NombreProducto NVARCHAR(100) COLLATE Modern_Spanish_CI_AS,
				PrecioUnitario DECIMAL(20,2),
				Cantidad INT,
				Fecha VARCHAR(15),
				Hora TIME,
				MedioPago VARCHAR(30) COLLATE Modern_Spanish_CI_AS,
				LegajoEmpleado INT,
				IDPago VARCHAR(30) COLLATE Modern_Spanish_CI_AS
			);
			
	SET NOCOUNT ON; -- nos evitamos mensajes que generan trafico de red.
    
    DECLARE @sql NVARCHAR(MAX); -- creo de forma dinamica el ingreso, usando @sql

	SET @sql = '
		BULK INSERT #tmpVentas
		FROM ''' + @data_file_path + '''
		WITH(
				CHECK_CONSTRAINTS,
				FORMAT = ''CSV'',		   
				CODEPAGE = ''65001'',
				FIRSTROW = 2,		   
				FIELDTERMINATOR = '';'',
				ROWTERMINATOR = ''0x0A''
			);
	';
	EXEC sp_executesql @sql;

	INSERT INTO Venta.Factura(NumeroFactura,Tipo,Monto,EstadoPago)
		SELECT  tmp.IDFactura, 
				tmp.TipoFactura, 
				tmp.Cantidad * PrecioUnitario, 
				'Pagado'
		FROM #tmpVentas tmp
		WHERE NOT EXISTS (
		 SELECT 1 FROM Venta.Factura f 
		 WHERE f.NumeroFactura = tmp.IDFactura
			);

		INSERT INTO Venta.Venta_Registrada(IDPago,Fecha,Hora,ID_Emp,Id_MP,ID_Fac)
		SELECT tmp.IDPago,
		CONVERT(DATE, tmp.Fecha, 101),
		tmp.Hora,
		tmp.LegajoEmpleado,
			(SELECT m.Id_MP
			FROM Venta.Medio_Pago m
				WHERE m.Nombre = tmp.MedioPago),
		(SELECT f.Id
				FROM Venta.Factura f
				WHERE f.NumeroFactura = tmp.IDFactura)
		FROM #tmpVentas tmp

		INSERT INTO Venta.Detalle_Venta(Cantidad, PrecioUnitario,Subtotal, Id_Venta, Id_Prod)
		SELECT tmp.Cantidad, tmp.PrecioUnitario, tmp.PrecioUnitario * tmp.Cantidad, 
		(SELECT TOP 1 v.Id -- Me tira duplicados
			FROM Venta.Venta_Registrada v
			WHERE v.IdPago = tmp.IDPago),
		(SELECT TOP 1 p.Id_Prod -- me tira duplicados
			FROM Articulo.Producto p
			WHERE p.Nombre = tmp.NombreProducto)
		FROM #tmpVentas tmp

	END TRY
	BEGIN CATCH
		PRINT 'Error al importar Excel Ventas Registradas' + ERROR_MESSAGE();
	END CATCH
		DROP TABLE IF EXISTS #tmpVentas;
END;
GO

Exec Venta.VentasImportar 'C:\Temp\Ventas_registradas.csv';
go
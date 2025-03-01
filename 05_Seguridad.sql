-- Grupo:06
-- Chacón Mirko Facundo - 43444942
-- Giannni Pérez, Gabriel Idelmar- 45614379
-- Nielsen, Tomas Agustín - 41326589
-- Silva , Pablo Ismael - 31641736
-------------------------------
-- Fecha de Entrega: 28/02/2025
-- Bases de Datos Aplicadas

-- Creacion de Logins en Master
Use Master;
go

-- El Jefe tiene autorizacion en el Rol Supervisores.
CREATE LOGIN Jefe
WITH PASSWORD = 'Contraseña'
, Check_Policy = on
go

-- Logins de Supervisores

CREATE LOGIN Francisco_Emmanuel_Lucena   
   WITH PASSWORD = 'Contraseña'
	,CHECK_POLICY = on
go

CREATE LOGIN Eduardo_Matias_Luna    
   WITH PASSWORD = 'Contraseña'
	,CHECK_POLICY = on
go

CREATE LOGIN Mauro_Alberto_Luna
   WITH PASSWORD = 'Contraseña'
	,CHECK_POLICY = on
go

CREATE LOGIN Emilce_Maidana    
   WITH PASSWORD = 'Contraseña'
	,CHECK_POLICY = on
go

CREATE LOGIN Noelia_Gisela_Fabiola_Maidana
   WITH PASSWORD = 'Contraseña'
	,CHECK_POLICY = on
go

CREATE LOGIN Fernanda_Gisela_Evangelina_Maizares     
   WITH PASSWORD = 'Contraseña'
	,CHECK_POLICY = on
go

use Com1353G06;
go

-- Creacion de Usuarios para el Rol Supervisores

CREATE USER Jefe FOR LOGIN Jefe
go
CREATE USER Francisco_Emmanuel_Lucena FOR LOGIN Francisco_Emmanuel_Lucena
go
CREATE USER Eduardo_Matias_Luna  FOR LOGIN Eduardo_Matias_Luna
go
CREATE USER Mauro_Alberto_Luna FOR LOGIN Mauro_Alberto_Luna
go
CREATE USER Emilce_Maidana  FOR LOGIN Emilce_Maidana
go
CREATE USER Noelia_Gisela_Fabiola_Maidana FOR LOGIN Noelia_Gisela_Fabiola_Maidana
go
CREATE USER Fernanda_Gisela_Evangelina_Maizares FOR LOGIN Fernanda_Gisela_Evangelina_Maizares
go

-- Creo el Rol Supervisores dandole autorizacion al Jefe.
CREATE ROLE Supervisores AUTHORIZATION Jefe;
GO

--DROP ROLE Supervisores; Si quiero borrar el Rol.

-- Agrego a los miembros al Rol.
ALTER ROLE Supervisores ADD MEMBER Francisco_Emmanuel_Lucena;
go
ALTER ROLE Supervisores ADD MEMBER Eduardo_Matias_Luna; 
go
ALTER ROLE Supervisores ADD MEMBER Mauro_Alberto_Luna;
go
ALTER ROLE Supervisores ADD MEMBER Emilce_Maidana;
go
ALTER ROLE Supervisores ADD MEMBER Noelia_Gisela_Fabiola_Maidana;
go
ALTER ROLE Supervisores ADD MEMBER Fernanda_Gisela_Evangelina_Maizares;
go

--ALTER ROLE vendedores DROP MEMBER Francisco_Emmanuel; Si lo quiero borrar

-- Les otorgo los permisos de Insertar datos a la tabla Nota de Credito.
GRANT INSERT, DELETE, UPDATE, SELECT ON Venta.Nota_De_Credito TO Supervisores WITH GRANT OPTION;
GO
GRANT EXECUTE ON Venta.GenerarNotaCredito TO Supervisores WITH GRANT OPTION;
GO
GRANT SELECT ON Venta.Factura TO Supervisores WITH GRANT OPTION;
GO

DENY INSERT ON Venta.Nota_De_Credito TO Supervisores; -- Les deniego el permiso de insertar cualquier dato no valido directamente a la tabla.
GO
DENY DELETE ON Venta.Nota_De_Credito TO Supervisores; -- No pueden borrar todas las notas de credito de la tabla.
GO
GRANT EXECUTE ON Venta.GenerarNotaCredito TO Supervisores; -- Les permito que usen el SP para generar las notas de crédito.
GO
DENY UPDATE ON Venta.Nota_De_Credito TO Supervisores; -- No pueden hacer un update de los datos no es necesario.
GO
GRANT SELECT ON Venta.Factura TO Supervisores -- Les permito ver las facturas de la tabla.
GO
GRANT SELECT ON Venta.Nota_De_Credito TO Supervisores -- Les permito ver las notas de crédito generadas.

-- Voy a revisar como mejorar lo de los permisos.


CREATE OR ALTER PROCEDURE Venta.GenerarNotaCredito -- Es un SP que me permite generar las notas de crédito.
    @Id_Fac INT,
    @Monto DECIMAL(17,2),
    @Fecha DATE
AS
BEGIN

    -- Verificar que la factura exista y esté en estado "Pagada"
    IF NOT EXISTS (
        SELECT 1 FROM Venta.Factura 
        WHERE Id = @Id_Fac AND EstadoPago = 'Pagado' 
		
    )
    BEGIN
        RAISERROR('La Factura debe estar en estado Pagada.', 16, 1);
        RETURN;
    END
	ELSE
	IF Not Exists (select 1 from Venta.Factura where monto = @Monto and Id = @Id_Fac)

BEGIN
RAISERROR ('El monto no coincide con la factura',10,2);
Return;
END
	ELSE
	BEGIN
    -- Insertar la nota de crédito
    INSERT INTO Venta.Nota_De_Credito (Fecha, Monto, Id_Fac)
    VALUES (@Fecha, @Monto, @Id_Fac);

	

    PRINT 'Nota de crédito generada exitosamente.';
	END
END;
Go

										-- Logueo de usuarios del Rol de Supervisores --

-- Loguearse como Jefe
EXECUTE AS LOGIN = 'Jefe';
GO
EXEC Venta.GenerarNotaCredito 2, 6.25, '2025-02-27';
GO
REVERT; -- El Revert para desloguearme.
GO

-- Loguearse como Francisco_Emmanuel_Lucena
EXECUTE AS LOGIN = 'Francisco_Emmanuel_Lucena';
GO
EXEC Venta.GenerarNotaCredito 3, 8.40, '2025-02-27'; -- El Supervisor Francisco Emmanuel puede generar Nota de Credito.
GO
Exec Venta.GenerarNotaCredito 2,22.25,'2025-02-27'; -- Como el monto no coincide con el monto de la factura no se puede generar la nota de crédito.
GO
REVERT; -- El Revert para desloguearme.
GO

-- Loguearse como Eduardo_Matias_Luna
EXECUTE AS LOGIN = 'Eduardo_Matias_Luna';  -- El Supervisor Eduardo Matias puede generar Nota de Credito.
GO
EXEC Venta.GenerarNotaCredito 4, 10.40, '2025-02-27';
GO
REVERT;
GO

-- Loguearse como Mauro_Alberto_Luna
EXECUTE AS LOGIN = 'Mauro_Alberto_Luna';
GO
EXEC Venta.GenerarNotaCredito 5, 13.30, '2025-02-27';  -- El Supervisor Mauro Alberto puede generar Nota de Credito.
GO
EXEC Venta.GenerarNotaCredito 50, 55.20, '2025-02-27';  -- No se puede generar porque el monto no coincide al de la Factura.
REVERT; -- El Revert para desloguearme.
GO

-- Loguearse como Emilce_Maidana
EXECUTE AS LOGIN = 'Emilce_Maidana';
GO
EXEC Venta.GenerarNotaCredito 6, 15.40, '2025-02-27'; -- El Supervisor Emilce Maidana puede generar Nota de Credito.
GO
EXEC Venta.GenerarNotaCredito 6, 15.40, '2025-02-27'; -- No se puede generar porque no debe haber repetidos.

REVERT; -- El Revert para desloguearme.
GO

-- Loguearse como Noelia_Gisela_Fabiola_Maidana
EXECUTE AS LOGIN = 'Noelia_Gisela_Fabiola_Maidana'; 
GO
EXEC Venta.GenerarNotaCredito 7, 5.70, '2025-02-27';  -- La Supervisora Fernanda Gisela puede generar Nota de Credito.
GO
REVERT; -- El Revert para desloguearme.
GO

-- Loguearse como Fernanda_Gisela_Evangelina_Maizares
EXECUTE AS LOGIN = 'Fernanda_Gisela_Evangelina_Maizares';
GO
EXEC Venta.GenerarNotaCredito 10, 4.77, '2025-02-27';  -- La Supervisora Fernanda Gisela puede generar Nota de Credito.
Go
EXEC Venta.GenerarNotaCredito 10, 4.77, '2025-02-27'; -- Si se vuelve a generar con el mismo Id no puede haber repetidos.
GO
REVERT; -- El Revert para desloguearme.
GO



-- Me Logueo con cualquier Supervisor:

EXECUTE AS LOGIN = 'Fernanda_Gisela_Evangelina_Maizares';
GO

select* from Venta.Factura; --Cualquier Supervisor puede revisar las facturas.
GO
select *
from venta.Nota_De_Credito;   -- Cualquier Supervisor puede verificar con el select si se genero exitosamente la nota de crédito.
GO
Delete Venta.Nota_De_Credito; -- No pueden borrar los datos de la Nota de Credito.
GO
INSERT VENTA.Nota_De_Credito VALUES ('2022-02-02',2.25,20) -- Si siendo supervisor pongo cualquier dato sin el SP no puede insertar datos
GO
REVERT; -- El Revert para desloguearme.
GO





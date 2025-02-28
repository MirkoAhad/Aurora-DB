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

GRANT INSERT ON Venta.Nota_De_Credito TO Supervisores; -- Solo pueden generar Notas de Credito.
DENY UPDATE, DELETE, SELECT ON Venta.Nota_De_Credito TO Supervisores; -- No pueden modificar, ni borrar, ni mirar todas las notas de credito.

select *
from venta.Factura

select *
from venta.Nota_De_Credito

CREATE OR ALTER PROCEDURE Venta.GenerarNotaCredito
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

Exec GenerarNotaCredito 1001,35,'2025-02-27';
Go

--drop table venta.Nota_De_Credito

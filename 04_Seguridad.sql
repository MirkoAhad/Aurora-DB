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

CREATE OR ALTER PROCEDURE SP_GenerarNotaCredito
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

Exec SP_GenerarNotaCredito 1001,35,'2025-02-27';

drop table venta.Nota_De_Credito


-- Cifrar los datos de los empleados


drop table Persona.Empleado


-- Agregar columnas para encriptar datos
ALTER TABLE Persona.Empleado  
ADD
    DireccionCifrar VARBINARY(256),
    EmailPersonalCifrar VARBINARY(256),
    EmailEmpresaCifrar VARBINARY(256);
GO

-- Definir la frase de cifrado
DECLARE @FraseClave NVARCHAR(128) = 'MiClaveSecreta'; 

-- Encriptar datos
UPDATE Persona.Empleado  
SET 
 
    DireccionCifrar = EncryptByPassPhrase(@FraseClave, Direccion),
    EmailPersonalCifrar = EncryptByPassPhrase(@FraseClave, Email_Personal),
    EmailEmpresaCifrar = EncryptByPassPhrase(@FraseClave, Email_Empresa);
GO

-- Verificar datos encriptados
SELECT  DireccionCifrar, EmailPersonalCifrar, EmailEmpresaCifrar
FROM Persona.Empleado;
GO

-- Crear nuevas columnas temporales para desencriptar datos
ALTER TABLE Persona.Empleado  
ADD 
    Direccion_Desencriptada VARCHAR(100),
    EmailPersonal_Desencriptado VARCHAR(100),
    EmailEmpresa_Desencriptado VARCHAR(100);
GO



-- Desencriptar datos
DECLARE @FraseClave NVARCHAR(128) = 'MiClaveSecreta'; 

UPDATE Persona.Empleado  
SET  
    Direccion_Desencriptada = CONVERT(VARCHAR(100), DecryptByPassPhrase(@FraseClave, DireccionCifrar)),
    EmailPersonal_Desencriptado = CONVERT(VARCHAR(100), DecryptByPassPhrase(@FraseClave, EmailPersonalCifrar)), 
    EmailEmpresa_Desencriptado = CONVERT(VARCHAR(100), DecryptByPassPhrase(@FraseClave, EmailEmpresaCifrar));
GO

-- Verificar datos desencriptados
SELECT Direccion_Desencriptada, 
       EmailPersonal_Desencriptado, EmailEmpresa_Desencriptado
FROM Persona.Empleado;
GO

-- Eliminar las columnas encriptadas
ALTER TABLE Persona.Empleado  
DROP COLUMN  DireccionCifrar, EmailPersonalCifrar, EmailEmpresaCifrar;
GO

-- Eliminar las columnas temporales de desencriptación
ALTER TABLE Persona.Empleado  
DROP COLUMN Direccion_Desencriptada, 
           EmailPersonal_Desencriptado, EmailEmpresa_Desencriptado;
GO

-- Ver toda la tabla 
select *
from Persona.empleado















---------------------
SELECT CURRENT_USER;  


-- Veamos los propietarios de las DB
SELECT d.name, d.owner_sid, sl.name
FROM sys.databases AS d
JOIN sys.sql_logins AS sl
ON d.owner_sid = sl.sid;


-- permisos otorgados explicitamente
SELECT
    perms.state_desc AS State,
    permission_name AS [Permission],
    obj.name AS [on Object],
    dp.name AS [to User Name]
FROM sys.database_permissions AS perms
JOIN sys.database_principals AS dp
    ON perms.grantee_principal_id = dp.principal_id
JOIN sys.objects AS obj
    ON perms.major_id = obj.object_id;


	-- ver roles de la DB y usuarios asignados
SELECT    roles.principal_id                            AS RolePrincipalID
    ,    roles.name                                    AS RolePrincipalName
    ,    database_role_members.member_principal_id    AS MemberPrincipalID
    ,    members.name                                AS MemberPrincipalName
FROM sys.database_role_members AS database_role_members  
JOIN sys.database_principals AS roles  
    ON database_role_members.role_principal_id = roles.principal_id  
JOIN sys.database_principals AS members  
    ON database_role_members.member_principal_id = members.principal_id;  
GO


-- Ver roles fijos de servidor y usuarios asignados
SELECT SRM.role_principal_id, SP.name AS Role_Name,   
SRM.member_principal_id, SP2.name  AS Member_Name  
FROM sys.server_role_members AS SRM  
JOIN sys.server_principals AS SP  
    ON SRM.Role_principal_id = SP.principal_id  
JOIN sys.server_principals AS SP2   
    ON SRM.member_principal_id = SP2.principal_id  
ORDER BY  SP.name,  SP2.name













CREATE TABLE Persona.Cliente (
    Id_Cli INT IDENTITY (1,1) PRIMARY KEY,
    Nombre VARCHAR (30) not null,
    Genero CHAR (6) not null,
	DNI int not null,
    Tipo CHAR(6) not null,
	Baja Date default null,
	CONSTRAINT CK_Genero CHECK (Genero IN ('Female','Male'))
); 

CREATE TABLE Venta.Medio_Pago (
    Id_MP INT IDENTITY (1,1) PRIMARY KEY,
    Descripcion CHAR (21),
	Baja Date default null
);

CREATE TABLE Venta.Factura (
    Id INT IDENTITY (1,1) PRIMARY KEY,
	NumeroFactura CHAR(11) UNIQUE,
    Tipo CHAR(1),
    MontoFactura DECIMAL(10,2), 
	EstadoPago VARCHAR(17) DEFAULT 'Pendiente de pago',
	Estado BIT DEFAULT 1, 
    CONSTRAINT CK_Tipo CHECK( Tipo IN ('A','B','C')),
	CONSTRAINT CK_NumeroFactura CHECK (NumeroFactura LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]')
);


CREATE TABLE  Venta.Sucursal (
    Id_Suc INT IDENTITY (1,1) PRIMARY KEY,
    Localidad_Ori VARCHAR (40) not null,
    Localidad_Real VARCHAR(40) not null,
	Direccion VARCHAR(150),
    Telefono CHAR(9),
	Estado BIT NOT NULL DEFAULT 1,
    Horario VARCHAR(50)
);
CREATE TABLE Articulo.Categoria (
    ID_Cat INT IDENTITY (1,1) PRIMARY KEY,
	Linea_De_Producto VARCHAR(20),
    Descripcion VARCHAR (50), --ESTO SERIA LA CATEGORIA (cambiar nombre a categoria y actualizar el procedure de importacion)
	Estado BIT NOT NULL DEFAULT 1
);


CREATE TABLE Articulo.Producto (
    Id_Prod INT IDENTITY (1,1) PRIMARY KEY,
    Nombre VARCHAR (100),
    Fecha_hora DATETIME,
    Precio_Unitario DECIMAL(20,2),
    Proveedor VARCHAR (40),
    Precio_Referencia decimal (20,2),
    Unidad_Referencia VARCHAR(10),
	Estado BIT NOT NULL DEFAULT 1, 
    ID_Cat INT,
    CONSTRAINT FK_Cat FOREIGN KEY (ID_Cat) REFERENCES Articulo.Categoria(ID_Cat)
);




CREATE TABLE Venta.Venta_Registrada (
	Id_Pago bigint primary key,
    Fecha DATE,
    Hora TIME,
    Ciudad VARCHAR(20),
	MontoTotal DECIMAL(10,2),
	Estado BIT NOT NULL DEFAULT 1,
    Id_Emp INT,
    Id_Fac INT,
    Id_Cli INT,
    Id_MP INT,
    CONSTRAINT FK_Emp FOREIGN KEY (Id_Emp) REFERENCES Persona.Empleado(Legajo),
    CONSTRAINT FK_Fac_VR FOREIGN KEY (Id_Fac) REFERENCES Venta.Factura(Id),
    CONSTRAINT FK_Cli FOREIGN KEY (Id_Cli) REFERENCES Persona.Cliente(Id_Cli),
    CONSTRAINT FK_MP FOREIGN KEY (Id_MP) REFERENCES Venta.Medio_Pago(Id_MP)
	);

CREATE TABLE Venta.Detalle_Venta (
    Cantidad INT not null,
    PrecioUnitario Decimal(10,2) not null,
    Subtotal Decimal(10,2) not null,
    Id_Prod INT not null,
	Id_Pago BigInt not null,
	CONSTRAINT PK_Detalle_Venta PRIMARY KEY (Id_Prod, Id_Pago), -- saque ID_Det, me parecio que era mejor usar una PK compuesta
	CONSTRAINT CK_Cantidad_Detalle CHECK (Cantidad > 0),
	CONSTRAINT CK_PrecioUnitario CHECK (PrecioUnitario > 0),
    CONSTRAINT FK_Prod FOREIGN KEY (Id_Prod) REFERENCES Articulo.Producto(Id_Prod),
	CONSTRAINT FK_Id_Pago FOREIGN KEY (Id_Pago) REFERENCES Venta.Venta_Registrada(Id_Pago)
);

CREATE TABLE Venta.Nota_De_Credito (
    Id INT IDENTITY(1,1), -- lo hice INT porque no es el mismo ID que factura
    Fecha DATE NOT NULL,
    Monto INT NOT NULL,
    Id_Fac INT NOT NULL,
    CONSTRAINT FK_Fac_Nota FOREIGN KEY (Id_Fac) REFERENCES Venta.Factura(Id) ON DELETE CASCADE,
	CONSTRAINT PK_IdNota PRIMARY KEY (Id, Id_Fac) -- Por ser debil deberia tener una Pk compuesta
);
/*
modificar empleado, 
modificar precio producto (creado), 
modificar sucursal (creado), 
modificar cliente, 
eliminar factura,
eliminar categoria (creado),
eliominar producto (creado)
eliminar empleado (creado)
eliminar venta
eliminar detalle venta
......
*/

-------------------------------
-- Grupo:06
-- Chacón Mirko Facundo - 43444942
-- Giannni Pérez, Gabriel Idelmar- 45614379
-- Nielsen, Tomas Agustín - 41326589
-- Silva , Pablo Ismael - 31641736
-------------------------------

-- Creacion de la BDD --

create database Com1353G06
use master
drop database Com1353G06
Use Com1353G06

-- Creacion de schemas --
create schema Persona
create schema Articulo
create schema Venta
create schema 
-- Creacion de tablas --


CREATE TABLE Persona.Cliente (
    Id_Cli INT IDENTITY (1,1) PRIMARY KEY,
    Nombre VARCHAR (30),
    Genero CHAR (6) not null,
    Tipo CHAR(11),
	Baja Date default null,
	CONSTRAINT CK_Genero CHECK (Genero IN ('Female','Male'))
); 

CREATE TABLE Venta.Medio_Pago (
    Id_MP INT IDENTITY (1,1) PRIMARY KEY,
    Descripcion CHAR (21),
	Baja Date default null
);

CREATE TABLE Venta.Factura (
    Id_Fac VARCHAR(11) PRIMARY KEY,
    Tipo CHAR(1),
    Fecha DATE,
    Monto NUMERIC (7,2), 
    CONSTRAINT CK_Tipo CHECK( Tipo IN ('A','B','C'))
);

CREATE TABLE  Venta.Sucursal (
    Id_Suc INT IDENTITY (1,1) PRIMARY KEY,
    Localidad VARCHAR (20) not null,
    Direccion VARCHAR(50) not null,
    Telefono CHAR(10),
    Horario varchar(44)
);

CREATE TABLE Articulo.Categoria (
    ID_Cat INT IDENTITY (1,1) PRIMARY KEY,
    Descripcion VARCHAR (30),
    Linea_De_Producto VARCHAR(20)
);


CREATE TABLE Articulo.Producto (
    Id_Prod INT IDENTITY (1,1) PRIMARY KEY,
    Nombre VARCHAR (20),
    Fecha_hora DATETIME,
    Precio Numeric(7,2),
    Proveedor VARCHAR (40),
    Referencia_Unit Decimal (10,2),
    Referencia CHAR(2),
    ID_Cat INT,
    CONSTRAINT FK_Cat FOREIGN KEY (ID_Cat) REFERENCES Articulo.Categoria(ID_Cat)
);

CREATE TABLE Persona.Empleado (
    Legajo int primary key,
    Nombre VARCHAR(30) NOT NULL,
    Apellido VARCHAR(25) NOT NULL,
    DNI INT NOT NULL,
    Direccion VARCHAR(50),
    Cargo VARCHAR(20),
    Email_Personal VARCHAR(100),
    Email_Empresa VARCHAR(100),
    Cuil INT DEFAULT 0,
    Turno CHAR(2),
    Id_Suc INT NOT NULL,
    CONSTRAINT Fk_Suc FOREIGN KEY (Id_Suc) REFERENCES Venta.Sucursal(Id_Suc),
    CONSTRAINT CK_Leg CHECK (Legajo BETWEEN 100000 AND 999999),
    CONSTRAINT CK_Tur CHECK (Turno IN ('TM','TT','JC','TN')), 
    CONSTRAINT CK_Cargo CHECK (Cargo IN ('Cajero','Supervisor','Gerente de sucursal'))
);


CREATE TABLE Venta.Venta_Registrada (
	Id_Pago int primary key,
    Tipo_Factura CHAR(1),
    Fecha DATE,
    Hora TIME,
    Tipo_Cliente VARCHAR(10),
    Ciudad VARCHAR(20),
    Cantidad INT,
    Producto VARCHAR (50),
    Precio_Unitario DECIMAL (10,2),
    Id_Emp INT,
    Id_Fac VARCHAR(11),
    Id_Cli INT,
    Id_MP INT,
	CONSTRAINT CK_Cantidad CHECK (Cantidad > 0),
    CONSTRAINT FK_Emp FOREIGN KEY (Id_Emp) REFERENCES Persona.Empleado(Legajo),
    CONSTRAINT FK_Fac_VR FOREIGN KEY (Id_Fac) REFERENCES Venta.Factura(Id_Fac),
    CONSTRAINT FK_Cli FOREIGN KEY (Id_Cli) REFERENCES Persona.Cliente(Id_Cli),
    CONSTRAINT FK_MP FOREIGN KEY (Id_MP) REFERENCES Venta.Medio_Pago(Id_MP),
    CONSTRAINT CK_TipoCl CHECK (Tipo_Cliente IN ('Member','Normal')),
   
);


CREATE TABLE Venta.Detalle_Venta (
    Id_Ven VARCHAR(11) PRIMARY KEY,
    Cantidad INT not null,
    Precio Decimal(10,2) not null,
    Subtotal Decimal(10,2) not null,
    Id_Prod INT not null,
    Id_Fac VARCHAR(11) not null,
    Id_Cli INT not null,
    Id_MP INT not null,

	CONSTRAINT CK_Cantidad_Detalle CHECK (Cantidad >= 0),
	CONSTRAINT CK_Precio CHECK (Precio > 0),
	CONSTRAINT CK_Subtotal CHECK (Subtotal > 0),
    CONSTRAINT FK_Prod FOREIGN KEY (Id_Prod) REFERENCES Articulo.Producto(Id_Prod),
    CONSTRAINT FK_Fac_DV FOREIGN KEY (Id_Fac) REFERENCES Venta.Factura(Id_Fac),
    CONSTRAINT FK_Cli_Venta FOREIGN KEY (Id_Cli) REFERENCES Persona.Cliente(Id_Cli),
    CONSTRAINT FK_MP_Venta FOREIGN KEY (Id_MP) REFERENCES Venta.Medio_Pago(Id_MP)
);


CREATE TABLE Venta.Nota_De_Credito (
    Numero_Comprobante VARCHAR(20) PRIMARY KEY,
    Fecha DATE,
    Monto INT,
    Id_Fac VARCHAR(11),
    CONSTRAINT FK_Fac_Nota FOREIGN KEY (Id_Fac) REFERENCES Venta.Factura(Id_Fac)
);



						----- Creacion SP ------
-- Para la tabla Sucursal
create or alter procedure Venta.Insertar_Sucursal --Insertar datos en Sucursal
@Localidad varchar(20),
@Direccion varchar(50),
@Telefono char(10), 
@Horario varchar(44)
AS
BEGIN
IF exists (select 1 from Venta.Sucursal where Direccion = @Direccion)
	BEGIN
	RAISERROR('Esta Direccion %s ya existe en el sistema',10,2, @Direccion);
	END
	ELSE
	BEGIN
		insert into Venta.Sucursal (Direccion,Horario,Localidad,Telefono)
		values (@Direccion,@Horario,@Localidad,@Telefono);
	END

END
GO

create or alter procedure Venta.Baja_Sucursal --Dar de baja la sucursal
@Id_suc int
AS
BEGIN
IF exists (select 1 from Venta.Sucursal where Id_Suc=@Id_suc)
	BEGIN
	update Venta.Sucursal
	set  baja = getdate()
	Where Id_Suc = @Id_Suc and Baja is null
	END
	ELSE
	BEGIN
	RAISERROR('ERROR EN EL BORRADO LOGICO POR EL ID %d',10,2,@Id_suc);
	END
END

-- Para la tabla Cliente --
create or alter procedure Persona.Insertar_Cliente --Insertar datos de clientes
@Id_Cli int,
@Nombre varchar(30),
@Genero CHAR(6),
@Tipo CHAR(11)
AS
BEGIN
IF NOT EXISTS (Select 1 From Persona.Cliente Where Id_Cli = @Id_Cli)
	BEGIN
	insert into Persona.Cliente(Id_Cli,Nombre,Genero,tipo) 
	values( @Id_Cli, @Nombre, @Genero, @Tipo);
	END
	ELSE
	BEGIN
	RAISERROR('Esta Id %d ya pertenece a un cliente en el sistema',10,2,@Id_Cli)
    END
END

create or alter procedure Persona.Eliminar_Cliente --Dar de baja al cliente
@Id_Cli int
AS
BEGIN
IF EXISTS (Select 1 From Persona.Cliente Where Id_Cli = @Id_Cli)
	BEGIN
	update Persona.Cliente
	set Baja = getdate()
	where Id_Cli = @Id_Cli and baja is null
	END
	ElSE
	BEGIN
	RAISERROR('No se puede dar de baja al Cliente con Id: %d (No existe o ya fue dado de baja)',10,2,@Id_Cli)
	END

END
-- Para la tabla Medio De Pago -- 
CREATE OR ALTER PROCEDURE Venta.Insertar_Medio_De_Pago
@Descripcion CHAR (21)
AS
BEGIN 
	SET @Descripcion = UPPER(@Descripcion);
IF NOT EXISTS (select 1 from Venta.Medio_Pago where Descripcion = @Descripcion and baja is null)
BEGIN
	insert into Venta.Medio_Pago (Descripcion)
	Values(@Descripcion);
	END
	ELSE
	BEGIN
		RAISERROR ('Ya existe el medio de pago %s',10,2,@Descripcion);
	END

END

CREATE OR ALTER PROCEDURE Venta.Baja_Medio_De_Pago
@Id_MP int
AS
BEGIN
IF EXISTS (select 1 from Venta.Medio_Pago where Id_MP = @Id_MP and baja is null)
	BEGIN
	update Venta.Medio_Pago
	set Baja = getdate()
	END
ELSE
	BEGIN
	RAISERROR ('No se puede dar de baja el medio de pago %d',10,2,@Id_MP);
	END

END

-- Para la tabla de Factura

CREATE OR ALTER PROCEDURE Venta.Insertar_Factura
@Id_Fac VARCHAR(12),
@Tipo CHAR (1),
@Fecha Date,
@Monto NUMERIC (7,2),
@Estado CHAR (9)
AS
BEGIN
IF NOT EXISTS (Select 1 From Venta.Factura Where Id_Fac = @Id_Fac )
	BEGIN
	insert Venta.Factura (Id_Fac,Tipo,Fecha,Monto,Estado)
	values (@Id_Fac,@Tipo, @Fecha, @Monto, @Estado);
	END
	ELSE
		BEGIN
		RAISERROR ('No se puede insertar datos con esa Id: %s',10,2,@Id_Fac);
		END
END

CREATE OR ALTER PROCEDURE Venta.Pagar_Factura
@Id_Fac varchar(12)
AS
BEGIN
IF EXISTS (Select 1 From Venta.Factura Where Id_Fac = @Id_Fac)
	BEGIN
	UPDATE Venta.Factura
	SET Estado = 'Pagada'
	Where Id_Fac = @Id_Fac and Estado ='No Pagada'
	END
	ELSE
		BEGIN
		RAISERROR('No fue posible encontrar la Id :%s',10,2,@Id_Fac);
		END
END

-- Para la tabla Categoria

CREATE OR ALTER Procedure Articulo.Insertar_Categoria
@Descripcion varchar(30),
@Linea_De_Producto varchar(20)
AS
BEGIN
IF NOT EXISTS (Select 1 From Articulo.Categoria Where Descripcion = @Descripcion)
	BEGIN
	insert Articulo.Categoria (Descripcion,Linea_De_Producto)
	values (@Descripcion, @Linea_De_Producto);
	END
	ELSE
	BEGIN
	RAISERROR ('No fue posible insertar el producto: %s',10,2,@Descripcion);
	END
END

-- Para tabla Producto

CREATE OR ALTER PROCEDURE Articulo.Insertar_Producto
@NombreProd varchar(20),
@Prod_Categoria varchar (20),
@Fecha_hora Datetime,
@Precio Numeric (7,2),
@Proveedor varchar(40),
@Referencia_Unit Decimal (10,2),
@Referencia CHAR (2),
@Id_Cat int
AS
BEGIN
IF NOT EXISTS (Select 1 From Articulo.Producto Where NombreProd = @NombreProd and Prod_Categoria = @Prod_Categoria)
	BEGIN
	insert Articulo.Producto (NombreProd, Prod_Categoria, Fecha_Hora, Precio, Proveedor, Referencia_Unit, Referencia, Id_Cat)
	values (@NombreProd, @Prod_Categoria, @Fecha_Hora, @Precio, @Proveedor, @Referencia_Unit, @Referencia, @Id_Cat);
	END
	ELSE
		BEGIN
		RAISERROR('No fue posible insertar el producto %s',10,2,@NombreProd);
		END
END

-- Para tabla Empleado


CREATE OR ALTER PROCEDURE Persona.Insertar_Empleado
@Legajo int,
@Nombre VARCHAR(30),
@Apellido VARCHAR(25),
@DNI int,
@Direccion VARCHAR(50),
@Cargo VARCHAR(20),
@Email_Personal VARCHAR(100),
@Email_Empresa VARCHAR(100),
@Cuil int,
@Turno CHAR(2),
@Id_Suc int
AS
BEGIN
IF NOT EXISTS (Select 1 From Persona.Empleado Where Legajo = @Legajo)
	BEGIN
	insert Persona.Empleado (Legajo,Nombre,Apellido,DNI,Direccion,Cargo,Email_Personal,Email_Empresa,Cuil,Turno,Id_Suc)
	values (@Legajo,@Nombre,@Apellido,@DNI,@Direccion,@Cargo,@Email_Personal,@Email_Empresa,@Cuil,@Turno,@Id_Suc)
	END
	ELSE
		BEGIN
		RAISERROR ('Ya existe un Empleado con este Legajo: %d en el sistema',10,2,@Legajo);
		END
END

-- Para tabla Venta_Registrada

CREATE OR ALTER PROCEDURE Venta.Insertar_VRegistrada
@Id_Pago int,
@Tipo_Factura CHAR(1),
@Fecha DATE,
@Hora TIME,
@Tipo_Cliente VARCHAR(10),
@Ciudad VARCHAR(20),
@Cantidad int,
@Producto VARCHAR(50),
@Precio_Unitario DECIMAL (10,2),
@Id_Emp int,
@Id_MP int
AS
BEGIN
IF NOT EXISTS (Select 1 From Venta.Venta_Registrada Where Id_Pago = @Id_Pago)
	BEGIN
	insert Venta.Venta_Registrada (Id_Pago,Tipo_Factura,Fecha,Hora,Tipo_Cliente,Ciudad,Cantidad,Producto,Precio_Unitario,Id_Emp,Id_MP)
	values (@Id_Pago,@Tipo_Factura,@Fecha,@Hora,@Tipo_Cliente,@Ciudad,@Cantidad,@Producto,@Precio_Unitario,@Id_Emp,@Id_MP);
	END
	ELSE
		BEGIN
		RAISERROR('Ya se uso ese Id: %s',10,2,@Id_Pago);
		END
END

drop table venta.venta_registrada

-- Para la tabla Detalle_Venta

CREATE OR ALTER PROCEDURE Venta.Insertar_Detalle_Venta
@Id_Ven varchar(11),
@Cantidad int,
@Precio Decimal (10,2),
@Subtotal Decimal (10,2),
@Id_Prod int,
@Id_Fac varchar(11),
@Id_Cli int,
@Id_MP int
AS
BEGIN
IF NOT EXISTS (Select 1 From Venta.Detalle_Venta Where Id_Ven = @Id_Ven )
	BEGIN
	insert Venta.Detalle_Venta (Id_Ven,Cantidad,Precio,Subtotal,Id_Prod,Id_Fac,Id_Cli,Id_MP)
	values (@Id_Ven,@Cantidad,@Precio,@Subtotal,@Id_Prod,@Id_Fac,@Id_Cli,@Id_MP);
	END
	ELSE 
		BEGIN
		RAISERROR('Id en uso: %s',10,2,@Id_Ven);
		END
END



--caso de pruebas
exec Persona.Insertar_Cliente 6,'Juan Perez','Female','Normal'
exec Persona.Eliminar_Cliente 6

delete venta.sucursal
select *
from Persona.Cliente

exec Venta.Insertar_Sucursal null,null,'s','L a V 8 a. m.–9 p. m.
S y D 9 a. m.-8 p. m.'
exec Venta.Baja_Sucursal 3



exec Venta.Insertar_Medio_De_Pago EfecTivo
exec Venta.Baja_Medio_De_Pago 1
select *
from Venta.Medio_Pago

SET IDENTITY_INSERT Persona.Cliente ON; --Sirve para insertar ID manualmente porque es identity

exec Venta.Pagar_Factura '750-67-8428'
exec Venta.Insertar_Factura '750-67-8428','A','2015-02-03', 2000,'No Pagada'
select *
from Venta.Factura

exec Articulo.Insertar_Categoria 'agua','Almacen'
select *
from Articulo.Categoria

-- Importacion De Archivos

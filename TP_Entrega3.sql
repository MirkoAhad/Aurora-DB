-------------------------------
-- Grupo:06
-- Chacón Mirko Facundo - 43444942
-- Giannni Pérez, Gabriel Idelmar- 45614379
-- Nielsen, Tomas Agustín - 41326589
-- Silva , Pablo Ismael - 31641736
-------------------------------

-- Creacion de la BDD --

create database Com1353G06

Use Com1353G06

-- Creacion de schemas --
create schema Persona
create schema Articulo
create schema Venta
create schema 
-- Creacion de tablas --
create table Persona.cliente (
Id_Cli int identity (1,1) primary key,
nombre varchar (15),
Genero varchar (6),
Tipo varchar(6)
);

create table Persona.Empleado(
Id_Emp int identity (1,1) primary key,
Nombre varchar(15) not null,
Apellido varchar(15) not null,
DNI int not null ,
Legajo int unique not null,
Direccion varchar(30),
Cargo varchar(20),
Email_Personal varchar(40),
Email_Empresaa varchar(40),
Cuil int,
Turno Char (2),
Id_Suc int,

CONSTRAINT Fk_Suc FOREIGN KEY (Id_Suc) REFERENCES Venta.Sucursal(Id_Suc),
CONSTRAINT CK_Leg CHECK (Legajo between 100000 and 999999),
CONSTRAINT CK_Tur CHECK (Turno ('TM','TT','JC','TN') 
CONSTRAINT CK_Cargo CHECK (Cargo ('Cajero','Supervisor','Gerente de sucursal')
);

create table Articulo.Producto(
Id_Prod int identity (1,1) primary key,
nombre varchar (20),
Fecha_hora datetime,
Precio int,
Proveedor varchar (40),
Referencia_Unit int,
Referencia char(2),
ID_Cat int,
CONSTRAINT FK_Cat FOREIGN KEY (ID_Cat) REFERENCES Articulo.Categoria(ID_Cat)
);

create table Articulo.Categoria(
ID_Cat int identity (1,1) primary key,
Descripcion varchar (30),
Linea_De_Producto varchar(20)
);

create table Venta.Detalle_Venta(
Id_Ven varchar(11) primary key,
Cantidad int,
Precio int,
Subtotal int,
Id_Prod int,
CONSTRAINT FK_Prod FOREIGN KEY (Id_Prod) REFERENCES Articulo.Producto(Id_Prod)
);

create table Venta.Factura(
Id_Fac varchar(11) primary key,
Tipo char(1),
Fecha Date,
Monto int, 
CONSTRAINT CK_Tipo CHECK( Tipo('A','B','C'))
);

create table Venta.Venta_Registrada
( Id_VR int identity (1,1) primary key,
  Tipo_Factura char(1),
  Fecha date,
  Hora time,
  Tipo_Cliente varchar(10),
  Ciudad varchar(20),
  Cantidad int,
  Genero varchar(6),
  Producto varchar (50),
  Precio_Unitario Decimal (10,2),
  Id_Emp int,
  Id_Fac int,
  Id_Cli int,
  Id_MP int,
  CONSTRAINT FK_Emp FOREIGN KEY (Id_Emp) REFERENCES Persona.Empleado (Id_Emp),
  CONSTRAINT FK_Fac FOREIGN KEY (Id_Fac) REFERENCES Venta.Factura (Id_Fac),
  CONSTRAINT FK_Cli FOREIGN KEY (Id_Cli) REFERENCES Persona.Cliente (Id_Cli),
  CONSTRAINT FK_MP  FOREIGN KEY (Id_MP) REFERENCES Venta.Medio_Pago (Id_MP),
  CONSTRAINT CK_TipoCl CHECK( Tipo_Cliente in ('Member','Normal')),
  CONSTRAINT CK_Genero CHECK( Genero in ('Female','Male'))
);

create table Venta.Medio_Pago ( Id_MP int identity (1,1) primary key,
Tipo varchar (30),
Nombre varchar (20)
);

create table Venta.Nota_De_Credito (
Numero_Comprobante varchar(20) primary key,
Fecha date,
Monto int,
Id_Fac int,
CONSTRAINT FK_Fac FOREIGN KEY (Id_Fac) REFERENCES Venta.Factura (Id_Fac)
);

create table Venta.Sucursal(
Id_Suc int identity (1,1) primary key,
Ciudad varchar (20),
Direccion varchar(100),
Telefono varchar(9),
Horario Time,

CONSTRAINT CK_Suc CHECK('Ramos Mejia','Lomas del Mirador','San Justo')
);


--caso de pruebas
insert into Articulo.Categoria (descripcion,linea_de_producto)  values ('aceite', 'almacen')
INSERT INTO Articulo.Producto (nombre, Fecha_hora, Precio, Proveedor, Referencia_Unit, Referencia, ID_Cat)  
VALUES ('Aceite de Oliva', '2024-02-20 12:30:00', 10.50, 'Proveedor A', 12345, 'OL', 1);
INSERT INTO Articulo.Categoria (Descripcion, Linea_De_Producto)  
VALUES ('Bebidas', 'Supermercado');
select *
from Articulo.Categoria
select *
from Articulo.Producto

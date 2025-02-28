--IMPORTANTE
/*
1) Decidi que linea de producto incluya a importado y a electrodomesticos
2) importados tienen sus propias categorias. Electrodomesticos queda en NULL. 
3) Vale la pena poner fecha hora, proveedor, precio referencia, y unidad referencia? por lo que veo no se usa para nada de nada

*/

-- Creacion de la BDD --
use master
go

create database Com1353G06
go

Use Com1353G06
go

-- Creacion de schemas --
create schema Persona
go

create schema Articulo
go

create schema Venta
go
	
-- Creacion de tablas --

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
    Nombre VARCHAR(30),
	Baja Date default null
);

CREATE TABLE Venta.Factura (
    Id INT IDENTITY (1,1) PRIMARY KEY,
	NumeroFactura CHAR(11) UNIQUE,
    Tipo CHAR(1),
    Monto DECIMAL(17,2), 
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
    Nombre NVARCHAR (100), -- Articulos no registrados tienen simbolos raros y el varchar no lo detecta.
    Fecha_hora DATETIME,
    Precio_Actual DECIMAL(20,2),
    Proveedor VARCHAR (40),
    Precio_Referencia decimal (20,2),
    Unidad_Referencia VARCHAR(10),
	Estado BIT NOT NULL DEFAULT 1, 
    ID_Cat INT,
    CONSTRAINT FK_Cat FOREIGN KEY (ID_Cat) REFERENCES Articulo.Categoria(ID_Cat)
);




create table venta.ventasProductosNoRegistrados -- Posibles datos de excel de ventas que no podemos hacer coincidir con los productos del catalogo.
	(
		NumeroFactura	CHAR(11),
		Tipo	char(1),
		ciudad			VARCHAR(40),
		tipo_cliente	CHAR(6),
		Genero			CHAR(6),
		NombreProducto	nvarchar(200),
		Precio_unitario	DECIMAL(20, 2),
		Cantidad		int,
		Fecha			varchar(15),
		Hora			time,
		Medio_de_pago	varchar(20),
		idEmpleado		int,
		idPago			varchar(30)
    );

 CREATE TABLE Persona.Empleado (
    Legajo int primary key,
    Nombre VARCHAR(30) NOT NULL,
    Apellido VARCHAR(30) NOT NULL,
    DNI INT NOT NULL,
    Direccion VARCHAR(100),
    Cargo VARCHAR(20),
    Email_Personal VARCHAR(100),
    Email_Empresa VARCHAR(100),
    Cuil INT NOT NULL,
    Turno CHAR(2),
    Id_Suc INT NOT NULL,
	Estado BIT NOT NULL DEFAULT 1,
    CONSTRAINT Fk_Suc FOREIGN KEY (Id_Suc) REFERENCES Venta.Sucursal(Id_Suc),
    CONSTRAINT CK_Leg CHECK (Legajo BETWEEN 100000 AND 999999),
    CONSTRAINT CK_Tur CHECK (Turno IN ('TM','TT','JC')), 
    CONSTRAINT CK_Cargo CHECK (Cargo IN ('Cajero','Supervisor','Gerente de sucursal'))
);

CREATE TABLE Venta.Venta_Registrada (
	Id INT IDENTITY(1,1) primary key,
	IdPago VARCHAR(30),
    Fecha DATE,
    Hora TIME,
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
	Id_Det INT IDENTITY (1,1) primary key,
    Cantidad INT not null,
    PrecioUnitario DECIMAL(17,2) not null,
    Subtotal DECIMAL(17,2) not null,
    Id_Prod INT not null,
	Id_Venta INT not null,
	
	CONSTRAINT CK_Cantidad_Detalle CHECK (Cantidad > 0),
	CONSTRAINT CK_PrecioUnitario CHECK (PrecioUnitario > 0),
    CONSTRAINT FK_Prod FOREIGN KEY (Id_Prod) REFERENCES Articulo.Producto(Id_Prod),
	CONSTRAINT FK_Id_Venta FOREIGN KEY (Id_Venta) REFERENCES Venta.Venta_Registrada(Id)
);

CREATE TABLE Venta.Nota_De_Credito (
    Id INT IDENTITY(1,1), 
    Fecha DATE NOT NULL,
    Monto Decimal(17,2) NOT NULL,
    Id_Fac INT NOT NULL unique,
    CONSTRAINT FK_Fac_Nota FOREIGN KEY (Id_Fac) REFERENCES Venta.Factura(Id) ON DELETE CASCADE,
	CONSTRAINT PK_IdNota PRIMARY KEY (Id, Id_Fac) -- Por ser debil deberia tener una Pk compuesta
);




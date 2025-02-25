
use master
drop database Com1353G06

-- Creacion de la BDD --

create database Com1353G06

Use Com1353G06

-- Creacion de schemas --
create schema Persona;
create schema Articulo;
create schema Venta
	
-- Creacion de tablas --

CREATE TABLE Persona.Cliente (
    Id_Cli INT IDENTITY (1,1) PRIMARY KEY,
    Nombre VARCHAR (30) not null,
    Genero CHAR (6) not null,
	DNI int not null,
    Tipo CHAR(11) not null,
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
    Localidad VARCHAR (20) not null,
    Direccion VARCHAR(50) not null,
    Telefono CHAR(10),
	Estado BIT NOT NULL DEFAULT 1,
    Horario varchar(44)
);

CREATE TABLE Articulo.Categoria (
    ID_Cat INT IDENTITY (1,1) PRIMARY KEY,
    Descripcion VARCHAR (30),
    Linea_De_Producto VARCHAR(20),
	Estado BIT NOT NULL DEFAULT 1
);

CREATE TABLE Articulo.Producto (
    Id_Prod INT IDENTITY (1,1) PRIMARY KEY,
    Nombre VARCHAR (20),
    Fecha_hora DATETIME,
    Precio DECIMAL(7,2),
    Proveedor VARCHAR (40),
    Referencia_Unit Decimal (10,2),
    Referencia CHAR(2),
	Estado BIT NOT NULL DEFAULT 1, 
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
    Cuil varchar(13) DEFAULT 0,
    Turno CHAR(2),
    Id_Suc INT NOT NULL,
	Estado BIT NOT NULL DEFAULT 1,
    CONSTRAINT Fk_Suc FOREIGN KEY (Id_Suc) REFERENCES Venta.Sucursal(Id_Suc),
    CONSTRAINT CK_Leg CHECK (Legajo BETWEEN 100000 AND 999999),
    CONSTRAINT CK_Tur CHECK (Turno IN ('TM','TT','JC','TN')), 
    CONSTRAINT CK_Cargo CHECK (Cargo IN ('Cajero','Supervisor','Gerente de sucursal'))
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
--    Tipo_Cliente VARCHAR(10) --> ya esta en cliente
--    Tipo_Factura CHAR(1) --> Ya esta en factura
--	  Agrego MontoTotal (se calcula con subtotales)

--cambios 
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

    --Id_Fac INT not null, --> no me hacen falta, esa info ya la tengo en venta_Registrada
    --Id_Cli INT not null,
	--Id_MP INT not null,
	--	CONSTRAINT CK_Subtotal CHECK (Subtotal > 0), creo que no vale la pena, ya se calucla multiplicando valores mayores a 0


CREATE TABLE Venta.Nota_De_Credito (
    Id INT IDENTITY(1,1), -- lo hice INT porque no es el mismo ID que factura
    Fecha DATE NOT NULL,
    Monto INT NOT NULL,
    Id_Fac INT NOT NULL,
    CONSTRAINT FK_Fac_Nota FOREIGN KEY (Id_Fac) REFERENCES Venta.Factura(Id) ON DELETE CASCADE,
	CONSTRAINT PK_IdNota PRIMARY KEY (Id, Id_Fac) -- Por ser debil deberia tener una Pk compuesta
);


/*Falta:
-unificar factura y venta LISTO
-Conectar con output detalle_venta y venta_registrada CREO QUE LISTO
- Si un empleado cambia de sucrursal, que el empleado siga vinculado a las ventas que realizo
-Duplicados clientes  y sucursal
- Registrar empleados que generan�la�compra*/

-- Grupo:06
-- Chac�n Mirko Facundo - 43444942
-- Giannni P�rez, Gabriel Idelmar- 45614379
-- Nielsen, Tomas Agust�n - 41326589
-- Silva , Pablo Ismael - 31641736
-------------------------------
-- Fecha de Entrega: 28/02/2025
-- Bases de Datos Aplicadas

/*Entrega 3
Luego de decidirse por un motor de base de datos relacional, lleg� el momento de generar la
base de datos. En esta oportunidad utilizar�n SQL Server.
Deber� instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle
las configuraciones aplicadas (ubicaci�n de archivos, memoria asignada, seguridad, puertos,
etc.) en un documento como el que le entregar�a al DBA.
Incluya tambi�n un DER con el dise�o de la base de datos. Deben aparecer correctamente
las relaciones y las claves, pero el formato queda a su criterio.
Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deber� entregar
un archivo .sql con el script completo de creaci�n (debe funcionar si se lo ejecuta �tal cual� es
entregado en una sola ejecuci�n). Incluya comentarios para indicar qu� hace cada m�dulo
de c�digo.
Genere store procedures para manejar la inserci�n, modificado, borrado (si corresponde,
tambi�n debe decidir si determinadas entidades solo admitir�n borrado l�gico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con �SP�.
Algunas operaciones implicar�n store procedures que involucran varias tablas, uso de
transacciones, etc. Puede que incluso realicen ciertas operaciones mediante varios SPs.
Aseg�rense de que los comentarios que acompa�en al c�digo lo expliquen.
Genere esquemas para organizar de forma l�gica los componentes del sistema y aplique esto
en la creaci�n de objetos. NO use el esquema �dbo�.
Todos los SP creados deben estar acompa�ados de juegos de prueba. Se espera que
realicen validaciones b�sicas en los SP (p/e cantidad mayor a cero, CUIT v�lido, etc.) y que
en los juegos de prueba demuestren la correcta aplicaci�n de las validaciones.
Las pruebas deben realizarse en un script separado, donde con comentarios se indique en
cada caso el resultado esperado */
-- Creacion de la BDD --
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
    Nombre  VARBINARY(256) NOT NULL,
    Apellido  VARBINARY(256) NOT NULL,
    DNI  VARBINARY(256) NOT NULL,
    Direccion  VARBINARY(256),
    Email_Personal VARBINARY(256),
    Email_Empresa VARBINARY(256),
	Cargo VARCHAR(20),
    Turno CHAR(2),
	CUIL VARBINARY(256),
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
	NumeroFactura CHAR(11) UNIQUE,
	TipoFactura CHAR(1),
	Monto DECIMAL(17,2),
	EstadoPago VARCHAR(17) DEFAULT 'Pagado',
    Fecha DATE,
    Hora TIME,
	Estado BIT NOT NULL DEFAULT 1, -- para darle de baja
    Id_Emp INT,
    Id_Cli INT,
    Id_MP INT,
	CONSTRAINT CK_TipoFactura CHECK(TipoFactura IN ('A','B','C')),
    CONSTRAINT FK_Emp FOREIGN KEY (Id_Emp) REFERENCES Persona.Empleado(Legajo),
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
    Id INT IDENTITY(1,1) primary key, 
    Fecha DATE NOT NULL,
    Monto Decimal(17,2) NOT NULL,
    Id_Venta INT NOT NULL unique,
    CONSTRAINT FK_Venta FOREIGN KEY (Id_Venta) REFERENCES Venta.Venta_Registrada(Id) ON DELETE CASCADE,
);

CREATE TYPE Venta.Detalle_Venta_Tipo AS TABLE (
    IdProd INT NOT NULL,
	Cantidad INT NOT NULL
);



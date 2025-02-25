-- Grupo:06
-- Chacón Mirko Facundo - 43444942
-- Giannni Pérez, Gabriel Idelmar- 45614379
-- Nielsen, Tomas Agustín - 41326589
-- Silva , Pablo Ismael - 31641736
-------------------------------

Use Com1353G06

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

END;
GO


create or alter procedure Venta.Baja_Sucursal --Dar de baja la sucursal
@Dir varchar (50)
AS
BEGIN
IF exists (select 1 from Venta.Sucursal where Direccion=@Dir)
	BEGIN
	update Venta.Sucursal
	set  Estado = 0
	Where Direccion = @Dir and Estado = 1 
	END
	ELSE
	BEGIN
	RAISERROR('ERROR EN EL BORRADO LOGICO POR LA DIRECCION: %s',10,2,@Dir);
	END
END;
GO


CREATE OR ALTER PROCEDURE Venta.Modificar_Sucursal
@Legajo INT,
@NuevaDireccion VARCHAR(50),
@NuevoCargo VARCHAR(20),
@NuevoEmail_Personal VARCHAR(100),
@NuevoEmail_Empresa VARCHAR(100),
@NuevoTurno CHAR(2),
@NuevoId_Suc int
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Persona.Empleado WHERE Legajo = @Legajo)
	BEGIN
		UPDATE Persona.Empleado
		SET Direccion = @NuevaDireccion,
		Cargo = @NuevoCargo ,
		Email_Personal = @NuevoEmail_Personal,
		Email_Empresa = @NuevoEmail_Empresa ,
		Turno = @NuevoTurno,
		Id_Suc = @NuevoId_Suc
		WHERE Legajo = @Legajo;

		IF @@ROWCOUNT > 0
		BEGIN
			DECLARE @texto NVARCHAR(250);
			SET @texto =CONCAT('Se han actualizado los datos del empleado con legajo: ', @Legajo);
			--EXEC registros.insertarLog @modulo, @texto;
		END
	END
END;
GO

drop table Persona.Cliente






-- Para la tabla Cliente --
create or alter procedure Persona.Insertar_Cliente --Insertar datos de clientes
@Nombre varchar(30),
@Genero CHAR(6),
@Tipo CHAR(11),
@DNI int
AS
BEGIN

	IF NOT EXISTS (SELECT 1 FROM Persona.Cliente WHERE DNI = @DNI)
    BEGIN
        -- Insertar solo si el DNI no existe
        INSERT INTO Persona.Cliente (Nombre, Genero, Tipo, DNI)
        VALUES (@Nombre, @Genero, @Tipo, @DNI);
    END
    ELSE
    BEGIN
        -- Si el DNI ya existe, lanzar un error
        RAISERROR('El DNI %d ya está registrado en el sistema', 16, 1, @DNI);
    END
	   
END;
GO


CREATE OR ALTER PROCEDURE Persona.Eliminar_Cliente --Dar de baja al cliente
@DNI int
AS
BEGIN
IF EXISTS (Select 1 From Persona.Cliente Where DNI = @DNI)
	BEGIN
	update Persona.Cliente
	set Baja = getdate()
	where DNI = @DNI and baja is null
	END
	ElSE
	BEGIN
	RAISERROR('No se puede dar de baja al Cliente con Id: %d (No existe o ya fue dado de baja)',10,2,@DNI)
	END

END;
GO


-- Para la tabla Medio De Pago -- 

CREATE OR ALTER PROCEDURE Venta.Insertar_Medio_De_Pago
@Descripcion CHAR (21)
AS
BEGIN 
	SET @Descripcion = UPPER(@Descripcion);

	IF @Descripcion = 'CREDIT CARD'
        SET @Descripcion = 'TARJETA DE CREDITO';
    ELSE IF @Descripcion = 'CASH'
        SET @Descripcion = 'EFECTIVO';
    ELSE IF @Descripcion = 'EWALLET'
        SET @Descripcion = 'BILLETERA ELECTRONICA';

IF NOT EXISTS (select 1 from Venta.Medio_Pago where Descripcion = @Descripcion and baja is null)
BEGIN
	insert into Venta.Medio_Pago (Descripcion)
	Values(@Descripcion);
	END
	ELSE
	BEGIN
		RAISERROR ('Ya existe el medio de pago %s',10,2,@Descripcion);
	END

END;
GO

CREATE OR ALTER PROCEDURE Venta.Baja_Medio_De_Pago
@Descripcion CHAR(21)
AS
BEGIN
	SET @Descripcion = UPPER(@Descripcion);
	IF @Descripcion = 'CREDIT CARD'
        SET @Descripcion = 'TARJETA DE CREDITO';
    ELSE IF @Descripcion = 'CASH'
        SET @Descripcion = 'EFECTIVO';
    ELSE IF @Descripcion = 'EWALLET'
        SET @Descripcion = 'BILLETERA ELECTRONICA';
IF EXISTS (select 1 from Venta.Medio_Pago where Descripcion = @Descripcion and baja is null)
	BEGIN

	update Venta.Medio_Pago
	set Baja = getdate()
	where Descripcion = @Descripcion
	END
ELSE
	BEGIN
	RAISERROR ('No se puede dar de baja el medio de pago %d',10,2,@Descripcion);
	END

END;
GO

-- Para la tabla de Factura

CREATE OR ALTER PROCEDURE Venta.Insertar_Factura
@NumeroFactura CHAR(11),
@Tipo CHAR (1),
@Monto Decimal (10,2)
AS
BEGIN
IF NOT EXISTS (Select 1 From Venta.Factura Where NumeroFactura = @NumeroFactura)
	BEGIN
	insert Venta.Factura (NumeroFactura,Tipo,MontoFactura)
	values (@NumeroFactura, @Tipo, @Monto);
	END
	ELSE
		BEGIN
		RAISERROR ('No se puede insertar datos con ese numero %s',10,2,@NumeroFactura);
		END
END;
GO

--Borado logico de factura

CREATE or ALTER PROCEDURE Venta.Eliminar_Factura
@NumeroFactura CHAR(11)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Venta.Factura where Estado = 0 and NumeroFactura = @NumeroFactura)
	BEGIN
		RAISERROR('Factura ya eliminada',16,1);
		RETURN;
	END

	DECLARE @modulo NVARCHAR(50) = 'Factura';
	UPDATE Venta.Factura
	SET Estado = 0
	WHERE NumeroFactura = @NumeroFactura;

	IF @@ROWCOUNT > 0
	BEGIN
		DECLARE @texto NVARCHAR(250);
		SET @texto =CONCAT('Se ha borrado logicamente la factura con el ID : ', @NumeroFactura);
		--EXEC registros.insertarLog @modulo, @texto;
	END
END;
GO


-- Cambiar Estado de la factura.

CREATE OR ALTER PROCEDURE Venta.Pagar_Factura
@NumeroFactura CHAR(11)
AS
BEGIN
IF EXISTS (Select 1 From Venta.Factura Where NumeroFactura = @NumeroFactura)
	BEGIN
	UPDATE Venta.Factura
	SET EstadoPago = 'Pagada'
	Where NumeroFactura = @NumeroFactura and Estado ='Pendiente de pago'
	END
	ELSE
		BEGIN
		RAISERROR('No fue posible encontrar la Id :%s',10,2,@NumeroFactura);
		END
END;
GO

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
END;
GO

-- Sirve para dar de baja una categoria.

CREATE OR ALTER PROCEDURE Articulo.Baja_Categoria
@Descripcion varchar(30)
AS
BEGIN
IF EXISTS (Select 1 From Articulo.Categoria Where Descripcion = @Descripcion and Estado = 1)
	BEGIN
	UPDATE Articulo.Categoria
	SET Estado = 0
	Where Descripcion = @Descripcion
	END
	ELSE
		BEGIN
		RAISERROR ('El Producto %s no se encuentra en el sistema o fue dado de baja',10,2,@Descripcion);
		END

END;
GO


-- Para tabla Producto

CREATE OR ALTER PROCEDURE Articulo.Insertar_Producto
@NombreProd varchar(20),
@Fecha_hora Datetime,
@Precio Numeric (7,2),
@Proveedor varchar(40),
@Referencia_Unit Decimal (10,2),
@Referencia CHAR (2),
@Id_Cat int
AS
BEGIN
IF NOT EXISTS (Select 1 From Articulo.Producto Where Nombre = @NombreProd)
	BEGIN
	insert Articulo.Producto (Nombre,Fecha_Hora, Precio, Proveedor, Referencia_Unit, Referencia, Id_Cat)
	values (@NombreProd, @Fecha_Hora, @Precio, @Proveedor, @Referencia_Unit, @Referencia, @Id_Cat);
	END
	ELSE
		BEGIN
		RAISERROR('No fue posible insertar el producto %s',10,2,@NombreProd);
		END
END;
GO

CREATE OR ALTER PROCEDURE Articulo.Baja_Producto -- Borrado Logico del producto.
@Nombre VARCHAR(20)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Articulo.Producto WHERE Nombre = @Nombre AND Estado = 1)
    UPDATE Articulo.Producto
    SET Estado = 0
    WHERE Nombre = @Nombre AND Estado = 1;
END;
GO


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
@Cuil varchar(13),
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
END;
GO

--Modificacion de Empleado

CREATE OR ALTER PROCEDURE Persona.Modificar_Empleado
@Legajo INT,
@NuevaDireccion VARCHAR(50),
@NuevoCargo VARCHAR(20),
@NuevoEmail_Personal VARCHAR(100),
@NuevoEmail_Empresa VARCHAR(100),
@NuevoTurno CHAR(2),
@NuevoId_Suc int
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Persona.Empleado WHERE Legajo = @Legajo)
	BEGIN
		UPDATE Persona.Empleado
		SET Direccion = @NuevaDireccion,
		Cargo = @NuevoCargo ,
		Email_Personal = @NuevoEmail_Personal,
		Email_Empresa = @NuevoEmail_Empresa ,
		Turno = @NuevoTurno,
		Id_Suc = @NuevoId_Suc
		WHERE Legajo = @Legajo;

		IF @@ROWCOUNT > 0
		BEGIN
			DECLARE @texto NVARCHAR(250);
			SET @texto =CONCAT('Se han actualizado los datos del empleado con legajo: ', @Legajo);
			--EXEC registros.insertarLog @modulo, @texto;
		END
	END
END;
GO

-- Borrado Logico
CREATE OR ALTER PROCEDURE Persona.Baja_Empleado 
@Legajo int
AS
BEGIN
IF EXISTS (Select 1 From Persona.Empleado Where Legajo = @Legajo and Estado = 1)
	BEGIN
	UPDATE Persona.Empleado
	SET Estado = 0
	Where Estado = 1
	END
	ELSE 
		BEGIN
		RAISERROR ('No se encontro el legajo: %d para dar de baja al Empleado',10,2,@Legajo);
		END
END;
GO
	

-- Para tabla Venta_Registrada

CREATE OR ALTER PROCEDURE Venta.Insertar_VRegistrada
@Id_Pago bigint,
@Fecha DATE,
@Hora TIME,
@MontoTotal Decimal(10,2),
@Id_Emp int,
@Id_MP int,
@Id_Cli int,
@Id_Fac int
AS
BEGIN
IF NOT EXISTS (Select 1 From Venta.Venta_Registrada Where Id_Pago = @Id_Pago)
	BEGIN
		insert Venta.Venta_Registrada (Id_Pago,Fecha,Hora,MontoTotal,Id_Emp,Id_Cli,Id_MP,Id_Fac)
		values (@Id_Pago,@Fecha,@Hora,@MontoTotal,@Id_Emp,@Id_Cli,@Id_MP,@Id_Fac);
	END
	ELSE
		BEGIN
			RAISERROR('Ya se uso ese Id: %s',10,2,@Id_Pago);
		END
END;
GO

-- Borrado logico de una venta registrada

CREATE OR ALTER PROCEDURE Venta.Eliminar_VRegistrada
@Id_Pago bigint
AS
BEGIN
	IF EXISTS(Select 1 From Venta.Venta_Registrada where Id_Pago = @Id_Pago and Estado = 0)
	BEGIN
		RAISERROR('Venta ya eliminada',16,1);	
		RETURN;
	END

	DECLARE @modulo NVARCHAR(50) = '';
	UPDATE Venta.Venta_Registrada
	SET Estado = 0
	WHERE Id_Pago = @Id_Pago;

	IF @@ROWCOUNT > 0
	BEGIN
		DECLARE @texto NVARCHAR(250);
		SET @texto =CONCAT('Se ha borrado logicamente la venta con el ID : ', @Id_Pago);
		--EXEC registros.insertarLog @modulo, @texto;
	END
END;
GO

		
-- Para la tabla Detalle_Venta

CREATE OR ALTER PROCEDURE Venta.Insertar_Detalle_Venta
@Id_Pago BigInt,
@Cantidad int,
@PrecioUnit Decimal (10,2),
@Subtotal Decimal (10,2),
@Id_Prod int

AS
BEGIN
IF NOT EXISTS (Select 1 From Venta.Detalle_Venta Where Id_Pago = @Id_Pago )
	BEGIN
	insert Venta.Detalle_Venta (Id_Pago,Cantidad,PrecioUnitario,Subtotal,Id_Prod)
	values (@Id_Pago,@Cantidad,@PrecioUnit,@Subtotal,@Id_Prod);
	END
	ELSE 
		BEGIN
		RAISERROR('Id en uso: %d',10,2,@Id_Pago);
		END
END;
GO


--Eliminar Detalle de venta

CREATE OR ALTER PROCEDURE Venta.Baja_Detalle_Venta
@Id_ven BigInt
AS
BEGIN
IF EXISTS (Select 1 From Venta.Detalle_Venta Where Id_Pago = @Id_Ven)
	BEGIN
	Delete Venta.Detalle_Venta
	END
	ELSE
		BEGIN
		RAISERROR('No se pudo dar de baja el Detalle de venta con Id: %d',10,2,@Id_ven);
		END
END;
GO




											--casos de pruebas--

--Insercion de datos en tabla Cliente -- Esta bien
exec Persona.Insertar_Cliente 'Juan Perez','Female','Member',45124919 

exec Persona.Insertar_Cliente 'Lucas Mendez','Male','Normal',42019283

exec Persona.Insertar_Cliente 'Nicolas Perez','Male', 'Normal', 45124919 --Da Errror DNI repetido.

exec Persona.Eliminar_Cliente 45124919 --Elimino un Cliente dandolo de baja con la fecha actual.


-- Insercion de datos Medio de Pago --Esta bien
Select *
From Venta.Medio_Pago
Exec Venta.Insertar_Medio_De_Pago 'Credit Card'; --Ingreso un metodo de pago como ejemplo.

Exec Venta.Insertar_Medio_De_Pago 'Credit Card'; -- Si ingreso el mismo metodo de pago no me va a dejar, ya que son unicos.
Exec Venta.Insertar_Medio_De_Pago 'Cash'; --Ingreso Cash debe aparecer "Efectivo".

Exec Venta.Insertar_Medio_De_Pago 'Ewallet' -- Ingreso otro ejemplo.

Exec Venta.Baja_Medio_De_Pago 'Tarjeta de Credito' -- Dar de baja a un metodo de pago.

Exec Venta.Baja_Medio_De_Pago 'CASH' -- Da de baja al metodo de pago "Efectivo"



-- Insercion de datos Factura --esta bien

Exec Venta.Insertar_Factura '750-67-8428','A', 250.5 -- Inserto un ejemplo de Factura.

Exec Venta.Eliminar_Factura '750-67-8428' -- Borrado Logico de Factura.


-- Insercion de datos en Sucursal --esta bien

Exec Venta.Insertar_Sucursal  'San Justo','Av. Brig. Gral. Juan Manuel de Rosas 3634, B1754 San Justo, Provincia de Buenos Aires','5555-5551',
'L a V 8 a. m.–9 p. m.S y D 9 a. m.-8 p. m.' -- Inserto un Ejemplo de Sucursal.

Exec Venta.Baja_Sucursal 'Av. Brig. Gral. Juan Manuel de Rosas 3634, B1754 San Justo, Provincia de Buenos Aires' --Dar de baja la sucursal.


-- Insercion de datos en Categoria - esta bien


Exec Articulo.Insertar_Categoria 'Agua','Almacen'  --Agrego un ejemplo en la tabla Categoria.


Exec Articulo.Baja_Categoria 'Agua'


-- Insercion de datos de Producto -Esta bien

Exec Articulo.Insertar_Producto 'Agua','20150210',250,'Distribuidor',15,'KG',1 -- Inserto como ejemplo en la tabla de Producto.

Exec Articulo.Baja_Producto 'Agua' --Dar de baja el producto.

-- Insercion de datos de Empleado --esta bien
--Esta bien
Exec Persona.Insertar_Empleado 257097,'Alejandro','Gonzalez',46393021,'Avenida siempre viva 123','Cajero','AleGon@gmail.com','AleGon@SuperA.com','20-46393021-3','TM',1 --Inserto un empleado.

Exec Persona.Modificar_Empleado 257097,'Calle falsa 123','Supervisor','AleGon@gmail.com','AleGon@SuperA.com','JC',1 --Modifico los datos del empleado.

Exec Persona.Baja_Empleado 257097  -- Borrado Logico da de baja al empleado


-- Insercion de datos de prueba Venta Registrada 

Exec Venta.Insertar_VRegistrada 0000003100099475144530, '2020-02-20','0005',1500,257097,1,1,1

Exec Venta.Eliminar_VRegistrada 0000003100099475144530


-- Insercion de datos de prueba Detalle Venta


Exec Venta.Insertar_Detalle_Venta 0000003100099475144530,25,5,500.25,1 --Inserta un detalle de venta como ejemplo.

Exec Venta.Baja_Detalle_Venta 0000003100099475144530 --Da de baja un Detalle de Venta



-- Importacion De Archivos


-- Grupo:06
-- Chacón Mirko Facundo - 43444942
-- Giannni Pérez, Gabriel Idelmar- 45614379
-- Nielsen, Tomas Agustín - 41326589
-- Silva , Pablo Ismael - 31641736
-------------------------------
-- Fecha de Entrega: 28/02/2025
-- Bases de Datos Aplicadas


Use Com1353G06;
Go
						----- Creacion SP ------
-- Para la tabla Sucursal

create or alter procedure Venta.Insertar_Sucursal --Insertar datos en Sucursal
@Localidad_Ori varchar(40),
@Localidad_Real varchar(40),
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
		insert into Venta.Sucursal (Direccion,Horario,Localidad_ori,Localidad_Real,Telefono)
		values (@Direccion,@Horario,@Localidad_ori,@Localidad_Real,@Telefono);
	END

END;
GO

create or alter procedure Venta.Baja_Sucursal --Dar de baja la sucursal
@Id_Suc INT
AS
BEGIN
IF exists (select 1 from Venta.Sucursal where Id_Suc = @Id_Suc and Estado = 1)
	BEGIN
	update Venta.Sucursal
	set  Estado = 0
	END

	ELSE

	BEGIN
		DECLARE @Mensaje VARCHAR(100)
		SET @Mensaje = CONCAT('La sucursal con ID ', @Id_Suc, ' no existe o ya fue dado de baja');
		RAISERROR(@Mensaje, 10, 2);
	END
END;
GO

CREATE OR ALTER PROCEDURE Venta.Modificar_Sucursal
@Id_suc int,
@NuevaLocalidad_Ori varchar(40),
@NuevaLocalidad_Real VARCHAR(40),
@Direccion varchar(150),
@Telefono CHAR(9),
@Horario varchar(50)
AS
BEGIN
IF EXISTS (Select 1 From Venta.Sucursal Where Id_Suc = @Id_Suc and Estado = 1)
BEGIN
	UPDATE Venta.Sucursal
	SET Localidad_Ori = @NuevaLocalidad_Ori,
	Localidad_Real = @NuevaLocalidad_Real,
	Direccion = @Direccion,
	Telefono = @Telefono,
	Horario = @Horario
	Where Id_Suc = @Id_SUC and Estado = 1
END

ELSE
BEGIN
RAISERROR('No se encontro el Id en el sistema o fue dado de baja',10,2); 
END
END;
GO

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
@Nombre VARCHAR (30)
AS
BEGIN 
	SET @NOMBRE = UPPER(@NOMBRE);
	
	IF @NOMBRE = 'TARJETA DE CREDITO'
        SET @NOMBRE = 'CREDIT CARD';
    ELSE IF @NOMBRE = 'EFECTIVO'
        SET @NOMBRE = 'CASH'; 
    ELSE IF @NOMBRE = 'BILLETERA ELECTRONICA'
        SET @NOMBRE = 'EWALLET'; 

IF NOT EXISTS (select 1 from Venta.Medio_Pago where NOMBRE = @NOMBRE and baja is null)
BEGIN
	insert into Venta.Medio_Pago (NOMBRE)
	Values(@NOMBRE);
	END
	ELSE
	BEGIN
		RAISERROR ('Ya existe el medio de pago %s',10,2,@NOMBRE);
	END

END;
GO

CREATE OR ALTER PROCEDURE Venta.Baja_Medio_De_Pago
@NOMBRE VARCHAR(30)
AS
BEGIN
	SET @NOMBRE = UPPER(@NOMBRE);
	IF @NOMBRE = 'TARJETA DE CREDITO'
        SET @NOMBRE = 'CREDIT CARD';
    ELSE IF @NOMBRE = 'EFECTIVO'
        SET @NOMBRE = 'CASH'; 
    ELSE IF @NOMBRE = 'BILLETERA ELECTRONICA'
        SET @NOMBRE = 'EWALLET'; 
IF EXISTS (select 1 from Venta.Medio_Pago where NOMBRE = @NOMBRE and baja is null)
	BEGIN

	update Venta.Medio_Pago
	set Baja = getdate()
	where NOMBRE = @NOMBRE
	END
ELSE
	BEGIN
	RAISERROR ('No se puede dar de baja el medio de pago %d',10,2,@NOMBRE);
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
@NombreProd nvarchar(100),
@Fecha_hora Datetime,
@Precio decimal (20,2),
@Proveedor varchar(40),
@Referencia_Unit Decimal (20,2),
@Referencia VARCHAR (10),
@Id_Cat int
AS
BEGIN
IF NOT EXISTS (Select 1 From Articulo.Producto Where Nombre = @NombreProd)
	BEGIN
	insert Articulo.Producto (Nombre,Fecha_Hora, Precio_Actual, Proveedor, Precio_Referencia, Unidad_Referencia, Id_Cat)
	values (@NombreProd, @Fecha_Hora, @Precio, @Proveedor, @Referencia_Unit, @Referencia, @Id_Cat);
	END
	ELSE
		BEGIN
		RAISERROR('No fue posible insertar el producto %s',10,2,@NombreProd);
		END
END;
GO

CREATE OR ALTER PROCEDURE Articulo.Baja_Producto -- Borrado Logico del producto.
@Nombre nVARCHAR(100)
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
@Apellido VARCHAR(30),
@DNI int,
@Direccion VARCHAR(100),
@Cargo VARCHAR(20),
@Email_Personal VARCHAR(100),
@Email_Empresa VARCHAR(100),
@Turno CHAR(2),
@CUIL BIGINT,
@Id_Suc int,
@FraseClave NVARCHAR(128)

AS
BEGIN
IF NOT EXISTS (Select 1 From Persona.Empleado Where Legajo = @Legajo)
	BEGIN
	insert Persona.Empleado (Legajo,Nombre,Apellido,DNI,Direccion,Cargo,Email_Personal,Email_Empresa,Turno,CUIL,Id_Suc)
	values (
			@Legajo,
            EncryptByPassPhrase(@FraseClave, @Nombre),
            EncryptByPassPhrase(@FraseClave, @Apellido),
            EncryptByPassPhrase(@FraseClave, CAST(@DNI as VARCHAR(20))),
            EncryptByPassPhrase(@FraseClave, @Direccion),
            @Cargo,  -- No encriptamos Cargo porque no es sensible
            EncryptByPassPhrase(@FraseClave, @Email_Personal),
            EncryptByPassPhrase(@FraseClave, @Email_Empresa),
			@Turno,
			EncryptByPassPhrase(@FraseClave, CAST(@CUIL as VARCHAR(25))),
            @Id_Suc)
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
@NuevoId_Suc int,
@FraseClave NVARCHAR(128)

AS
BEGIN
	IF EXISTS (SELECT 1 FROM Persona.Empleado WHERE Legajo = @Legajo)
	BEGIN
		UPDATE Persona.Empleado
		SET Direccion = EncryptByPassPhrase(@FraseClave, @NuevaDireccion),
		Cargo = @NuevoCargo ,
		Email_Personal = EncryptByPassPhrase(@FraseClave, @NuevoEmail_Personal),
		Email_Empresa = EncryptByPassPhrase(@FraseClave, @NuevoEmail_Empresa),
		Turno = @NuevoTurno,
		Id_Suc = @NuevoId_Suc
		WHERE Legajo = @Legajo;
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
	

-- Para ingresar una venta registrada con su factura

CREATE OR ALTER PROCEDURE Venta.Insertar_VRegistrada
@IdPago varchar(30) = NULL,
@NumeroFactura CHAR(11),
@TipoFactura CHAR(1) = NULL,
@Monto DECIMAL(17,2) = NULL,
@Fecha DATE =NULL,
@Hora TIME = NULL,
@Id_Emp int = NULL,
@Id_Cli int = NULL,
@Id_MP int = NULL,
@Id_Venta int OUTPUT --me devuelve el ID venta para luego usarlo en detalle venta

AS
BEGIN
IF NOT EXISTS (Select 1 From Venta.Venta_Registrada Where NumeroFactura = @NumeroFactura)
	BEGIN
		insert Venta.Venta_Registrada (IdPago,NumeroFactura,TipoFactura,Monto,Fecha,Hora,Id_Emp,Id_Cli,Id_MP)
		values (@IdPago,@NumeroFactura,@TipoFactura,@Monto,@Fecha,@Hora,@Id_Emp,@Id_Cli,@Id_MP);
		set @Id_Venta = SCOPE_IDENTITY();
	END
	ELSE
		BEGIN
			set @Id_Venta = 
			(SELECT v.Id
			FROM venta.Venta_Registrada v
			where v.NumeroFactura = @NumeroFactura)
			RAISERROR('ID de venta ya generado: %d',10,2,@Id_Venta);
		END
END;
GO

-- Borrado logico de una venta registrada por ID Factura

CREATE OR ALTER PROCEDURE Venta.Eliminar_VRegistrada
@NumeroFactura CHAR(11)
AS
BEGIN
	IF EXISTS(Select 1 From Venta.Venta_Registrada where NumeroFactura = @NumeroFactura and Estado = 0)
	BEGIN
		RAISERROR('Venta ya eliminada',16,1);	
		RETURN;
	END

	UPDATE Venta.Venta_Registrada
	SET Estado = 0
	WHERE NumeroFactura = @NumeroFactura;

	IF @@ROWCOUNT > 0
	BEGIN
		DECLARE @texto NVARCHAR(250);
		SET @texto =CONCAT('Se ha borrado logicamente la venta con el ID :', @NumeroFactura);
		PRINT @texto;
	END
END;
GO

		
-- Para la tabla Detalle_Venta

CREATE OR ALTER PROCEDURE Venta.Insertar_Detalle_Venta
@Cantidad int,
@PrecioUnit Decimal (17,2),
@Subtotal Decimal (17,2),
@Id_Prod int,
@Id_Venta int

AS
BEGIN
IF NOT EXISTS (Select 1 From Venta.Detalle_Venta Where Id_Prod = @Id_Prod and Id_Venta = @Id_venta)
	BEGIN
	insert Venta.Detalle_Venta (Cantidad,PrecioUnitario,Subtotal,Id_Prod,Id_Venta)
	values (@Cantidad,@PrecioUnit,@Subtotal,@Id_Prod,@id_venta);
	END
	ELSE 
		BEGIN
		RAISERROR('Id de producto en uso: %d',10,2,@Id_Prod);
		END
END;
GO


--Eliminar Detalle de venta

CREATE OR ALTER PROCEDURE Venta.Baja_Detalle_Venta
@Id_venta int,
@Id_Prod int
AS
BEGIN
IF EXISTS (Select 1 From Venta.Detalle_Venta Where Id_venta = @Id_Venta and id_prod = @id_prod)
	BEGIN
	Delete Venta.Detalle_Venta
	END
	ELSE
		BEGIN
		RAISERROR('No se pudo dar de baja el Detalle de venta con Id de producto: %d',10,2,@Id_Prod);
		END
END;
GO








-- Grupo:06
-- Chacón Mirko Facundo - 43444942
-- Giannni Pérez, Gabriel Idelmar- 45614379
-- Nielsen, Tomas Agustín - 41326589
-- Silva , Pablo Ismael - 31641736
-------------------------------
-- Fecha de Entrega: 28/02/2025
-- Bases de Datos Aplicadas

Use Com1353G06;			
go
											--casos de pruebas--

--Insercion de datos en tabla Cliente 

exec Persona.Insertar_Cliente 'Juan Perez','Female','Member',45124919;
Go

exec Persona.Insertar_Cliente 'Lucas Mendez','Male','Normal',42019283;
Go

exec Persona.Insertar_Cliente 'Nicolas Perez','Male', 'Normal', 45124919; --Da Errror DNI repetido.
Go

exec Persona.Eliminar_Cliente 45124919; --Elimino un Cliente dandolo de baja con la fecha actual.
Go

select * from Persona.Empleado

-- Insercion de datos Medio de Pago 

Exec Venta.Insertar_Medio_De_Pago 'Credit Card'; --Ingreso un metodo de pago como ejemplo.
Go

Exec Venta.Insertar_Medio_De_Pago 'Credit Card'; -- Si ingreso el mismo metodo de pago no me va a dejar, ya que son unicos.
Go

Exec Venta.Insertar_Medio_De_Pago 'Cash'; --Otro ejemplo.
Go

Exec Venta.Insertar_Medio_De_Pago 'Ewallet'; -- Ingreso otro ejemplo.
Go

Exec Venta.Baja_Medio_De_Pago 'Tarjeta de Credito'; -- Dar de baja a un metodo de pago.
Go

Exec Venta.Baja_Medio_De_Pago 'CASH'; -- Da de baja al metodo de pago "Efectivo"
Go



-- Insercion de datos en Sucursal 

Exec Venta.Insertar_Sucursal  'Yangon','San Justo','Av. Brig. Gral. Juan Manuel de Rosas 3634, B1754 San Justo, Provincia de Buenos Aires','5555-5551',
'L a V 8 a. m.–9 p. m.S y D 9 a. m.-8 p. m.'; -- Inserto un Ejemplo de Sucursal.
Go

--Modifica sucursal
Exec Venta.Modificar_Sucursal 4,'Avenida Siempre Viva','Calle falsa 123','Direccion Falsa de prueba','2342-1232','M a J 7 p.m - 11 p.m'; 
Go

Exec Venta.Baja_Sucursal 4; --Dar de baja la sucursal con borrado logico.
Go

Exec Venta.Baja_Sucursal 4; --Detecta que ya fue dado de baja y no lo permite.
Go

Exec Venta.Baja_Sucursal 10; --Detecta que no existe la sucursal
Go
	
-- Insercion de datos en Categoria 

Exec Articulo.Insertar_Categoria 'Agua','Almacen' --Agrego un ejemplo en la tabla Categoria.
Go

Exec Articulo.Baja_Categoria 'Agua';  -- Dar de baja la categoria.
Go

select * from Articulo.Producto
-- Insercion de datos de Producto 

Exec Articulo.Insertar_Producto 'Agua','20150210',250,'Distribuidor',15,'KG',1; -- Inserto como ejemplo en la tabla de Producto.
Go

--Producto ya insertado
Exec Articulo.Insertar_Producto 'Agua','20150210',250,'Distribuidor',15,'KG',1; -- Inserto como ejemplo en la tabla de Producto.
Go

Exec Articulo.Baja_Producto 'Agua'; --Dar de baja el producto.
Go

-- Insercion de datos de Empleado 

Exec Persona.Insertar_Empleado 257097,'Alejandro','Gonzalez',46393021,
'Avenida siempre viva 123','Cajero','AleGon@gmail.com','AleGon@SuperA.com','TM',20463930213,2,'clave'; --Inserto un empleado.
Go

-- Vemos que empleado 257020 realizo ventas en Sucursal 2
select * from Venta.Venta_Registrada
WHERE Id_Emp = 257020

-- Modificamos sucursal del empleado 257020 a la sucursal 1
--Modificamos la sucursal de trabajo del empleado pero la sucursal sigue vinculada a la venta registrada
Exec Persona.Modificar_Empleado 257020,'Calle falsa 123','Supervisor','AleGon@gmail.com','AleGon@SuperA.com','JC',1, 'clave'; --Modifico los datos del empleado.
Go 

--Insertamos una venta registrada por el empleado 257020

--Declaro mi tabla variable para insertar los productos
DECLARE @Detalle Venta.Detalle_Venta_Tipo
-- Insertamos productos de prueba en la tabla de tipo
INSERT INTO @Detalle (IdProd, Cantidad)
VALUES
    (5,2),  -- Producto 1,  Cantidad 2
    (9,3),   -- Producto 2, Cantidad 3
    (10,5);   -- Producto 3, Cantidad 5

Exec Venta.Insertar_VRegistrada 
@IdPago = 0000003100099475144530, 
@NumeroFactura = '20957-34799',
@TipoFactura = 'A',
@Fecha = '2020-02-20',
@Hora = '20:20',
@Id_Emp = 257020,
@Id_Cli = 1,
@Id_MP = 1,
@Detalle = @Detalle

go

---Observamos que ahora esta se registra en sucursal 1

select * from Venta.Venta_Registrada
WHERE Id_Emp = 257020 and Id_Suc = 1


Exec Persona.Baja_Empleado 257097; -- Borrado Logico da de baja al empleado
Go



--Insertar venta registrada con sus detalles de venta--

--Declaro mi tabla variable para insertar los productos
DECLARE @Detalle Venta.Detalle_Venta_Tipo

-- Insertamos productos de prueba en la tabla de tipo
INSERT INTO @Detalle (IdProd, Cantidad)
VALUES
    (5,2),  -- Producto 1,  Cantidad 2
    (9,3),   -- Producto 2, Cantidad 3
    (10,5);   -- Producto 3, Cantidad 5

Exec Venta.Insertar_VRegistrada 
@IdPago = 0000003100099475144530, 
@NumeroFactura = '14255-31799',
@TipoFactura = 'A',
@Fecha = '2020-02-20',
@Hora = '0005',
@Id_Emp = 257097,
@Id_Cli = 1,
@Id_MP = 1,
@Detalle = @Detalle

go

select * from VEnta.Venta_Registrada
select * from Venta.Detalle_Venta

--Borrado logico de una venta registrada mediante su ID de factura

EXEC Venta.Eliminar_VRegistrada
@NumeroFactura = '05255-31799'


-- Borrar las tablas para crearlas nuevamente asi se realiza correctamente la importacion
drop table if exists Venta.Detalle_Venta;
Go
drop table if exists Venta.Venta_Registrada;
Go
drop table if exists Persona.Empleado;
Go
drop table if exists Articulo.Producto;
Go
drop table if exists Articulo.Categoria;
Go
drop table if exists Venta.sucursal;
Go
drop table if exists Venta.Medio_Pago;
Go
drop table if exists Persona.Cliente;
Go

drop table if exists Venta.Factura

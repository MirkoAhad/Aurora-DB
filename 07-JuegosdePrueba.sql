﻿-- Grupo:06
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

Exec Venta.Modificar_Sucursal 3,'Avenida Siempre Viva','Calle falsa 123','Direccion Falsa de prueba','2342-1232','M a J 7 p.m - 11 p.m'; 
Go

Exec Venta.Baja_Sucursal 1; --Dar de baja la sucursal con borrado logico.
Go

Exec Venta.Baja_Sucursal 1; --Detecta que ya fue dado de baja y no lo permite.
Go

Exec Venta.Baja_Sucursal 10; --Detecta que no existe la sucursal
Go
	
-- Insercion de datos en Categoria 


Exec Articulo.Insertar_Categoria 'Agua','Almacen' --Agrego un ejemplo en la tabla Categoria.
Go


Exec Articulo.Baja_Categoria 'Agua';  -- Dar de baja la categoria.
Go


-- Insercion de datos de Producto 

Exec Articulo.Insertar_Producto 'Agua','20150210',250,'Distribuidor',15,'KG',1; -- Inserto como ejemplo en la tabla de Producto.
Go

Exec Articulo.Baja_Producto 'Agua'; --Dar de baja el producto.
Go

-- Insercion de datos de Empleado 

Exec Persona.Insertar_Empleado 257097,'Alejandro','Gonzalez',46393021,
'Avenida siempre viva 123','Cajero','AleGon@gmail.com','AleGon@SuperA.com','TM',20463930213,2,'clave'; --Inserto un empleado.
Go

Exec Persona.Modificar_Empleado 257097,'Calle falsa 123','Supervisor','AleGon@gmail.com','AleGon@SuperA.com','JC',4, 'clave'; --Modifico los datos del empleado.
Go

Exec Persona.Baja_Empleado 257097; -- Borrado Logico da de baja al empleado
Go

-- Insercion de datos de una nueva Venta Registrada y su detalle venta. 
-- Ejecutar todo junto hasta el Go
DECLARE @IdVenta INT;
Exec Venta.Insertar_VRegistrada 0000003100099475144530, '05511-97799', 'A',10000, 
'2020-02-20','0005',257097,1,1, @Id_Venta = @IdVenta OUTPUT
Exec Venta.Insertar_Detalle_Venta 10,5,100.25,40,@IdVenta; --Inserta un detalle de venta como ejemplo.
Go


--Si deseo insertar mas detalles de ventas a la misma venta:
-- Ejecutar todo junto hasta el Go

DECLARE @IdVenta INT;
Exec Venta.Insertar_VRegistrada @NumeroFactura ='01111-97799',  @Id_Venta = @IdVenta OUTPUT
Exec Venta.Insertar_Detalle_Venta 10,5,14.2,4,@IdVenta; --Inserta un detalle de venta como ejemplo.
Go

--Eliminar Venta registrada por numero de factura
Exec Venta.Eliminar_VRegistrada '373-73-7910';
Go

-- Insercion de datos de prueba Detalle Venta

Exec Venta.Baja_Detalle_Venta 1,1; --Da de baja un Detalle de Venta sin borrado logico.
Go

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

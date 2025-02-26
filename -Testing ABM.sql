Use Com1353G06
--caso de pruebas
-----------------------------------------------------------
-- Test Insercion de cliente
-----------------------------------------------------------
exec Persona.Insertar_Cliente 6,'Juan Perez','Female','Normal'
exec Persona.Eliminar_Cliente 6

delete venta.sucursal
select *
from Persona.Cliente

-----------------------------------------------------------
-- Test Insercion Sucursal
-----------------------------------------------------------
--No permite duplicados: si la sucursal tiene la misma direccion en la misma ciudad, entonces habrá un error
exec Venta.Insertar_Sucursal 'Merlo','Los algarrobos 350','48212321','L a V 8?a. m.–9?p. m.
S y D 9 a. m.-8?p. m.'

exec Venta.Insertar_Sucursal 'Ayacucho','Los algarrobos 350','011-48212321','L a V 8?a. m.–9?p. m.
S y D 9 a. m.-8?p. m.'

exec Venta.Insertar_Sucursal 'Ayacucho','Los algarrobos 350','4844132','L a V 8?a. m.–9?p. m.
S y D 9 a. m.-8?p. m.'


SELECT * FROM Venta.Sucursal

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

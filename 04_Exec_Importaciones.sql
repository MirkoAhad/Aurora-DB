
-- Grupo:06
-- Chacón Mirko Facundo - 43444942
-- Giannni Pérez, Gabriel Idelmar- 45614379
-- Nielsen, Tomas Agustín - 41326589
-- Silva , Pablo Ismael - 31641736
-------------------------------
-- Fecha de Entrega: 28/02/2025
-- Bases de Datos Aplicadas

USE Com1353G06
GO


--------------------------------------------------------Sucursal-----------------------------------------------

EXEC Venta.SucursalImportar
	@data_file_path = 'C:\Temp\Informacion_complementaria.xlsx';
GO

--------------------------------------------------------Empleados-----------------------------------------------


EXEC Persona.EmpleadosImportar
	@data_file_path = 'C:\Temp\Informacion_complementaria.xlsx', @FraseClave ='clave';
GO

--------------------------------------------------------Categoria-----------------------------------------------


EXEC Articulo.CategoriaImportar
	@data_file_path = 'C:\Temp\Informacion_complementaria.xlsx';
GO

--------------------------------------------------------Cliente-----------------------------------------------

Exec Persona.ClienteImportar 'C:\Temp\Clientes.xlsx';
go

--------------------------------------------------------Catalogo-----------------------------------------------

Exec Articulo.CatalogoImportar 'C:\Temp\catalogo.csv';
go

--------------------------------------------------------Productos-----------------------------------------------

Exec Articulo.Productos_ImpImportar 'C:\Temp\Productos_importados.xlsx';
go

--------------------------------------------------------Electronicos-----------------------------------------------

Exec Articulo.ElectronicosImportar 'C:\Temp\Electronic accessories.xlsx';
go

--------------------------------------------------------MedioDePago-----------------------------------------------

EXEC Venta.MediodePagoImportar
	@data_file_path = 'C:\Temp\Informacion_complementaria.xlsx';
GO

--------------------------------------------------------Venta-----------------------------------------------

Exec Venta.VentasImportar 'C:\Temp\Ventas_registradas.csv';
go

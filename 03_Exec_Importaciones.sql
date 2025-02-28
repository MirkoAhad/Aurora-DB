USE Com1353G06
GO


--------------------------------------------------------Sucursal-----------------------------------------------

EXEC Venta.SucursalImportar
	@data_file_path = 'C:\Temp\Informacion_complementaria.xlsx';
GO

--------------------------------------------------------Empleados-----------------------------------------------


EXEC Persona.EmpleadosImportar
	@data_file_path = 'C:\Temp\Informacion_complementaria.xlsx';
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


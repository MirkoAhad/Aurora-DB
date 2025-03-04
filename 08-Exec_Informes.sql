-- Grupo:06
-- Chac�n Mirko Facundo - 43444942
-- Giannni P�rez, Gabriel Idelmar- 45614379
-- Nielsen, Tomas Agust�n - 41326589
-- Silva , Pablo Ismael - 31641736
-------------------------------
-- Fecha de Entrega: 28/02/2025
-- Bases de Datos Aplicadas

use Com1353G06
go

-- EXECS DE INFORMES --

--Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar la cantidad de productos vendidos en ese rango, ordenado de mayor a menor
EXEC Venta.Cantidad_RangoFechas '2019-01-05', '2019-04-04'
GO

----Mostrar total acumulado de ventas (o sea tambi�n mostrar el detalle) para una fecha y sucursal particulares
EXEC Venta.TotalVentasporSucursal '2019-01-05', 'Lomas del mirador '
GO


--Mensual: ingresando un mes y a�o determinado mostrar el total facturado por d�as de la semana, incluyendo s�bado y domingo. 

EXEC Venta.mensual_1
	@mes = 2, @anio = 2019;
GO

--Trimestral: mostrar el total facturado por turnos de trabajo por mes. 

EXEC Venta.Trimestral
GO

--Mensual: ingresando un mes y a�o determinado mostrar el vendedor de mayor monto facturado por sucursal. 

EXEC Venta.mensual_2
	@mes = 2, @anio = 2019, @FraseClave = 'clave';
GO

--Mostrar los 5 productos m�s vendidos en un mes, por semana

EXEC Venta.mensual_3
	@mes = 2, @anio = 2019;
GO

--Mostrar los 5 productos menos vendidos en el mes

EXEC Venta.mensual_4
	@mes = 2, @anio = 2019;
GO

-- por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrarla cantidad de productos vendidos en ese rango por sucursal, ordenado de mayor amenor.

EXEC Venta.fecha_1
	@fechaInicio = '2019-02-01', @fechaFin  = '2024-02-28';
GO
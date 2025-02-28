-- Grupo:06
-- Chacón Mirko Facundo - 43444942
-- Giannni Pérez, Gabriel Idelmar- 45614379
-- Nielsen, Tomas Agustín - 41326589
-- Silva , Pablo Ismael - 31641736
-------------------------------
-- Fecha de Entrega: 28/02/2025
-- Bases de Datos Aplicadas

-- EXECS DE INFORMES --
EXEC Venta.Cantidad_RangoFechas '2019-01-05', '2019-04-04'

EXEC Venta.TotalVentasporSucursal '2019-01-05', 'Ramos Mejia'

EXEC Venta.mensual_1
	@mes = 2, @anio = 2019;

EXEC Venta.Trimestral

EXEC Venta.mensual_2
	@mes = 2, @anio = 2019, @FraseClave = 'clave';

EXEC Venta.mensual_3
	@mes = 2, @anio = 2019;

EXEC Venta.mensual_4
	@mes = 2, @anio = 2019;

EXEC Venta.fecha_1
	@fechaInicio = '2019-02-01', @fechaFin  = '2024-02-28';



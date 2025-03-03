
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

--Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar la cantidad de productos vendidos en ese rango, ordenado de mayor a menor

CREATE OR ALTER PROCEDURE Venta.Cantidad_RangoFechas
@FechaInicio DATE,
@FechaFin DATE
AS
BEGIN
	SELECT 
		p.Id_Prod,
		p.nombre,
		SUM(dv.Cantidad) as TotalVendido
	FROM Venta.Detalle_Venta dv INNER JOIN Venta.Venta_Registrada vr ON dv.Id_Venta= vr.Id 
	INNER JOIN Articulo.Producto p ON dv.Id_Prod = p.Id_Prod
	WHERE vr.Fecha BETWEEN @FechaInicio and @FechaFin
	GROUP BY p.Id_Prod, p.Nombre
	ORDER BY TotalVendido DESC
	FOR XML PATH('CantidadPorRangodeFechas'), ROOT('ReporteProductosVendidos');
END;
go

--Mostrar total acumulado de ventas (o sea tambi�n mostrar el detalle) para una fecha y sucursal particulares

CREATE OR ALTER PROCEDURE Venta.TotalVentasporSucursal
@Fecha DATE,
@Sucursal VARCHAR(30)
AS
BEGIN
	SELECT 
		dv.Id_Prod,
		p.Nombre,
		dv.Cantidad,
		dv.PrecioUnitario,
		dv.Subtotal,
		sum(dv.Subtotal) OVER() AS VentaTotal
	FROM Venta.Sucursal s INNER JOIN Persona.Empleado e ON s.Id_Suc = e.Id_Suc
		INNER JOIN Venta.Venta_Registrada vr ON vr.Id_Emp = e.Legajo
		INNER JOIN Venta.Detalle_Venta dv ON dv.Id_Venta = vr.Id
		INNER JOIN Articulo.Producto p ON p.Id_Prod = dv.Id_Prod
	WHERE vr.Fecha = @Fecha and s.Localidad_Real = @Sucursal

	FOR XML PATH('VentasPorSucursalyFecha'), ROOT('ReporteVentas');
END;
go

--Mensual: ingresando un mes y a�o determinado mostrar el total facturado por d�as de la semana, incluyendo s�bado y domingo. 

CREATE OR ALTER PROCEDURE Venta.mensual_1
   @mes INT, @anio INT
AS
BEGIN
		SELECT 
			DATENAME(WEEKDAY, vr.fecha) AS dia_semana,SUM(vr.Monto) AS total_facturado
		FROM Venta.Venta_Registrada vr
		WHERE month(vr.fecha) = @mes AND year(vr.fecha) = @anio
		GROUP BY DATENAME(WEEKDAY, vr.fecha)
		FOR XML PATH('dia'), ROOT('facturacionMensual');
END;
go

--Trimestral: mostrar el total facturado por turnos de trabajo por mes. 

CREATE OR ALTER PROCEDURE Venta.Trimestral
AS
BEGIN
	select Format(vr.Fecha,'MM') As Mes, E.Turno,
		Sum(vr.monto) as Total_Facturado
		from venta.Venta_Registrada vr
		join Persona.Empleado E on vr.id_Emp = E.Legajo
	where vr.Estado = 1
		Group by Format (vr.Fecha,'MM'), E.Turno
		Order by Mes, E.Turno
	For XML PATH ('Factura'), ROOT ('Facturas');
END;
GO

--Mensual: ingresando un mes y a�o determinado mostrar el vendedor de mayor monto facturado por sucursal. 

CREATE OR ALTER PROCEDURE Venta.mensual_2
   @mes INT, @anio INT, @FraseClave VARCHAR(100)
AS
BEGIN
	WITH RankingVendedores AS (
		SELECT 
			s.Id_Suc,
			s.Localidad_Real AS sucursal,
			e.Legajo,
			CONVERT(VARCHAR(256), DecryptByPassPhrase(@FraseClave, e.Nombre)) + ' ' 
			+ CONVERT(VARCHAR(256), DecryptByPassPhrase(@FraseClave, e.Apellido)) AS vendedor,
			SUM(vr.Monto) AS total_facturado,
			RANK() OVER (PARTITION BY s.Id_Suc ORDER BY SUM(vr.Monto) DESC) AS ranking
		FROM Venta.Venta_Registrada vr
			JOIN Persona.Empleado e ON vr.Id_Emp = e.Legajo
			JOIN Venta.Sucursal s ON e.Id_Suc = s.Id_Suc
		WHERE MONTH(vr.Fecha) = @mes AND YEAR(vr.Fecha) = @anio
			GROUP BY s.Id_Suc, s.Localidad_Real, e.Legajo, e.Nombre, e.Apellido
	)
	SELECT 
		sucursal,
		vendedor,
		total_facturado
	FROM RankingVendedores
	WHERE ranking = 1
	FOR XML PATH('sucursal'), ROOT('MejorVendedorPorSucursal');

END;
go

--Mostrar los 5 productos m�s vendidos en un mes, por semana

CREATE OR ALTER PROCEDURE Venta.mensual_3
   @mes INT, @anio INT
AS
BEGIN

	WITH VentasPorSemana AS (
		SELECT 
			DATEPART(WEEK, vr.Fecha) AS Semana,
			dv.Id_Prod,
			p.Nombre AS Producto,
			SUM(dv.Cantidad) AS Total_Vendido,
			RANK() OVER (PARTITION BY DATEPART(WEEK, vr.Fecha) ORDER BY SUM(dv.Cantidad) DESC) AS ranking
		FROM Venta.Venta_Registrada vr
			JOIN Venta.Detalle_Venta dv ON vr.Id = dv.Id_Venta
			JOIN Articulo.Producto p ON dv.Id_Prod = p.Id_Prod
		WHERE MONTH(vr.Fecha) = @mes AND YEAR(vr.Fecha) = @anio
		GROUP BY DATEPART(WEEK, vr.Fecha), dv.Id_Prod, p.Nombre
	)
	SELECT 
		Semana,
		Producto,
		Total_Vendido
	FROM VentasPorSemana
	WHERE ranking <= 5
	ORDER BY Semana, ranking
	FOR XML PATH('producto'), ROOT('productosMasVendidosPorSemana');

END;
go

--Mostrar los 5 productos menos vendidos en el mes

CREATE OR ALTER PROCEDURE Venta.mensual_4
   @mes INT, @anio INT
AS
BEGIN

	WITH ProductosMenosVendidos AS (
		SELECT 
			dv.Id_Prod,
			p.Nombre AS Producto,
			SUM(dv.Cantidad) AS Total_Vendido,
			RANK() OVER (ORDER BY SUM(dv.Cantidad) ASC) AS ranking
		FROM Venta.Venta_Registrada vr
			JOIN Venta.Detalle_Venta dv ON vr.Id = dv.Id_Venta
			JOIN Articulo.Producto p ON dv.Id_Prod = p.Id_Prod
		WHERE MONTH(vr.Fecha) = @mes AND YEAR(vr.Fecha) = @anio
			GROUP BY dv.Id_Prod, p.Nombre
	)
	SELECT 
		Producto,
		Total_Vendido
	FROM ProductosMenosVendidos
		WHERE ranking <= 5
	ORDER BY ranking
	FOR XML PATH('producto'), ROOT('productosMenosVendidos');

END;
go

-- por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrarla cantidad de productos vendidos en ese rango por sucursal, ordenado de mayor amenor.

CREATE OR ALTER PROCEDURE venta.fecha_1
   @fechaInicio DATE, @fechaFin DATE
AS
BEGIN
	SELECT 
		s.Localidad_Real AS Sucursal,
		p.Nombre AS Producto,
		SUM(dv.Cantidad) AS Cantidad_Vendida
	FROM Venta.Venta_Registrada vr
		JOIN Venta.Detalle_Venta dv ON vr.Id = dv.Id_Venta
		JOIN Articulo.Producto p ON dv.Id_Prod = p.Id_Prod
		JOIN Persona.Empleado e ON vr.Id_Emp = e.Legajo
		JOIN Venta.Sucursal s ON e.Id_Suc = s.Id_Suc
	WHERE vr.Fecha BETWEEN @fechaInicio AND @fechaFin
		GROUP BY s.Localidad_Real, p.Nombre
		ORDER BY Cantidad_Vendida DESC
	FOR XML PATH('producto'), ROOT('productosVendidosPorSucursal');

	END;
go

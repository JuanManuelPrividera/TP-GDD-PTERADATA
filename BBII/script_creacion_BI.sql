--------------------------
-- FUNCIONES AUXILIARES --
--------------------------
CREATE FUNCTION Pteradata.getRangoEtario (@fecha_nacimiento DATE) 
RETURNS INT 
AS
BEGIN
	DECLARE @id_rango_etario INT

	IF(YEAR(GETDATE()) - YEAR(@fecha_nacimiento) < 25)
		SET @id_rango_etario = 1
	ELSE IF (YEAR(GETDATE()) - YEAR(@fecha_nacimiento) < 35)
		SET @id_rango_etario = 2
	ELSE IF (YEAR(GETDATE()) - YEAR(@fecha_nacimiento) < 50)
		SET @id_rango_etario = 3
	ELSE
		SET @id_rango_etario = 4

	RETURN @id_rango_etario
END

GO


CREATE FUNCTION Pteradata.isEntregadoATiempo (@fechaProgramada DATE, @fechaEntrega DATE) RETURNS INT AS
BEGIN

	DECLARE @result INT
	IF @fechaEntrega <= @fechaProgramada
		SET @result = 1
	ELSE
		SET @result = 0

	RETURN @result
END

GO

CREATE FUNCTION Pteradata.getTurno (@fecha_hora DATETIME) RETURNS INT AS 
BEGIN
	DECLARE @id_turno INT
	DECLARE @hora TIME 
	SET @hora = CAST(@fecha_hora AS TIME)

	IF(@hora BETWEEN '08:00:00' AND '12:00:00')
		SET @id_turno = 1
	ELSE IF (@hora BETWEEN '12:00:01' AND '16:00:00')
		SET @id_turno = 2
	ELSE IF (@hora BETWEEN '16:00:01' AND '20:00:00')
		SET @id_turno = 3
	ELSE 
		SET @id_turno = 4

	RETURN @id_turno

END

GO

CREATE FUNCTION Pteradata.isCuota (@cant_cuotas INT) RETURNS INT AS
BEGIN
	DECLARE @return INT
	IF(@cant_cuotas = 1)
		SET @return = 0
	ELSE 
		SET @return = 1

	RETURN @return
END

GO
-----------------------------------
-- CREACIÓN TABLA DE DIMENSIONES --
-----------------------------------
CREATE PROCEDURE Pteradata.crear_todas_las_dimensiones AS
BEGIN
	CREATE TABLE Pteradata.BI_DimProvincia (
		id_provincia INT IDENTITY(1, 1) PRIMARY KEY,
		nombre NVARCHAR(255)
	);
	
	CREATE TABLE Pteradata.BI_DimLocalidad (
		id_localidad INT IDENTITY(1, 1) PRIMARY KEY,
		id_provincia INT REFERENCES Pteradata.BI_DimProvincia,
		nombre NVARCHAR(255)
	);

	CREATE TABLE Pteradata.BI_DimSucursal (
		id_sucursal INT IDENTITY(1, 1) PRIMARY KEY,
		id_localidad INT REFERENCES Pteradata.BI_DimLocalidad,
		nombre NVARCHAR(255),
	);

	CREATE TABLE Pteradata.BI_DimCuatrimestre (
		id_cuatrimestre INT CHECK (id_cuatrimestre IN (1,2,3,4)) PRIMARY KEY,
	);

	CREATE TABLE Pteradata.BI_DimMes (
		id_mes INT CHECK (id_mes IN (1,2,3,4,5,6,7,8,9,10,11,12)) PRIMARY KEY,
		id_cuatrimestre INT REFERENCES Pteradata.BI_DimCuatrimestre,
		nombre NVARCHAR(255)
	);

	CREATE TABLE Pteradata.BI_DimAño (
		id_año INT PRIMARY KEY,
	);

	CREATE TABLE Pteradata.BI_DimTiempo (
		id_tiempo INT IDENTITY(1, 1) PRIMARY KEY,
		id_año INT REFERENCES Pteradata.BI_DimAño,
		id_mes INT REFERENCES Pteradata.BI_DimMes,
	);

	CREATE TABLE Pteradata.BI_DimTurno (
		id_turno INT CHECK (id_turno IN (1,2,3,4)) PRIMARY KEY,
		nombre NVARCHAR(255),
		hora_inicio TIME,
		hora_fin TIME
	);

	CREATE TABLE Pteradata.BI_DimRangoEtario (
		id_rango_etario INT IDENTITY(1,1) PRIMARY KEY,
		nombre NVARCHAR(255),
		edad_inicial INT,
		edad_final INT
	);

	CREATE TABLE Pteradata.BI_DimCategoria (
		id_categoria INT IDENTITY(1,1) PRIMARY KEY,
		nombre NVARCHAR(255)
	);

	CREATE TABLE Pteradata.BI_DimMedioPago (
		id_medio_pago INT IDENTITY(1,1) PRIMARY KEY,
		descripcion NVARCHAR(255)
	);

	CREATE TABLE Pteradata.BI_DimTipoCaja (
		id_tipo_caja INT IDENTITY(1, 1) PRIMARY KEY,
		descripcion NVARCHAR(255)
	);
END

GO
	EXEC Pteradata.crear_todas_las_dimensiones;
GO
------------------------------
-- CREACIÓN TABLA DE HECHOS --
------------------------------
CREATE PROCEDURE Pteradata.crear_todos_los_hechos AS
BEGIN
	CREATE TABLE Pteradata.BI_HechosVentas (
		id_hechos_ventas INT IDENTITY(1, 1) PRIMARY KEY,
		id_tiempo INT REFERENCES Pteradata.BI_DimTiempo,
		id_turno INT REFERENCES Pteradata.BI_DimTurno,
		id_localidad_sucursal INT REFERENCES Pteradata.BI_DimLocalidad,
		id_rango_etario_empleado INT REFERENCES Pteradata.BI_DimRangoEtario,
		id_tipo_caja INT REFERENCES Pteradata.BI_DimTipoCaja,
	
		monto_total_final DECIMAL(16, 2),
		descuento_total DECIMAL(16, 2),
		monto_total_sin_descuento DECIMAL(16, 2),
		cantidad_articulos INT
	);

	

	CREATE TABLE Pteradata.BI_HechosEnvios (
		id_hechos_envios INT IDENTITY(1, 1) PRIMARY KEY,
		id_tiempo INT REFERENCES Pteradata.BI_DimTiempo,
		id_sucursal INT REFERENCES Pteradata.BI_DimSucursal,
		id_rango_etario_cliente INT REFERENCES Pteradata.BI_DimRangoEtario,
		localidad_cliente INT REFERENCES Pteradata.BI_DimLocalidad,

		costo DECIMAL(16, 2),
		entregado_a_tiempo INT CHECK (entregado_a_tiempo IN (0, 1))
	);

	DROP TABLE Pteradata.BI_HechosPromocion

	CREATE TABLE Pteradata.BI_HechosPromocion (
		id_hechos_promocion INT IDENTITY(1, 1) PRIMARY KEY,
		id_tiempo INT REFERENCES Pteradata.BI_DimTiempo,
		id_categoria INT REFERENCES Pteradata.BI_DimCategoria,

		descuento_aplicado DECIMAL(16, 2)
	);

	CREATE TABLE Pteradata.BI_HechosPagos (
		id_hechos_pagos INT IDENTITY(1, 1) PRIMARY KEY,
		id_tiempo INT REFERENCES Pteradata.BI_DimTiempo,
		id_sucursal INT REFERENCES Pteradata.BI_DimSucursal,
		id_medio_pago INT REFERENCES Pteradata.BI_DimMedioPago,
		id_rango_etario_cliente INT REFERENCES Pteradata.BI_DimRangoEtario,

		importe_total DECIMAL(16, 2),
		is_cuota INT CHECK (is_cuota IN (0, 1)),
		descuento_aplicado DECIMAL(16, 2)
	);
END
GO
EXEC Pteradata.crear_todos_los_hechos
GO


--------------------------------
-- MIGRACIÓN TABLAS DIMENSIÓN --
--------------------------------
CREATE PROCEDURE Pteradata.migrar_BI_DimProvincia AS
BEGIN
	INSERT INTO Pteradata.BI_DimProvincia
	SELECT DISTINCT provincia_nombre FROM Pteradata.Provincia
END

GO

CREATE PROCEDURE Pteradata.migrar_BI_DimLocalidad AS
BEGIN
	INSERT INTO Pteradata.BI_DimLocalidad
	SELECT DISTINCT dp.id_provincia, localidad_nombre FROM Pteradata.Localidad l
		JOIN Pteradata.Provincia p ON p.id_provincia = l.id_provincia
		JOIN Pteradata.BI_DimProvincia dp ON p.provincia_nombre = dp.nombre
END

GO

CREATE PROCEDURE Pteradata.migrar_BI_DimSucursal AS
BEGIN
	INSERT INTO Pteradata.BI_DimSucursal
	SELECT DISTINCT dl.id_localidad, sucursal_nombre FROM Pteradata.Sucursal s
 		JOIN Pteradata.Direccion d ON d.id_direccion = s.id_direccion
		JOIN Pteradata.Localidad l ON l.id_localidad = d.id_localidad
		JOIN Pteradata.BI_DimLocalidad dl ON dl.nombre = l.localidad_nombre

END

GO

CREATE PROCEDURE Pteradata.migrar_BI_DimCuatrimestre AS
BEGIN
	INSERT INTO Pteradata.BI_DimCuatrimestre (id_cuatrimestre) VALUES (1),(2),(3)
END

GO

CREATE PROCEDURE Pteradata.migrar_BI_DimMes AS
BEGIN
INSERT INTO Pteradata.BI_DimMes (id_mes, id_cuatrimestre, nombre) VALUES 
	(1, 1, 'Enero'), 
	(2, 1, 'Febrero'), 
	(3, 1, 'Marzo'),
	(4, 1, 'Abril'), 
	(5, 2, 'Mayo'), 
	(6, 2, 'Junio'),
	(7, 2, 'Julio'), 
	(8, 2, 'Agosto'), 
	(9, 3, 'Septiembre'),
	(10, 3, 'Octubre'), 
	(11, 3, 'Noviembre'), 
	(12, 3, 'Diciembre');
END

GO

CREATE PROCEDURE Pteradata.migrar_BI_DimAño AS
BEGIN
	INSERT INTO Pteradata.BI_DimAño(id_año)
	SELECT DISTINCT año FROM (
		SELECT YEAR(ticket_fecha_hora) año FROM Pteradata.Ticket
		UNION
		SELECT YEAR(envio_fecha_programada) año FROM Pteradata.Envio
		UNION
		SELECT YEAR(fecha_entregado) año FROM Pteradata.Envio
		UNION
		SELECT YEAR(pago_fecha) año FROM Pteradata.Pago
	) años
END

GO

CREATE PROCEDURE Pteradata.migrar_BI_DimTiempo AS
BEGIN
	INSERT INTO Pteradata.BI_DimTiempo
	SELECT da.id_año, dm.id_mes FROM Pteradata.BI_DimAño da
		JOIN Pteradata.BI_DimMes dm ON 1=1  
END

GO

CREATE PROCEDURE Pteradata.migrar_BI_DimTurno AS
BEGIN
	INSERT INTO Pteradata.BI_DimTurno (id_turno,nombre,hora_inicio,hora_fin) VALUES 
		(1, 'Mañana', '08:00:00','12:00:00'),
		(2, 'Tarde', '12:00:01','16:00:00'),
		(3, 'Noche', '16:00:01','20:00:00'),
		(4, 'Otro', '20:00:01','07:59:59') 
END
/*
Creo el turno Otro ya que hay tickets que se emiten en horarios fuera de turno
*/
GO

CREATE PROCEDURE Pteradata.migrar_BI_DimRangoEtario AS
BEGIN
	INSERT INTO Pteradata.BI_DimRangoEtario(nombre,edad_inicial,edad_final) VALUES 
		('Menor a 25', 0, 25),
		('Entre 25 y 35', 25, 35),
		('Entre 35 y 50', 35, 50),
		('Mayor a 50', 50, 100)

END

GO

CREATE PROCEDURE Pteradata.migrar_BI_DimCategoria AS
BEGIN
	INSERT INTO Pteradata.BI_DimCategoria(nombre)
	SELECT producto_categoria FROM Pteradata.Categoria
END

GO

CREATE PROCEDURE Pteradata.migrar_BI_DimMedioPago AS
BEGIN
	INSERT INTO Pteradata.BI_DimMedioPago(descripcion)
	SELECT pago_medio_pago FROM Pteradata.MedioPago
END

GO

CREATE PROCEDURE Pteradata.migrar_BI_DimTipoCaja AS
BEGIN
	INSERT INTO Pteradata.BI_DimTipoCaja(descripcion)
	SELECT caja_tipo FROM Pteradata.CajaTipo
END

GO

CREATE PROCEDURE Pteradata.migrar_todas_las_dimensiones AS
BEGIN
	BEGIN TRANSACTION
		BEGIN TRY
			EXEC Pteradata.migrar_BI_DimProvincia;
			EXEC Pteradata.migrar_BI_DimLocalidad;
			EXEC Pteradata.migrar_BI_DimSucursal;
			EXEC Pteradata.migrar_BI_DimCuatrimestre;
			EXEC Pteradata.migrar_BI_DimMes;
			EXEC Pteradata.migrar_BI_DimAño;
			EXEC Pteradata.migrar_BI_DimTiempo;
			EXEC Pteradata.migrar_BI_DimTurno;
			EXEC Pteradata.migrar_BI_DimRangoEtario;
			EXEC Pteradata.migrar_BI_DimCategoria;
			EXEC Pteradata.migrar_BI_DimMedioPago;
			EXEC Pteradata.migrar_BI_DimTipoCaja;
	COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
	ROLLBACK 
		END CATCH
END

GO

EXEC Pteradata.migrar_todas_las_dimensiones;

GO
----------------------------
-- MIGRACIÓN TABLA HECHOS --
----------------------------

SELECT * FROM Pteradata.Envio

CREATE PROCEDURE Pteradata.migrar_BI_HechosEnvio AS
BEGIN
	INSERT INTO Pteradata.BI_HechosEnvios 
	SELECT dt.id_tiempo, ds.id_sucursal, Pteradata.getRangoEtario(c.cliente_fecha_nacimiento), dl.id_localidad,
			SUM(e.envio_costo), Pteradata.isEntregadoATiempo(e.envio_fecha_programada, e.fecha_entregado)
		FROM Pteradata.Envio e
			JOIN Pteradata.BI_DimTiempo dt ON dt.id_año = YEAR(e.envio_fecha_programada) AND dt.id_mes = MONTH(e.envio_fecha_programada)
			JOIN Pteradata.Ticket t ON t.id_ticket = e.id_ticket
			JOIN Pteradata.BI_DimSucursal ds ON ds.nombre = t.sucursal_nombre
			JOIN Pteradata.Cliente c ON c.id_cliente = e.id_cliente
			JOIN Pteradata.Direccion d ON d.id_direccion = c.id_direccion
			JOIN Pteradata.Localidad l ON l.id_localidad = d.id_localidad
			JOIN Pteradata.Provincia p ON p.id_provincia = l.id_provincia
			JOIN Pteradata.BI_DimProvincia dp ON dp.nombre = p.provincia_nombre
			JOIN Pteradata.BI_DimLocalidad dl ON dl.nombre = l.localidad_nombre AND dl.id_provincia = dp.id_provincia
	GROUP BY dt.id_tiempo, ds.id_sucursal, Pteradata.getRangoEtario(c.cliente_fecha_nacimiento), 
	Pteradata.isEntregadoATiempo(e.envio_fecha_programada, e.fecha_entregado), dl.id_localidad

END

GO

CREATE PROCEDURE Pteradata.migrar_BI_HechosVentas AS
BEGIN
	INSERT INTO Pteradata.BI_HechosVentas
	SELECT DISTINCT dt.id_tiempo, Pteradata.getTurno(t.ticket_fecha_hora), ds.id_localidad, Pteradata.getRangoEtario(e.empleado_fecha_nacimiento), 
			dtc.id_tipo_caja, 
			CAST( SUM(t.ticket_total) AS DECIMAL(16, 2) ), 
			CAST( SUM(t.ticket_total_Descuento_aplicado + t.ticket_det_Descuento_medio_pago) AS DECIMAL(16, 2) ),
			CAST( SUM(t.ticket_subtotal_productos) AS DECIMAL(16, 2) ),
			SUM(tp.ticket_det_cantidad)
	FROM Pteradata.Ticket t
		JOIN Pteradata.TicketPorProducto tp ON tp.id_ticket = t.id_ticket
		JOIN Pteradata.BI_DimTiempo dt ON dt.id_año = YEAR(t.ticket_fecha_hora) AND dt.id_mes = MONTH(t.ticket_fecha_hora)
		JOIN Pteradata.Sucursal s ON t.sucursal_nombre = s.sucursal_nombre
		JOIN Pteradata.BI_DimSucursal ds ON ds.nombre = s.sucursal_nombre
		JOIN Pteradata.Empleado e ON e.legajo_empleado = t.legajo_empleado
		JOIN Pteradata.Caja c ON c.id_caja = t.id_caja
		JOIN Pteradata.CajaTipo ct ON ct.id_caja_tipo = c.id_caja_tipo
		JOIN Pteradata.BI_DimTipoCaja dtc ON dtc.descripcion = ct.caja_tipo
	GROUP BY 
		dt.id_tiempo, dt.id_mes, dt.id_año, ds.id_localidad, dtc.id_tipo_caja, 
		Pteradata.getRangoEtario(e.empleado_fecha_nacimiento),
		Pteradata.getTurno(t.ticket_fecha_hora)
		
END

GO

CREATE PROCEDURE Pteradata.migrar_BI_HechosPagos AS
BEGIN
	INSERT INTO Pteradata.BI_HechosPagos
	SELECT DISTINCT dt.id_tiempo, ds.id_sucursal, dmp.id_medio_pago, Pteradata.getRangoEtario(c.cliente_fecha_nacimiento),
	SUM(p.pago_importe), Pteradata.isCuota(dp.cant_cuotas), SUM(t.ticket_det_Descuento_medio_pago)
	FROM Pteradata.Pago p
		JOIN Pteradata.BI_DimTiempo dt ON dt.id_año = YEAR(p.pago_fecha) AND dt.id_mes = MONTH(p.pago_fecha) 
		JOIN Pteradata.Ticket t ON t.id_ticket = p.id_ticket
		JOIN Pteradata.BI_DimSucursal ds ON ds.nombre = t.sucursal_nombre
		JOIN Pteradata.MedioPago mp ON p.id_medio_pago = mp.id_medio_pago
		JOIN Pteradata.BI_DimMedioPago dmp ON dmp.descripcion = mp.pago_medio_pago
		JOIN Pteradata.DetallePago dp ON dp.ID_pago = p.ID_pago
		JOIN Pteradata.Cliente c ON c.id_cliente = dp.id_cliente
	GROUP BY dt.id_tiempo, ds.id_sucursal, dmp.id_medio_pago,
				Pteradata.getRangoEtario(c.cliente_fecha_nacimiento), Pteradata.isCuota(dp.cant_cuotas)
END

GO

CREATE PROCEDURE Pteradata.migrar_BI_HechosPromociones AS
BEGIN
	INSERT INTO Pteradata.BI_HechosPromocion
	SELECT DISTINCT dt.id_tiempo, dc.id_categoria, SUM(Promocion_aplicada_dto)
	FROM Pteradata.PromocionAplicada pa
		JOIN Pteradata.TicketPorProducto tpp ON tpp.id_ticket_producto = pa.id_ticket_producto
		JOIN Pteradata.Ticket t ON t.id_ticket = tpp.id_ticket
		JOIN Pteradata.ProductoPorMarca ppm ON ppm.id_producto_marca = tpp.id_Producto_Marca
		JOIN Pteradata.Producto p ON p.id_producto = ppm.id_producto
		JOIN Pteradata.ProductoPorCategoria ppc ON p.id_producto = ppc.id_producto
		JOIN Pteradata.BI_DimCategoria dc ON dc.nombre = ppc.producto_categoria
		JOIN Pteradata.BI_DimTiempo dt ON dt.id_año = YEAR(t.ticket_fecha_hora) AND dt.id_mes = MONTH(t.ticket_fecha_hora)
	GROUP BY dt.id_tiempo, dc.id_categoria
END

GO

CREATE PROCEDURE Pteradata.migrar_todos_los_hechos AS
BEGIN
	EXEC Pteradata.migrar_BI_HechosEnvio;
	EXEC Pteradata.migrar_BI_HechosVentas;
	EXEC Pteradata.migrar_BI_HechosPagos;
	EXEC Pteradata.migrar_BI_HechosPromociones;
END

GO

EXEC Pteradata.migrar_todos_los_hechos

GO


----------------------------
--   CREACION DE VISTAS   --
----------------------------

/*
Ticket Promedio mensual. Valor promedio de las ventas (en $) según la
localidad, año y mes. Se calcula en función de la sumatoria del importe de las
ventas sobre el total de las mismas.
*/

CREATE VIEW Pteradata.TicketPromedioMensual(promedio_mensual,localidad, año, mes) AS
	SELECT SUM(v.monto_total)/COUNT(v.id_hechos_ventas), l.nombre, t.id_año, m.nombre  FROM Pteradata.BI_HechosVentas v
	JOIN Pteradata.BI_DimLocalidad l ON l.id_localidad = v.id_localidad_sucursal
	JOIN Pteradata.BI_DimTiempo t ON t.id_tiempo = v.id_tiempo
	JOIN Pteradata.BI_DimMes m ON t.id_mes = m.id_mes
	GROUP BY l.id_localidad, l.nombre, t.id_año, m.nombre

GO
/*
Cantidad unidades promedio. Cantidad promedio de artículos que se venden
en función de los tickets según el turno para cada cuatrimestre de cada año. Se
obtiene sumando la cantidad de artículos de todos los tickets correspondientes
sobre la cantidad de tickets. Si un producto tiene más de una unidad en un ticket,
para el indicador se consideran todas las unidades.
*/

CREATE VIEW Pteradata.CantidadUnidadesPromedio(cantidad_unidades_promedio, turno, cuatrimestre, año) AS
	SELECT CAST(SUM(v.cantidad_articulos)/COUNT(v.id_hechos_ventas) AS DECIMAL(10,2)), dt.nombre, m.id_cuatrimestre, t.id_año FROM Pteradata.BI_HechosVentas v
	JOIN Pteradata.BI_DimTiempo t ON t.id_tiempo = v.id_tiempo
	JOIN Pteradata.BI_DimMes m ON t.id_mes = m.id_mes
	JOIN Pteradata.BI_DimTurno dt ON dt.id_turno = v.id_turno
	GROUP BY dt.nombre,t.id_año, m.id_cuatrimestre

GO
/*
Porcentaje anual de ventas registradas por rango etario del empleado según el
tipo de caja para cada cuatrimestre. Se calcula tomando la cantidad de ventas
correspondientes sobre el total de ventas anual.
*/

CREATE VIEW Pteradata.PorcentajeDeVentasPorRangoEtario(porcentaje_ventas, rango_etario, tipo_de_caja, cuatrimestre, año) AS
	SELECT CAST(COUNT(v.id_hechos_ventas)AS DECIMAL(7,2))/CAST((SELECT COUNT(v1.id_hechos_ventas) FROM Pteradata.BI_HechosVentas v1) AS DECIMAL(7,2)) * 100,
	re.nombre, tc.descripcion, m.id_cuatrimestre, t.id_año
	FROM Pteradata.BI_HechosVentas v
		JOIN Pteradata.BI_DimRangoEtario re ON re.id_rango_etario = v.id_rango_etario_empleado
		JOIN Pteradata.BI_DimTipoCaja tc ON tc.id_tipo_caja = v.id_tipo_caja
		JOIN Pteradata.BI_DimTiempo t ON t.id_tiempo = v.id_tiempo
		JOIN Pteradata.BI_DimMes m ON m.id_mes = t.id_mes
	GROUP BY re.nombre, tc.descripcion, m.id_cuatrimestre, t.id_año

GO
/*
Cantidad de ventas registradas por turno para cada localidad según el mes de
cada año.
*/

CREATE VIEW Pteradata.VentasPorTurno(cantidad_ventas, turno, mes, año) AS
	SELECT COUNT(v.id_hechos_ventas), dt.nombre, m.nombre, t.id_año  FROM Pteradata.BI_HechosVentas v
		JOIN Pteradata.BI_DimTurno dt ON dt.id_turno = v.id_turno
		JOIN Pteradata.BI_DimTiempo t ON t.id_tiempo = v.id_tiempo
		JOIN Pteradata.BI_DimMes m ON t.id_mes = m.id_mes
	GROUP BY dt.nombre, m.nombre, t.id_año

GO

/*
Porcentaje de descuento aplicados en función del total de los tickets según el
mes de cada año.
*/

CREATE VIEW Pteradata.PorcentajeDeDescuentosAplicados (porcentaje_aplicado, mes, año) AS
	SELECT SUM(v.porcentaje_descuento)/COUNT(v.id_hechos_ventas), m.nombre, t.id_año FROM Pteradata.BI_HechosVentas v
		JOIN Pteradata.BI_DimTiempo t ON t.id_tiempo = v.id_tiempo
		JOIN Pteradata.BI_DimMes m ON m.id_mes = t.id_mes
	GROUP BY m.nombre, t.id_año

GO
/*
Las tres categorías de productos con mayor descuento aplicado a partir de
promociones para cada cuatrimestre de cada año.
*/
CREATE VIEW Pteradata.Top3CategoriasConMayorDescuento(categoria, descuento_aplicado, cuatrimestre, año) AS
	SELECT categoria, descuento_aplicado, cuatrimestre, año FROM (
	SELECT d.nombre 'categoria', MAX(p.descuento_aplicado) 'descuento_aplicado', 
		m.id_cuatrimestre 'cuatrimestre', t.id_año 'año',
		ROW_NUMBER() OVER (PARTITION BY m.id_cuatrimestre, t.id_año ORDER BY MAX(p.descuento_aplicado) DESC) AS rownum
		FROM Pteradata.BI_HechosPromocion p
		JOIN Pteradata.BI_DimCategoria d ON d.id_categoria = p.id_categoria
		JOIN Pteradata.BI_DimTiempo t ON t.id_tiempo = p.id_tiempo
		JOIN Pteradata.BI_DimMes m ON t.id_mes = m.id_mes
	GROUP BY d.nombre, m.id_cuatrimestre, t.id_año ) AS tb
	WHERE rownum <= 3

GO

/*
Porcentaje de cumplimiento de envíos en los tiempos programados por
sucursal por año/mes (desvío)
*/

CREATE VIEW Pteradata.CumplimientoDeEnvios (porcentaje_cumplimiento, sucursal, año, mes) AS
	SELECT (COUNT(e.entregado_a_tiempo)/COUNT(e.id_hechos_envios))*100, s.nombre, t.id_año, m.nombre FROM Pteradata.BI_HechosEnvios e
		JOIN Pteradata.BI_DimSucursal s ON s.id_sucursal = e.id_sucursal
		JOIN Pteradata.BI_DimTiempo t ON t.id_tiempo = e.id_tiempo
		JOIN Pteradata.BI_DimMes m ON m.id_mes = t.id_mes
	WHERE e.entregado_a_tiempo = 0
	GROUP BY s.nombre, t.id_año, m.nombre

GO

/*
Cantidad de envíos por rango etario de clientes para cada cuatrimestre de
cada año.
*/

CREATE VIEW Pteradata.EnviosPorRangoEtario(cantidad_envios, rango_etario_cliente, cuatrimestre, año) AS
	SELECT COUNT(e.id_hechos_envios), r.nombre, m.id_cuatrimestre, t.id_año FROM Pteradata.BI_HechosEnvios e
		JOIN Pteradata.BI_DimCliente c ON e.id_cliente = c.id_cliente
		JOIN Pteradata.BI_DimRangoEtario r ON r.id_rango_etario = c.id_rango_etario
		JOIN Pteradata.BI_DimTiempo t ON t.id_tiempo = e.id_tiempo
		JOIN Pteradata.BI_DimMes m ON t.id_mes = m.id_mes
	GROUP BY r.nombre, m.id_cuatrimestre, t.id_año

GO

/*
Las 5 localidades (tomando la localidad del cliente) con mayor costo de envío.
*/

CREATE VIEW Pteradata.Top5LocalidadesMayorCostoEnvio(localidad, costo_envio) AS
	SELECT localidad, costo_envio FROM (
		SELECT l.nombre 'localidad', MAX(e.costo) 'costo_envio',
			ROW_NUMBER() OVER (ORDER BY MAX(e.costo) DESC) AS rownum
		FROM Pteradata.BI_HechosEnvios e
			JOIN Pteradata.BI_DimCliente c ON e.id_cliente = c.id_cliente
			JOIN Pteradata.BI_DimLocalidad l ON c.id_localidad = l.id_localidad
		GROUP BY l.nombre
	) tb
	WHERE rownum <= 5

GO

/*
Las 3 sucursales con el mayor importe de pagos en cuotas, según el medio de
pago, mes y año. Se calcula sumando los importes totales de todas las ventas en
cuotas.
*/

CREATE VIEW Pteradata.Top3SucursalesMayorPagoEnCuotas(importe_total, sucursal, medio_de_pago, mes, año) AS
	SELECT importe_total, sucursal, medio_de_pago, mes, año FROM (
		SELECT SUM(p.importe_total) 'importe_total',s.nombre 'sucursal', mp.descripcion 'medio_de_pago', m.nombre 'mes', t.id_año 'año', 
		ROW_NUMBER() OVER (PARTITION BY mp.descripcion, m.nombre, t.id_año ORDER BY SUM(p.importe_total) DESC) AS rownum
		FROM Pteradata.BI_HechosPagos p
			JOIN Pteradata.BI_DimMedioPago mp ON mp.id_medio_pago = p.id_medio_pago
			JOIN Pteradata.BI_DimTiempo t ON t.id_tiempo = p.id_tiempo
			JOIN Pteradata.BI_DimMes m ON m.id_mes = t.id_mes
			JOIN Pteradata.BI_DimSucursal s ON s.id_sucursal = p.id_sucursal
		WHERE p.importe_por_cuota != p.importe_total
		GROUP BY mp.descripcion, m.nombre, t.id_año,s.nombre) tb
	WHERE rownum <= 3

GO

/*
Promedio de importe de la cuota en función del rango etareo del cliente.
*/

CREATE VIEW Pteradata.PromedioImporteCuotaPorRangoEtario (promedio_importe, rango_etario) AS
	SELECT CAST(SUM(p.importe_por_cuota)/COUNT(p.id_hechos_pagos) AS DECIMAL(10,2)), r.nombre FROM Pteradata.BI_HechosPagos p
		JOIN Pteradata.BI_DimRangoEtario r ON r.id_rango_etario = p.id_rango_etario_cliente
	WHERE p.importe_por_cuota != p.importe_total
	GROUP BY r.nombre

GO
/*
Porcentaje de descuento aplicado por cada medio de pago en función del valor
de total de pagos sin el descuento, por cuatrimestre. Es decir, total de descuentos
sobre el total de pagos más el total de descuentos.
*/

CREATE VIEW Pteradata.PorcentajeDescuentoPorMedioPago (porcentaje_descuento, medio_de_pago) AS
	SELECT SUM(p.descuento_aplicado)/(SUM(p.importe_total) + SUM(p.descuento_aplicado)) * 100, mp.descripcion
	FROM Pteradata.BI_HechosPagos p
		JOIN Pteradata.BI_DimMedioPago mp ON mp.id_medio_pago = p.id_medio_pago
	GROUP BY mp.descripcion
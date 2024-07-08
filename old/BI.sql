
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------CREACION DE TABLAS -----------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE crearTodasLasTablasBI AS
BEGIN
	CREATE TABLE Pteradata.BI_Tiempo(
		id_tiempo INT PRIMARY KEY,
		año INT,
		cuatrimestre INT,
		mes INT
	);

	CREATE TABLE Pteradata.BI_Ubicacion(
		id_direccion INT PRIMARY KEY,
		Direccion NVARCHAR(255),
		Localidad NVARCHAR(255),
		Provincia NVARCHAR (255)
	);
	CREATE TABLE Pteradata.BI_Sucursal(
		sucursal_nombre NVARCHAR(255) PRIMARY KEY,
		CUIT NVARCHAR(255),
		Id_Direccion INT,
		FOREIGN KEY(id_direccion) REFERENCES Pteradata.BI_Ubicacion(id_direccion)
	);
	CREATE TABLE Pteradata.BI_MedioPago (
		id_medio_pago INT PRIMARY KEY,
		Medio_Pago NVARCHAR(255) UNIQUE
	);
	CREATE TABLE Pteradata.BI_Turno(
		id_turno INT PRIMARY KEY IDENTITY(1,1),
		turno_hora_inicio TIME,
		turno_hora_fin TIME
	);
	CREATE TABLE Pteradata.BI_Ticket(
		id_ticket INT PRIMARY KEY,
		sucursal_nombre NVARCHAR(255),
		ticket_numero DECIMAL(18,0),
		ticket_total DECIMAL (18,2),
		ticket_total_envio DECIMAL(18,2),
		ticket_total_Descuento_aplicado DECIMAL(18,2),
		ticket_det_Descuento_medio_pago DECIMAL(18,2),
		ticket_turno INT,
		ticket_fecha INT,
		ticket_subtotal_productos DECIMAL(18,2),
		FOREIGN KEY (sucursal_nombre) REFERENCES Pteradata.BI_Sucursal(sucursal_nombre),
		FOREIGN KEY (ticket_turno) REFERENCES Pteradata.BI_Turno(id_turno),
		FOREIGN KEY (ticket_fecha) REFERENCES Pteradata.BI_Tiempo(id_tiempo)

	);
	CREATE TABLE Pteradata.BI_Pago(
		ID_Pago INT PRIMARY KEY,
		id_medio_pago INT,
		id_ticket INT,
		pago_fecha INT, 
		pago_importe DECIMAL(18,2),

		FOREIGN KEY(id_medio_pago) REFERENCES Pteradata.BI_MedioPago(id_medio_pago),
		FOREIGN KEY(id_ticket) REFERENCES Pteradata.BI_Ticket(id_ticket),
		FOREIGN KEY (pago_fecha) REFERENCES Pteradata.BI_Tiempo(id_tiempo)
	);
	CREATE TABLE Pteradata.BI_RangoEtario(
		id_rango_etario INT PRIMARY KEY IDENTITY(1,1),
		edad_minima INT,
		edad_maxima INT,
		descripcion NVARCHAR(255)
	);
	CREATE TABLE Pteradata.BI_Cliente(
		id_cliente INT PRIMARY KEY, 
		id_direccion INT,
		cliente_fecha_registro DATE,
		cliente_fecha_nacimiento DATE,
		edad INT,
		id_rango_etario INT, 
		FOREIGN KEY(id_direccion) REFERENCES Pteradata.BI_Ubicacion(id_direccion),
		FOREIGN KEY(id_rango_etario) REFERENCES Pteradata.BI_RangoEtario(id_rango_etario)
	);

	CREATE TABLE Pteradata.BI_TicketPorProducto(
		id_ticket INT,
		id_producto_marca INT,
		ticket_det_cantidad INT
		FOREIGN KEY (id_ticket) REFERENCES Pteradata.BI_Ticket(id_ticket)
	);
	CREATE TABLE Pteradata.BI_Empleado(
		legajo_empleado INT,
		sucursal_nombre NVARCHAR(255),
		id_rango_etario INT,
		caja_tipo NVARCHAR(255),

		FOREIGN KEY(id_rango_etario) REFERENCES Pteradata.BI_RangoEtario(id_rango_etario)
	);
	CREATE TABLE Pteradata.BI_Envio(
		id_envio INT PRIMARY KEY,
		id_cliente INT,
		id_ticket INT,
		envio_estado NVARCHAR(255),
		envio_costo DECIMAL(18,2),
		envio_fecha_programada DATETIME,
		envio_hora_inicio DATETIME,
		envio_hora_fin DATETIME,
		fecha_entregado DATETIME,
		id_fecha INT

		FOREIGN KEY (id_cliente) REFERENCES Pteradata.BI_Cliente,
		FOREIGN KEY (id_ticket) REFERENCES Pteradata.BI_Ticket,
		FOREIGN KEY (id_fecha) REFERENCES Pteradata.BI_Tiempo(id_tiempo)
	);
	CREATE TABLE Pteradata.BI_Producto(
		id_producto INT PRIMARY KEY, 
		nombre NVARCHAR(255),
		descripcion NVARCHAR(255)
	);
	CREATE TABLE Pteradata.BI_ProductoPorCategoria(
		id_producto INT,
		producto_categoria NVARCHAR(255),
		PRIMARY KEY(id_producto, producto_categoria),
		FOREIGN KEY (id_producto) REFERENCES Pteradata.BI_Producto(id_producto)
	);
	CREATE TABLE Pteradata.BI_PromocionAplicada(
		id_promocion_aplicada INT PRIMARY KEY,
		promocion_dto_aplicado DECIMAL(18,2),
		id_producto INT,
		fecha INT,
		FOREIGN KEY (id_producto) REFERENCES Pteradata.BI_Producto(id_producto),
		FOREIGN KEY (fecha) REFERENCES Pteradata.BI_Tiempo(id_tiempo)
	);

	CREATE TABLE Pteradata.BI_DetallePago (
			id_pago_detalle INT PRIMARY KEY,
			ID_Pago INT,
			id_cliente INT,
			cant_cuotas DECIMAL(18,0),
        
			FOREIGN KEY(ID_Pago) REFERENCES Pteradata.BI_Pago(ID_Pago),
			FOREIGN KEY (id_cliente) REFERENCES Pteradata.BI_Cliente(id_cliente)
	);
	CREATE TABLE Pteradata.BI_DescuentoPorPago(
			ID_Pago INT,
			Descuento_aplicado DECIMAL(18,2),

			PRIMARY KEY (ID_Pago),
			FOREIGN KEY(ID_Pago) REFERENCES Pteradata.BI_Pago(ID_Pago)
	);
END

EXEC crearTodasLasTablasBI


------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------MIGRO DATOS--------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
GO
CREATE PROCEDURE migrarBI_Tiempo AS
BEGIN 
	INSERT INTO Pteradata.BI_Tiempo(id_tiempo,año, mes, cuatrimestre)
	SELECT DISTINCT (YEAR(pago_fecha)*100+MONTH(pago_fecha)),YEAR(pago_fecha), MONTH(pago_fecha),
		CASE 
			WHEN MONTH(pago_fecha) BETWEEN 1 AND 4  THEN 1
			WHEN MONTH(pago_fecha) BETWEEN 5 AND 8  THEN 2
			WHEN MONTH(pago_fecha) BETWEEN 9 AND 12 THEN 3
		END 
		FROM Pteradata.Pago
	UNION 
	SELECT DISTINCT (YEAR(fecha_entregado)*100+MONTH(fecha_entregado)),YEAR(fecha_entregado), MONTH(fecha_entregado),
		CASE 
			WHEN MONTH(fecha_entregado) BETWEEN 1 AND 4  THEN 1
			WHEN MONTH(fecha_entregado) BETWEEN 5 AND 8  THEN 2
			WHEN MONTH(fecha_entregado) BETWEEN 9 AND 12 THEN 3
		END
		FROM Pteradata.Envio
	UNION
	SELECT DISTINCT (YEAR(envio_fecha_programada)*100+MONTH(envio_fecha_programada)),YEAR(envio_fecha_programada), MONTH(envio_fecha_programada),
		CASE 
			WHEN MONTH(envio_fecha_programada) BETWEEN 1 AND 4  THEN 1
			WHEN MONTH(envio_fecha_programada) BETWEEN 5 AND 8  THEN 2
			WHEN MONTH(envio_fecha_programada) BETWEEN 9 AND 12 THEN 3
		END
		FROM Pteradata.Envio	
	UNION 
	SELECT DISTINCT (YEAR(ticket_fecha_hora)*100+MONTH(ticket_fecha_hora)),YEAR(ticket_fecha_hora), MONTH(ticket_fecha_hora),
		CASE 
			WHEN MONTH(ticket_fecha_hora) BETWEEN 1 AND 4  THEN 1
			WHEN MONTH(ticket_fecha_hora) BETWEEN 5 AND 8  THEN 2
			WHEN MONTH(ticket_fecha_hora) BETWEEN 9 AND 12 THEN 3
		END
		FROM Pteradata.Ticket
END
GO
CREATE PROCEDURE migrarBI_Ubicacion AS
BEGIN
	INSERT INTO Pteradata.BI_Ubicacion(id_direccion,Direccion,Localidad,Provincia)
	SELECT DISTINCT d.id_direccion, d.domicilio, l.localidad_nombre,p.provincia_nombre
	FROM Pteradata.Direccion d 
		JOIN Pteradata.Localidad l ON d.id_localidad = l.id_localidad
		JOIN Pteradata.Provincia p ON l.id_provincia = p.id_provincia
							 
END
GO
CREATE PROCEDURE migrarBI_Sucursal AS
BEGIN
	INSERT INTO Pteradata.BI_Sucursal(Sucursal_Nombre,CUIT,Id_Direccion)
	SELECT DISTINCT sucursal_nombre, cuit, id_direccion
	FROM Pteradata.Sucursal
END
GO
CREATE PROCEDURE migrarBI_MedioPago AS
BEGIN
	INSERT INTO Pteradata.BI_MedioPago(id_medio_pago,Medio_Pago)
	SELECT id_medio_pago,pago_medio_pago
	FROM Pteradata.MedioPago
END
GO
CREATE PROCEDURE migrarBI_Turno AS
BEGIN
	INSERT INTO Pteradata.BI_Turno (turno_hora_inicio,turno_hora_fin)
	VALUES('08:00:00','12:00:00'), ('12:00:01','16:00:00'),('16:00:01','20:00:00'),('20:00:01','00:00:00'),('00:00:01','07:59:59')
END
select * from Pteradata.BI_Turno
GO
CREATE PROCEDURE migrarBI_Ticket AS
BEGIN
	INSERT INTO Pteradata.BI_Ticket(id_ticket,sucursal_nombre,ticket_numero,ticket_total,ticket_total_envio,ticket_total_Descuento_aplicado,ticket_det_Descuento_medio_pago,ticket_turno,ticket_fecha,ticket_subtotal_productos)
	SELECT  id_ticket,sucursal_nombre,ticket_numero,ticket_total,ticket_total_envio,ticket_total_Descuento_aplicado,ticket_det_Descuento_medio_pago,tu.id_turno,ti.id_tiempo,ticket_subtotal_productos
	FROM Pteradata.Ticket t JOIN Pteradata.BI_Turno tu ON CAST(t.ticket_fecha_hora AS TIME) BETWEEN tu.turno_hora_inicio AND tu.turno_hora_fin
	JOIN Pteradata.BI_Tiempo ti ON ti.mes = MONTH(t.ticket_fecha_hora) AND ti.año = YEAR(t.ticket_fecha_hora) 
END
GO
CREATE PROCEDURE migrarBI_Pago AS
BEGIN
	INSERT INTO Pteradata.BI_Pago(ID_Pago,id_medio_pago,id_ticket,pago_fecha,pago_importe)
	SELECT DISTINCT ID_Pago,id_medio_pago,id_ticket,t.id_tiempo,pago_importe
	FROM Pteradata.Pago p JOIN Pteradata.BI_Tiempo t ON t.mes = MONTH(p.pago_fecha) AND t.año = YEAR(p.pago_fecha)
END
GO
CREATE PROCEDURE migrarBI_RangoEtario AS
BEGIN
	INSERT INTO Pteradata.BI_RangoEtario(edad_minima,edad_maxima,descripcion)
	VALUES (0,25,'Menores de 25'),(26,35,'Mayores de 25 y menores de 35'),(36,50, 'Mayores de 35 y menores de 50'),(51,150,'Mayores de 50')
END
GO
CREATE PROCEDURE migrarBI_Cliente AS
BEGIN
	INSERT INTO Pteradata.BI_Cliente(id_cliente,id_direccion,cliente_fecha_registro,cliente_fecha_nacimiento,edad, id_rango_etario)
	SELECT DISTINCT id_cliente,id_direccion,cliente_fecha_registro,cliente_fecha_nacimiento, 
			DATEDIFF(YEAR,cliente_fecha_nacimiento,GETDATE()) AS edad, r.id_rango_etario
	FROM Pteradata.Cliente
		JOIN Pteradata.BI_RangoEtario r on r.edad_minima <= DATEDIFF(YEAR,cliente_fecha_nacimiento,GETDATE()) and r.edad_maxima >= DATEDIFF(YEAR,cliente_fecha_nacimiento,GETDATE()) 
END
GO

CREATE PROCEDURE migrarBI_TicketPorProducto AS
BEGIN
	INSERT INTO Pteradata.BI_TicketPorProducto(id_ticket, id_producto_marca, ticket_det_cantidad)
	SELECT id_ticket, id_producto_marca, ticket_det_cantidad FROM Pteradata.TicketPorProducto
END
GO
CREATE PROCEDURE migrarBI_Empleado AS
BEGIN
	INSERT INTO Pteradata.BI_Empleado(legajo_empleado,sucursal_nombre,id_rango_etario, caja_tipo)
	SELECT e.legajo_empleado, e.sucursal_nombre, r.id_rango_etario, ct.caja_tipo 
	FROM Pteradata.Empleado e
		JOIN Pteradata.BI_RangoEtario r ON DATEDIFF(year, e.empleado_fecha_nacimiento, GETDATE()) BETWEEN r.edad_minima AND r.edad_maxima
		JOIN Pteradata.Caja c ON c.id_caja = e.ID_Caja
		JOIN Pteradata.CajaTipo ct ON ct.id_caja_tipo = c.id_caja_tipo
END
GO
CREATE PROCEDURE migrarBI_Envio AS
BEGIN
	INSERT INTO Pteradata.BI_Envio(id_envio, id_cliente, id_ticket, envio_estado, envio_costo, envio_fecha_programada,
	envio_hora_inicio, envio_hora_fin, fecha_entregado, id_fecha)
	SELECT e.id_envio, e.id_cliente, e.id_ticket, ee.envio_estado, e.envio_costo, e.envio_fecha_programada,
					e.envio_hora_inicio, e.envio_hora_fin, e.fecha_entregado,t.id_tiempo
		FROM Pteradata.Envio e
		JOIN Pteradata.EnvioEstado ee on ee.id_envio_estado = e.id_envio_estado
		JOIN Pteradata.BI_Tiempo t ON t.mes = MONTH(e.envio_fecha_programada) AND t.año= YEAR( e.envio_fecha_programada)
END
GO
CREATE PROCEDURE migrarBI_Producto AS
BEGIN
	INSERT INTO Pteradata.BI_Producto(id_producto, nombre, descripcion)
	SELECT id_producto, Producto_Nombre, Producto_Descripcion
		FROM Pteradata.Producto
END
GO
CREATE PROCEDURE migrarBI_ProductoPorCategoria AS
BEGIN
	INSERT INTO Pteradata.BI_ProductoPorCategoria(id_producto, producto_categoria)
	SELECT DISTINCT p.id_producto, ppc.producto_categoria
		FROM Pteradata.BI_Producto p
			JOIN Pteradata.ProductoPorCategoria ppc on ppc.id_producto = p.id_producto
END
GO
CREATE PROCEDURE migrarBI_PromocionAplicada AS
BEGIN 
	INSERT INTO Pteradata.BI_PromocionAplicada(id_promocion_aplicada, promocion_dto_aplicado, id_producto, fecha)
	SELECT p.id_promocion_aplicada, tpp.ticket_det_total - p.Promocion_aplicada_dto, ppm.id_producto, t.ticket_fecha
		FROM Pteradata.PromocionAplicada p
			JOIN Pteradata.TicketPorProducto tpp ON tpp.id_ticket_producto = p.id_ticket_producto
			JOIN Pteradata.ProductoPorMarca ppm ON ppm.id_producto_marca = tpp.id_Producto_Marca 
			JOIN Pteradata.BI_Ticket t on t.id_ticket = tpp.id_ticket
END
GO
CREATE PROCEDURE migrarBI_DetallePago AS
BEGIN
	INSERT INTO Pteradata.BI_DetallePago(id_pago_detalle,ID_Pago,id_cliente,cant_cuotas)
	SELECT DISTINCT id_pago_detalle,ID_Pago,id_cliente,cant_cuotas
	FROM Pteradata.DetallePago
END
GO
CREATE PROCEDURE migrarBI_DtoxPago AS
BEGIN
	INSERT INTO Pteradata.BI_DescuentoPorPago(ID_Pago,Descuento_aplicado)
	SELECT DISTINCT ID_Pago,Descuento_aplicado
	FROM Pteradata.DescuentoPorPago
END
GO
CREATE PROCEDURE migrarTodoBI AS
BEGIN 
	EXEC migrarBI_Tiempo;
	EXEC migrarBI_Ubicacion;	
	EXEC migrarBI_Sucursal;
	EXEC migrarBI_MedioPago;
	EXEC migrarBI_Turno;
	EXEC migrarBI_Ticket;
	EXEC migrarBI_Pago;
	EXEC migrarBI_RangoEtario;
	EXEC migrarBI_Cliente;
	EXEC migrarBI_TicketPorProducto;
	EXEC migrarBI_Empleado;
	EXEC migrarBI_Envio;
	EXEC migrarBI_Producto;
	EXEC migrarBI_ProductoPorCategoria;
	EXEC migrarBI_PromocionAplicada;
	EXEC migrarBI_DetallePago;
	EXEC migrarBI_DtoxPago;
END
GO
EXEC migrarTodoBI

------------------------------------------------------------------------------------------------------------------------
----------------------------------------------- CREACION DE VISTAS -----------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- 1 --
	
GO
CREATE VIEW TicketPromedioMensual AS
SELECT SUM(t.ticket_total)/COUNT(t.id_ticket) AS Promedio_Por_Localidad, ti.año AS año,ti.mes AS mes,u.Localidad 
FROM Pteradata.BI_Ticket t
	JOIN Pteradata.BI_Sucursal s ON t.sucursal_nombre = s.Sucursal_Nombre
	JOIN Pteradata.BI_Ubicacion u ON u.id_direccion = s.Id_Direccion
	JOIN Pteradata.BI_Tiempo ti ON t.ticket_fecha = ti.id_tiempo
GROUP BY u.Localidad, ti.año,ti.mes
ORDER BY año,mes


-- 2 --

GO
CREATE VIEW CantidadUnidadesPromedio AS
SELECT SUM(tp.ticket_det_cantidad)/COUNT(tp.id_ticket) AS Promedio_Productos, tu.id_turno 
FROM Pteradata.BI_TicketPorProducto tp
	JOIN Pteradata.BI_Ticket t ON t.id_ticket = tp.id_ticket
	JOIN Pteradata.BI_Turno tu ON t.ticket_turno = tu.id_turno
GROUP BY tu.id_turno


-- 3 --

GO
CREATE VIEW PorcentajeAnualVentas AS
SELECT COUNT(t.id_ticket) AS Cantidad_Tickets, ti.año AS Año, ti.CUATRIMESTRE AS Cuatrimestre, r.descripcion AS Rango_Etario, e.caja_tipo AS Tipo_De_Caja
FROM Pteradata.BI_Ticket t
	JOIN Pteradata.BI_Sucursal s ON s.Sucursal_Nombre = t.sucursal_nombre
	JOIN Pteradata.BI_Empleado e ON e.sucursal_nombre = s.Sucursal_Nombre
	JOIN Pteradata.BI_RangoEtario r ON r.id_rango_etario = e.id_rango_etario
	JOIN Pteradata.BI_Tiempo ti ON t.ticket_fecha = ti.id_tiempo
GROUP BY ti.año, ti.cuatrimestre,r.descripcion, e.caja_tipo
ORDER BY CUATRIMESTRE, ti.año


-- 4 --

GO
CREATE VIEW CantidadDeVentasPorTurnoPorLocalidadPorMes AS
SELECT COUNT(DISTINCT id_ticket) CantidadDeVentas, tu.id_turno Turno, u.Localidad Localidad, ti.mes Mes 
FROM Pteradata.BI_Ticket t
JOIN Pteradata.BI_Turno tu on t.ticket_turno = tu.id_turno
JOIN Pteradata.BI_Sucursal s on t.sucursal_nombre = s.Sucursal_Nombre
JOIN Pteradata.BI_Ubicacion u on s.Id_Direccion = u.id_direccion
JOIN Pteradata.BI_Tiempo ti ON t.ticket_fecha = ti.id_tiempo
GROUP BY u.Localidad, ti.mes, tu.id_turno
ORDER BY ti.mes


-- 5 --

GO
CREATE VIEW PorcentajeDeDescuento AS
SELECT (1 - SUM(ticket_total) / SUM(ticket_subtotal_productos)) * 100 DescuentoAplicado, ti.mes as Mes 
FROM Pteradata.BI_Ticket t JOIN Pteradata.BI_Tiempo ti ON t.ticket_fecha = ti.id_tiempo
GROUP BY ti.mes
ORDER BY 2


-- 6 -- 
-- tomo que PROMO_APLICADA_DESCUENTO es el precio del producto con el descuento aplicado 

GO
CREATE VIEW Top3CategoriasConMayorDescuentoPorCuatrimestre AS
SELECT top 3 SUM(pa.promocion_dto_aplicado) TotalDescuentosAplicados, ppc.producto_categoria
	FROM Pteradata.BI_PromocionAplicada pa
		JOIN Pteradata.BI_ProductoPorCategoria ppc on ppc.id_producto = pa.id_producto
		JOIN Pteradata.BI_Tiempo t on pa.fecha=t.id_tiempo
	GROUP BY ppc.producto_categoria, t.CUATRIMESTRE


-- 7 --

-- Se crea una tabla temporal para facilitar la creación de la vista
SELECT id_envio INTO #TempEnviosCumplidos
	FROM Pteradata.BI_Envio e
	WHERE e.envio_estado = 'Finalizado' AND CAST(e.fecha_entregado AS DATE) = CAST(e.envio_fecha_programada AS DATE);

GO
CREATE VIEW ProcentajeEnviosCumplidosPorSucursal AS
SELECT DISTINCT COUNT(te.id_envio)*100 / COUNT(e.id_envio), t.sucursal_nombre AS ProcentajeDeCumplimiento
		FROM Pteradata.BI_Envio e
		JOIN #TempEnviosCumplidos te on te.id_envio = e.id_envio
		JOIN Pteradata.BI_Ticket t on t.id_ticket = e.id_ticket 
		GROUP BY t.sucursal_nombre, YEAR(e.envio_fecha_programada), MONTH(e.envio_fecha_programada)	


-- 8 --

GO
CREATE VIEW CantEnviosPorRangoEtarioPorCuatri AS
SELECT COUNT(e.id_envio) cant_envios, r.id_rango_etario, t.cuatrimestre 
	FROM Pteradata.BI_Envio e
		JOIN Pteradata.BI_Cliente c ON c.id_cliente = e.id_cliente
		JOIN Pteradata.BI_RangoEtario r ON r.id_rango_etario = c.id_rango_etario
		JOIN Pteradata.BI_Tiempo t ON t.AÑO = YEAR(e.envio_fecha_programada) AND t.MES = MONTH(e.envio_fecha_programada)
	GROUP BY r.id_rango_etario, t.cuatrimestre 


-- 9 -- 

GO
CREATE VIEW Top5LocalidadesConEnviosMasCaros AS
SELECT TOP 5 u.localidad 
	FROM Pteradata.BI_Cliente c
		JOIN Pteradata.BI_Ubicacion u on u.id_direccion = c.id_direccion
		JOIN Pteradata.BI_Envio e on e.id_cliente = c.id_cliente
	order by e.envio_costo DESC


-- 10 -- 

GO
CREATE VIEW Top3SucursalesXImportePago AS
SELECT TOP 3 t.sucursal_nombre, ti.año, ti.mes
	FROM Pteradata.BI_Ticket t
		right JOIN Pteradata.BI_Pago p ON p.id_ticket = t.id_ticket
		JOIN Pteradata.BI_Tiempo ti ON p.pago_fecha = ti.id_tiempo
		JOIN Pteradata.BI_DetallePago dp ON dp.ID_Pago = p.ID_Pago
	WHERE dp.cant_cuotas > 1
	GROUP BY t.sucursal_nombre, p.id_medio_pago, ti.año, ti.mes
	ORDER BY SUM(p.pago_importe)


---11---

GO
CREATE VIEW promedioImporteXRangoEtario AS
	SELECT re.descripcion AS RangoEtario,CAST(AVG(p.pago_importe/dp.cant_cuotas) AS DECIMAL(18,4)) AS PromedioImporteDeCuota
	FROM Pteradata.BI_Cliente c 
	JOIN Pteradata.BI_DetallePago dp ON dp.id_cliente = c.id_cliente
	JOIN Pteradata.Pago p ON p.ID_Pago = dp.ID_Pago
	JOIN Pteradata.BI_RangoEtario re ON re.id_rango_etario = c.id_rango_etario
	GROUP BY re.descripcion, re.id_rango_etario
	ORDER BY re.id_rango_etario
		

--12--

GO
CREATE VIEW porcentajeDtoAplicadoMP AS
	SELECT DISTINCT mp.Medio_Pago, tm.cuatrimestre, SUM(t.ticket_total_Descuento_aplicado)/SUM(t.ticket_total+t.ticket_total_Descuento_aplicado) * 100 AS porcentaje_dto
	FROM Pteradata.BI_Ticket t 
	JOIN Pteradata.BI_Pago p ON t.id_ticket = p.id_ticket
	JOIN Pteradata.BI_MedioPago mp ON mp.id_medio_pago = p.id_medio_pago
	JOIN Pteradata.BI_Tiempo tm ON p.pago_fecha = tm.id_tiempo
	GROUP BY mp.Medio_Pago, tm.cuatrimestre
	ORDER BY tm.cuatrimestre, mp.Medio_Pago
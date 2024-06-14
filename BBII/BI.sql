----------------------------------------------------------------------------------------------------------------------------
----------------------------------------CREACION DE TABLAS -----------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Pteradata.BI_Tiempo(
	id_tiempo INT PRIMARY KEY IDENTITY(1,1),
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
	Sucursal_Nombre NVARCHAR(255) PRIMARY KEY,
	CUIT NVARCHAR(255),
	Id_Direccion INT,
	FOREIGN KEY(id_direccion) REFERENCES Pteradata.BI_Ubicacion(id_direccion)
);
CREATE TABLE Pteradata.BI_MedioPago (
    id_medio_pago INT PRIMARY KEY,
    Medio_Pago NVARCHAR(255) UNIQUE
);
CREATE TABLE Pteradata.BI_Ticket(
    id_ticket INT PRIMARY KEY,
    sucursal_nombre NVARCHAR(255),
    ticket_numero DECIMAL(18,0),
    ticket_total DECIMAL (18,2),
    ticket_total_envio DECIMAL(18,2),
    ticket_total_Descuento_aplicado DECIMAL(18,2),
    ticket_det_Descuento_medio_pago DECIMAL(18,2),
    ticket_fecha_hora DATETIME,
    ticket_subtotal_productos DECIMAL(18,2),
    FOREIGN KEY (sucursal_nombre) REFERENCES Pteradata.Sucursal(sucursal_nombre),
);
CREATE TABLE Pteradata.BI_Pago(
    ID_Pago INT PRIMARY KEY,
    id_medio_pago INT,
    id_ticket INT,
    pago_fecha INT, 
    pago_importe DECIMAL(18,2),

    FOREIGN KEY(id_medio_pago) REFERENCES Pteradata.BI_MedioPago(id_medio_pago),
	FOREIGN KEY(id_ticket) REFERENCES Pteradata.BI_Ticket(id_ticket)
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
    cliente_nombre NVARCHAR(255),
    cliente_apellido NVARCHAR(255),
    cliente_fecha_registro DATE,
    cliente_telefono DECIMAL (18,0),
    cliente_mail NVARCHAR(255),
    cliente_fecha_nacimiento DATE,
	edad INT,
    cliente_dni DECIMAL(18,0),
	id_rango_etario INT, 
    FOREIGN KEY(id_direccion) REFERENCES Pteradata.BI_Ubicacion(id_direccion),
	FOREIGN KEY(id_rango_etario) REFERENCES Pteradata.BI_RangoEtario(id_rango_etario)
);
CREATE TABLE Pteradata.BI_Turno(
	id_turno INT PRIMARY KEY IDENTITY(1,1),
	turno_hora_inicio TIME,
	turno_hora_fin TIME
);
CREATE TABLE Pteradata.BI_TicketPorProducto(
	id_ticket INT,
	id_producto_marca INT,
	ticket_det_cantidad INT

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

	FOREIGN KEY (id_cliente) REFERENCES Pteradata.BI_Cliente,
	FOREIGN KEY (id_ticket) REFERENCES Pteradata.BI_Ticket
);

------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------MIGRO DATOS--------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
/*  vvvvv PARA MI QUE ESTO ESTA MAL vvvvv
CREATE PROCEDURE migrarBI_Tiempo AS
BEGIN
	INSERT INTO Pteradata.BI_Tiempo(Id_Tiempo,AÑO,CUATRIMESTRE,MES)
	SELECT DISTINCT (YEAR(pago_fecha)*100+MONTH(pago_fecha)),
    YEAR(pago_fecha),
    CASE 
        WHEN MONTH(pago_fecha) BETWEEN 1 AND 4 THEN 1
        WHEN MONTH(pago_fecha) BETWEEN 4 AND 8 THEN 2
        WHEN MONTH(pago_fecha) BETWEEN 8 AND 12 THEN 3
    END,
    MONTH(pago_fecha)
FROM 
    Pteradata.Pago
ORDER BY 
    MONTH(pago_fecha);
END
*/
GO
CREATE PROCEDURE migrarBI_Tiempo AS
BEGIN 
	INSERT INTO Pteradata.BI_Tiempo(año, mes, cuatrimestre)
	SELECT DISTINCT YEAR(pago_fecha), MONTH(pago_fecha),
		CASE 
			WHEN MONTH(pago_fecha) BETWEEN 1 AND 4  THEN 1
			WHEN MONTH(pago_fecha) BETWEEN 5 AND 8  THEN 2
			WHEN MONTH(pago_fecha) BETWEEN 9 AND 12 THEN 3
		END 
		FROM Pteradata.Pago
	UNION 
	SELECT DISTINCT YEAR(fecha_entregado), MONTH(fecha_entregado),
		CASE 
			WHEN MONTH(fecha_entregado) BETWEEN 1 AND 4  THEN 1
			WHEN MONTH(fecha_entregado) BETWEEN 5 AND 8  THEN 2
			WHEN MONTH(fecha_entregado) BETWEEN 9 AND 12 THEN 3
		END
		FROM Pteradata.Envio
	UNION
	SELECT DISTINCT YEAR(envio_fecha_programada), MONTH(envio_fecha_programada),
		CASE 
			WHEN MONTH(envio_fecha_programada) BETWEEN 1 AND 4  THEN 1
			WHEN MONTH(envio_fecha_programada) BETWEEN 5 AND 8  THEN 2
			WHEN MONTH(envio_fecha_programada) BETWEEN 9 AND 12 THEN 3
		END
		FROM Pteradata.Envio	
	UNION 
	SELECT DISTINCT YEAR(ticket_fecha_hora), MONTH(ticket_fecha_hora),
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
	FROM Pteradata.Direccion d JOIN Pteradata.Localidad l ON d.id_localidad = l.id_localidad
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
CREATE PROCEDURE migrarBI_Ticket AS
BEGIN
	INSERT INTO Pteradata.BI_Ticket(id_ticket,sucursal_nombre,ticket_numero,ticket_total,ticket_total_envio,ticket_total_Descuento_aplicado,ticket_fecha_hora,ticket_subtotal_productos)
	SELECT DISTINCT id_ticket,sucursal_nombre,ticket_numero,ticket_total,ticket_total_envio,ticket_total_Descuento_aplicado,ticket_fecha_hora,ticket_subtotal_productos
	FROM Pteradata.Ticket
END
GO
CREATE PROCEDURE migrarBI_Pago AS
BEGIN
	INSERT INTO Pteradata.BI_Pago(ID_Pago,id_medio_pago,id_ticket,pago_fecha,pago_importe)
	SELECT DISTINCT ID_Pago,id_medio_pago,id_ticket,(YEAR(pago_fecha)*100+MONTH(pago_fecha)) AS pago_fecha,pago_importe
	FROM Pteradata.Pago
END
GO
CREATE PROCEDURE migrarBI_RangoEstario AS
BEGIN
	INSERT INTO Pteradata.BI_RangoEtario(edad_minima,edad_maxima,descripcion)
	VALUES (0,25,'Menores de 25'),(26,35,'Mayores de 25 y menores de 35'),(36,50, 'Mayores de 35 y menores de 50'),(51,150,'Mayores de 50')
END
GO
CREATE PROCEDURE migrarBI_Cliente AS
BEGIN
	INSERT INTO Pteradata.BI_Cliente(id_cliente,id_direccion,cliente_nombre,cliente_apellido,cliente_fecha_registro,cliente_telefono,cliente_mail,cliente_fecha_nacimiento,edad,cliente_dni, id_rango_etario)
	SELECT DISTINCT id_cliente,id_direccion,cliente_nombre,cliente_apellido,cliente_fecha_registro,cliente_telefono,cliente_mail,cliente_fecha_nacimiento, 
			DATEDIFF(YEAR,cliente_fecha_nacimiento,GETDATE()) AS edad, cliente_dni, r.id_rango_etario
	FROM Pteradata.Cliente
		JOIN Pteradata.BI_RangoEtario r on r.edad_minima <= DATEDIFF(YEAR,cliente_fecha_nacimiento,GETDATE()) and r.edad_maxima >= DATEDIFF(YEAR,cliente_fecha_nacimiento,GETDATE()) 
END
GO
CREATE PROCEDURE migrarBI_Turno AS
BEGIN
	INSERT INTO Pteradata.BI_Turno (turno_hora_inicio,turno_hora_fin)
	VALUES('08:00:00','12:00:00'), ('12:00:00','16:00:00'),('16:00:00','20:00:00')
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
	envio_hora_inicio, envio_hora_fin, fecha_entregado)
	SELECT e.id_envio, e.id_cliente, e.id_ticket, ee.envio_estado, e.envio_costo, e.envio_fecha_programada,
					e.envio_hora_inicio, e.envio_hora_fin, e.fecha_entregado
		FROM Pteradata.Envio e
		JOIN Pteradata.EnvioEstado ee on ee.id_envio_estado = e.id_envio_estado
END
GO
CREATE PROCEDURE migrarTodoBI AS
BEGIN 
	EXEC migrarBI_Tiempo;
	EXEC migrarBI_Ubicacion;	
	EXEC migrarBI_Sucursal;
	EXEC migrarBI_MedioPago;
	EXEC migrarBI_Ticket;
	EXEC migrarBI_Pago;
	EXEC migrarBI_RangoEstario;
	EXEC migrarBI_Cliente;
	EXEC migrarBI_Turno;
	EXEC migrarBI_TicketPorProducto;
	EXEC migrarBI_Empleado;
	EXEC migrarBI_Envio;
END
--EXEC migrarTodoBI
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------CREACION DE VISTAS------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- 1 --
-- No estoy seguro de si ticket_total es el total total...
-- Estan todas las sucursales en la mimsa localidad ? 
/*
Valor promedio de las ventas (en $) según la
localidad, año y mes. Se calcula en función de la sumatoria del importe de las
ventas sobre el total de las mismas.
*/
CREATE VIEW TicketPromedioMensual AS
SELECT SUM(t.ticket_total)/COUNT(t.id_ticket) AS Promedio_Por_Localidad, YEAR(t.ticket_fecha_hora) AS año,MONTH(t.ticket_fecha_hora) AS mes,u.Localidad 
FROM Pteradata.BI_Ticket t
	JOIN Pteradata.BI_Sucursal s ON t.sucursal_nombre = s.Sucursal_Nombre
	JOIN Pteradata.BI_Ubicacion u ON u.id_direccion = s.Id_Direccion
GROUP BY u.Localidad, YEAR(t.ticket_fecha_hora),MONTH(t.ticket_fecha_hora)
ORDER BY año,mes

-- 2 --
-- 5,5,5 mmmmm...
/*
Cantidad unidades promedio. 
Cantidad promedio de artículos que se venden en función de los tickets según 
el turno para cada cuatrimestre de cada año. Se obtiene sumando la cantidad de 
artículos de todos los tickets correspondientes sobre la cantidad de tickets. 
Si un producto tiene más de una unidad en un ticket, para el indicador se 
consideran todas las unidades

*/
CREATE VIEW CantidadUnidadesPromedio AS
SELECT SUM(tp.ticket_det_cantidad)/COUNT(tp.id_ticket) AS Promedio_Productos, tu.id_turno 
FROM Pteradata.BI_TicketPorProducto tp
	JOIN Pteradata.BI_Ticket t ON t.id_ticket = tp.id_ticket
	JOIN Pteradata.BI_Turno tu ON CAST(t.ticket_fecha_hora AS TIME) BETWEEN tu.turno_hora_inicio AND turno_hora_fin
GROUP BY tu.id_turno

-- 3 --
-- Un ticket es una venta? 
/*
Porcentaje anual de ventas registradas por rango etario del empleado según el
tipo de caja para cada cuatrimestre. Se calcula tomando la cantidad de ventas
correspondientes sobre el total de ventas anual.
*/
CREATE VIEW PorcentajeAnualVentas AS
SELECT COUNT(t.id_ticket) AS Cantidad_Tickets, YEAR(t.ticket_fecha_hora) AS Año, ti.CUATRIMESTRE AS Cuatrimestre, r.descripcion AS Rango_Etario, e.caja_tipo AS Tipo_De_Caja
FROM Pteradata.BI_Ticket t
	JOIN Pteradata.BI_Sucursal s ON s.Sucursal_Nombre = t.sucursal_nombre
	JOIN Pteradata.BI_Empleado e ON e.sucursal_nombre = s.Sucursal_Nombre
	JOIN Pteradata.BI_RangoEtario r ON r.id_rango_etario = e.id_rango_etario
	JOIN Pteradata.BI_Tiempo ti ON ti.mes = MONTH(t.ticket_fecha_hora) AND ti.año = YEAR(t.ticket_fecha_hora)
GROUP BY YEAR(t.ticket_fecha_hora), ti.cuatrimestre,r.descripcion, e.caja_tipo
ORDER BY CUATRIMESTRE, YEAR(t.ticket_fecha_hora)


-- 4
-- Cantidad de ventas registradas por turno para cada localidad según el mes de
-- cada año.
CREATE VIEW CantidadDeVentasPorTurnoPorLocalidadPorMes AS
SELECT COUNT(DISTINCT id_ticket) CantidadDeVentas, tu.id_turno Turno, u.Localidad Localidad, MONTH(t.ticket_fecha_hora) Mes FROM Pteradata.BI_Ticket t
JOIN Pteradata.BI_Turno tu on CONVERT(TIME, t.ticket_fecha_hora) BETWEEN tu.turno_hora_inicio AND tu.turno_hora_fin
JOIN Pteradata.BI_Sucursal s on t.sucursal_nombre = s.Sucursal_Nombre
JOIN Pteradata.BI_Ubicacion u on s.Id_Direccion = u.id_direccion
GROUP BY u.Localidad, MONTH(t.ticket_fecha_hora), tu.id_turno
ORDER BY MONTH(t.ticket_fecha_hora)

-- 5
-- Porcentaje de descuento aplicados en función del total de los tickets según el
-- mes de cada año.
CREATE VIEW PorcentajeDeDescuento AS
SELECT (1 - SUM(ticket_total) / SUM(ticket_subtotal_productos)) * 100 DescuentoAplicado, MONTH(ticket_fecha_hora) Mes 
FROM Pteradata.BI_Ticket
GROUP BY MONTH(ticket_fecha_hora)
ORDER BY 2

-- 6
-- Las tres categorías de productos con mayor descuento aplicado a partir de
-- promociones para cada cuatrimestre de cada año.
--SELECT (1 - SUM(ticket_total) / SUM(ticket_subtotal_productos)) * 100 DtoAplicado, Producto_Categoria FROM Pteradata.Ticket
--JOIN Pteradata.TicketPorProducto tpp

--SELECT * FROM Pteradata.Ticket
--SELECT ticket_subtotal_productos - ticket_total - ticket_total_envio - ticket_total_Descuento_aplicado - ticket_det_Descuento_medio_pago FROM Pteradata.Ticket






-----
--7-- Porcentaje de cumplimiento de envíos en los tiempos programados por sucursal por año/mes (desvío)
-----
SELECT id_envio INTO #TempEnviosCumplidosPorSucursal
	FROM Pteradata.BI_Envio e
	WHERE e.envio_estado = 'Finalizado' AND CAST(e.fecha_entregado AS DATE) = CAST(e.envio_fecha_programada AS DATE)

GO
CREATE VIEW ProcentajeEnviosCumplidosPorSucursal AS
SELECT COUNT(te.id_envio)*100 / COUNT(e.id_envio) AS ProcentajeDeCumplimiento
     FROM Pteradata.BI_Envio e
		JOIN #TempEnviosCumplidosPorSucursal te on te.id_envio = e.id_envio
		JOIN Pteradata.BI_Ticket t on t.id_ticket = e.id_ticket 
	 GROUP BY t.sucursal_nombre, YEAR(e.envio_fecha_programada), MONTH(e.envio_fecha_programada)	

-----
--8-- Cantidad de envíos por rango etario de clientes para cada cuatrimestre de cada año.-----
GO
CREATE VIEW CantEnviosPorRangoEtarioPorCuatri AS
SELECT COUNT(e.id_envio) cant_envios, r.id_rango_etario, t.cuatrimestre 
	FROM Pteradata.BI_Envio e
		JOIN Pteradata.BI_Cliente c ON c.id_cliente = e.id_cliente
		JOIN Pteradata.BI_RangoEtario r ON r.id_rango_etario = c.id_rango_etario
		JOIN Pteradata.BI_Tiempo t ON t.AÑO = YEAR(e.envio_fecha_programada) AND t.MES = MONTH(e.envio_fecha_programada)
	GROUP BY r.id_rango_etario, t.cuatrimestre 

-----
--9-- Las 5 localidades (tomando la localidad del cliente) con mayor costo de envío.
-----
CREATE VIEW Top5LocalidadesConEnviosMasCaros AS
SELECT TOP 5 u.localidad 
	FROM Pteradata.BI_Cliente c
		JOIN Pteradata.BI_Ubicacion u on u.id_direccion = c.id_direccion
		JOIN Pteradata.BI_Envio e on e.id_cliente = c.id_cliente
	order by e.envio_costo DESC



--10--
CREATE VIEW Top3SucursalesCuotas AS
WITH PagosPorSucursal AS (
    SELECT 
        mp.Medio_Pago,
        ti.AÑO,
        ti.MES,
        s.Sucursal_Nombre,
        SUM(p.pago_importe) AS Importe_Total,
        ROW_NUMBER() OVER (PARTITION BY mp.Medio_Pago, ti.AÑO, ti.MES ORDER BY SUM(p.pago_importe) DESC) AS Sucursal_Ranking
    FROM 
        Pteradata.BI_Pago p 
    JOIN 
        Pteradata.BI_Ticket t ON p.id_ticket = t.id_ticket
    JOIN 
        Pteradata.BI_Sucursal s ON t.sucursal_nombre = s.Sucursal_Nombre
    JOIN 
        Pteradata.BI_MedioPago mp ON p.id_medio_pago = mp.id_medio_pago
    JOIN 
        Pteradata.BI_Tiempo ti ON ti.id_tiempo = p.pago_fecha
    WHERE 
        mp.Medio_Pago <> 'Efectivo'
    GROUP BY 
        mp.Medio_Pago, ti.AÑO, ti.MES, s.Sucursal_Nombre
)
SELECT
    Medio_Pago,
    AÑO,
    MES,
    Sucursal_Nombre,
    Importe_Total
FROM 
    PagosPorSucursal
WHERE 
    Sucursal_Ranking <= 3;

GO

---11---

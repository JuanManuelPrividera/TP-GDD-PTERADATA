----------------------------------------CREACION DE TABLAS -----------------------------------------------------------------
CREATE TABLE Pteradata.BI_Tiempo(
	Id_Tiempo INT PRIMARY KEY,
	AÑO INT,
	CUATRIMESTRE INT,
	MES INT
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
    FOREIGN KEY (sucursal_nombre) REFERENCES Pteradata.Sucursal (sucursal_nombre),
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
    FOREIGN KEY(id_direccion) REFERENCES Pteradata.BI_Ubicacion(id_direccion)
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
CREATE TABLE Pteradata.BI_RangoEtario(
	id_rango_etario INT PRIMARY KEY IDENTITY(1,1),
	edad_minima INT,
	edad_maxima INT,
	descripcion NVARCHAR(255)
);
CREATE TABLE Pteradata.BI_Empleado(
	legajo_empleado INT,
	sucursal_nombre NVARCHAR(255),
	id_rango_etario INT,
	caja_tipo NVARCHAR(255),

	FOREIGN KEY(id_rango_etario) REFERENCES Pteradata.BI_RangoEtario(id_rango_etario)
);

-----------------------------------------------MIGRO DATOS--------------------------------------------------------------
GO
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
-- A ESTA MIGRACION LE HACE FALTA AGREGAR UNIONS CON EL RESTO DE FECHAS Q HAY A MEDIDA QUE LAS NECESITEMOS
GO
CREATE PROCEDURE migrarBI_Ubicacion AS
BEGIN
	INSERT INTO Pteradata.BI_Ubicacion(id_direccion,Direccion,Localidad,Provincia)
	SELECT DISTINCT d.id_direccion, d.domicilio, l.localidad_nombre,p.provincia_nombre
	FROM Pteradata.Direccion d JOIN Pteradata.Localidad l ON d.id_localidad = l.id_localidad
							   JOIN Pteradata.Provincia p ON l.id_provincia = p.id_provincia
							 
END
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
CREATE PROCEDURE migrarBI_Cliente AS
BEGIN
	INSERT INTO Pteradata.BI_Cliente(id_cliente,id_direccion,cliente_nombre,cliente_apellido,cliente_fecha_registro,cliente_telefono,cliente_mail,cliente_fecha_nacimiento,edad,cliente_dni)
	SELECT DISTINCT id_cliente,id_direccion,cliente_nombre,cliente_apellido,cliente_fecha_registro,cliente_telefono,cliente_mail,cliente_fecha_nacimiento, 
			DATEDIFF(YEAR,cliente_fecha_nacimiento,GETDATE()) AS edad, cliente_dni
	FROM Pteradata.Cliente
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
CREATE PROCEDURE migrarBI_RangoEstario AS
BEGIN
	INSERT INTO Pteradata.BI_RangoEtario(edad_minima,edad_maxima,descripcion)
	VALUES (0,25,'Menores de 25'),(26,35,'Mayores de 25 y menores de 35'),(36,50, 'Mayores de 35 y menores de 50'),(51,150,'Mayores de 50')
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


-------------------------------------------------CREACION DE VISTAS--------------------------------------------------------
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
	JOIN Pteradata.BI_Tiempo ti ON ti.MES = MONTH(t.ticket_fecha_hora) AND ti.AÑO = YEAR(t.ticket_fecha_hora)
GROUP BY YEAR(t.ticket_fecha_hora), ti.CUATRIMESTRE,r.descripcion, e.caja_tipo
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
CREATE VIEW PorcentajeDeDescuento
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
        Pteradata.BI_Tiempo ti ON ti.Id_Tiempo = p.pago_fecha
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

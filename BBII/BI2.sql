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

CREATE FUNCTION Pteradata.isEntregadoATiempo (@fechaProgramada DATETIME, @fechaEntrega DATETIME) RETURNS INT AS
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

CREATE FUNCTION Pteradata.getImportePorCuota (@importe_total DECIMAL(10,2), @cant_cuotas INT) RETURNS DECIMAL(10,2) AS
BEGIN
	DECLARE @importe_por_cuota DECIMAL (10,2)
	IF(@cant_cuotas = 1)
		SET @importe_por_cuota = @importe_total
	ELSE 
		SET @importe_por_cuota = @importe_total / @cant_cuotas

	RETURN @importe_por_cuota
END

GO
-----------------------------------
-- CREACI�N TABLA DE DIMENSIONES --
-----------------------------------
CREATE TABLE Pteradata.BI_DimProvincia (
	id_provincia INT IDENTITY(1, 1) PRIMARY KEY,
	nombre NVARCHAR(255)
);

GO

CREATE TABLE Pteradata.BI_DimLocalidad (
	id_localidad INT IDENTITY(1, 1) PRIMARY KEY,
	id_provincia INT REFERENCES Pteradata.BI_DimProvincia,
	nombre NVARCHAR(255)
);

GO

CREATE TABLE Pteradata.BI_DimSucursal (
	id_sucursal INT IDENTITY(1, 1) PRIMARY KEY,
	id_localidad INT REFERENCES Pteradata.BI_DimLocalidad,
	nombre NVARCHAR(255),
);

GO

CREATE TABLE Pteradata.BI_DimCuatrimestre (
	id_cuatrimestre INT CHECK (id_cuatrimestre IN (1,2,3,4)) PRIMARY KEY,
);

GO

CREATE TABLE Pteradata.BI_DimMes (
	id_mes INT IDENTITY(1,1) PRIMARY KEY,
	id_cuatrimestre INT REFERENCES Pteradata.BI_DimCuatrimestre,
	nombre NVARCHAR(255)
);

GO

CREATE TABLE Pteradata.BI_DimA�o (
	id_a�o INT PRIMARY KEY,
);

GO

CREATE TABLE Pteradata.BI_DimTiempo (
	id_tiempo INT IDENTITY(1, 1) PRIMARY KEY,
	id_a�o INT REFERENCES Pteradata.BI_DimA�o,
	id_mes INT REFERENCES Pteradata.BI_DimMes,
);

GO

CREATE TABLE Pteradata.BI_DimTurno (
	id_turno INT IDENTITY(1,1) PRIMARY KEY,
	nombre NVARCHAR(255),
	hora_inicio TIME,
	hora_fin TIME
);

GO

CREATE TABLE Pteradata.BI_DimRangoEtario (
	id_rango_etario INT IDENTITY(1,1) PRIMARY KEY,
	nombre NVARCHAR(255),
	edad_inicial INT,
	edad_final INT
);

GO

CREATE TABLE Pteradata.BI_DimCliente (
	id_cliente INT IDENTITY(1,1) PRIMARY KEY,
	id_rango_etario INT REFERENCES Pteradata.BI_DimRangoEtario,
	id_localidad INT REFERENCES Pteradata.BI_DimLocalidad
);

GO

CREATE TABLE Pteradata.BI_DimCategoria (
	id_categoria INT IDENTITY(1,1) PRIMARY KEY,
	nombre NVARCHAR(255)
);

GO

CREATE TABLE Pteradata.BI_DimMedioPago (
	id_medio_pago INT IDENTITY(1,1) PRIMARY KEY,
	descripcion NVARCHAR(255)
);

GO

CREATE TABLE Pteradata.BI_DimTipoCaja (
	id_tipo_caja INT IDENTITY(1, 1) PRIMARY KEY,
	descripcion NVARCHAR(255)
);

GO
------------------------------
-- CREACI�N TABLA DE HECHOS --
------------------------------
CREATE TABLE Pteradata.BI_HechosVentas (
	id_hechos_ventas INT IDENTITY(1, 1) PRIMARY KEY,
	id_tiempo INT REFERENCES Pteradata.BI_DimTiempo,
	id_turno INT REFERENCES Pteradata.BI_DimTurno,
	id_localidad_sucursal INT REFERENCES Pteradata.BI_DimLocalidad,
	id_rango_etario_empleado INT REFERENCES Pteradata.BI_DimRangoEtario,
	id_tipo_caja INT REFERENCES Pteradata.BI_DimTipoCaja,
	
	monto_total DECIMAL(10, 2),
	porcentaje_descuento DECIMAL(3, 2),
	descuento_total DECIMAL(10, 2),
	cantidad_articulos INT
);

GO

CREATE TABLE Pteradata.BI_HechosEnvios (
	id_hechos_envios INT IDENTITY(1, 1) PRIMARY KEY,
	id_tiempo INT REFERENCES Pteradata.BI_DimTiempo,
	id_sucursal INT REFERENCES Pteradata.BI_DimSucursal,
	id_cliente INT REFERENCES Pteradata.BI_DimCliente,

	costo DECIMAL(10, 2),
	entregado_a_tiempo INT CHECK (entregado_a_tiempo IN (0, 1))
);

GO

CREATE TABLE Pteradata.BI_HechosPromocion (
	id_hechos_promocion INT IDENTITY(1, 1) PRIMARY KEY,
	id_tiempo INT REFERENCES Pteradata.BI_DimTiempo,
	id_categoria INT REFERENCES Pteradata.BI_DimCategoria,

	descuento_aplicado DECIMAL(10, 2)
);

GO

CREATE TABLE Pteradata.BI_HechosPagos (
	id_hechos_pagos INT IDENTITY(1, 1) PRIMARY KEY,
	id_tiempo INT REFERENCES Pteradata.BI_DimTiempo,
	id_sucursal INT REFERENCES Pteradata.BI_DimSucursal,
	id_medio_pago INT REFERENCES Pteradata.BI_DimMedioPago,
	id_rango_etario_cliente INT REFERENCES Pteradata.BI_DimRangoEtario,

	importe_total DECIMAL(10, 2),
	importe_por_cuota DECIMAL(10, 2),
	descuento_aplicado DECIMAL(10, 2)
);

GO


--------------------------------
-- MIGRACI�N TABLAS DIMENSI�N --
--------------------------------
CREATE PROCEDURE migrar_BI_DimProvincia AS
BEGIN
	INSERT INTO Pteradata.BI_DimProvincia
	SELECT DISTINCT provincia_nombre FROM Pteradata.Provincia
END

GO

CREATE PROCEDURE migrar_BI_DimLocalidad AS
BEGIN
	INSERT INTO Pteradata.BI_DimLocalidad
	SELECT DISTINCT localidad_nombre, provincia_nombre FROM Pteradata.Localidad l
		JOIN Pteradata.Provincia p on p.id_provincia = l.id_provincia
END

GO

CREATE PROCEDURE migrar_BI_DimSucursal AS
BEGIN
	INSERT INTO Pteradata.BI_DimSucursal
	SELECT DISTINCT sucursal_nombre, dl.id_localidad FROM Pteradata.Sucursal s
 		JOIN Pteradata.Direccion d ON d.id_direccion = s.id_direccion
		JOIN Pteradata.Localidad l ON l.id_localidad = d.id_localidad
		JOIN Pteradata.BI_DimLocalidad dl ON dl.nombre = l.localidad_nombre

END

GO

CREATE PROCEDURE migrar_BI_DimCuatrimestre AS
BEGIN
	INSERT INTO Pteradata.BI_DimCuatrimestre (id_cuatrimestre) VALUES (1),(2),(3),(4)
END

GO

CREATE PROCEDURE migrar_BI_DimMes AS
BEGIN
INSERT INTO Pteradata.BI_DimMes (id_mes, id_cuatrimestre, nombre) VALUES 
	(1, 1, 'Enero'), 
	(2, 1, 'Febrero'), 
	(3, 1, 'Marzo'),
	(4, 2, 'Abril'), 
	(5, 2, 'Mayo'), 
	(6, 2, 'Junio'),
	(7, 3, 'Julio'), 
	(8, 3, 'Agosto'), 
	(9, 3, 'Septiembre'),
	(10, 4, 'Octubre'), 
	(11, 4, 'Noviembre'), 
	(12, 4, 'Diciembre');
END

GO

CREATE PROCEDURE migrar_BI_DimA�o AS
BEGIN
	INSERT INTO Pteradata.BI_DimA�o(id_a�o)
	SELECT DISTINCT a�o FROM (
		SELECT YEAR(ticket_fecha_hora) a�o FROM Pteradata.Ticket
		UNION
		SELECT YEAR(envio_fecha_programada) a�o FROM Pteradata.Envio
		UNION
		SELECT YEAR(fecha_entregado) a�o FROM Pteradata.Envio
		UNION
		SELECT YEAR(pago_fecha) a�o FROM Pteradata.Pago
	) a�os
END

GO

CREATE PROCEDURE migrar_BI_DimTiempo AS
BEGIN
	INSERT INTO Pteradata.BI_DimTiempo
	SELECT da.id_a�o, dm.id_mes FROM Pteradata.BI_DimA�o da
		JOIN Pteradata.BI_DimMes dm ON 1=1  
END

GO

CREATE PROCEDURE migrar_BI_DimTurno AS
BEGIN
	INSERT INTO Pteradata.BI_DimTurno (nombre,hora_inicio,hora_fin) VALUES 
		('Ma�ana', '08:00:00','12:00:00'),
		('Tarde', '12:00:01','16:00:00'),
		('Noche', '16:00:01','20:00:00'),
		('Otro', '20:00:01','07:59:99') 
END
/*
Creo el turno Otro ya que hay tickets que se emiten en horarios fuera de turno
*/
GO

CREATE PROCEDURE migrar_BI_DimRangoEtario AS
BEGIN
	INSERT INTO Pteradata.BI_DimRangoEtario(nombre,edad_inicial,edad_final) VALUES 
		('Menor a 25', 0, 25),
		('Entre 25 y 35', 25, 35),
		('Entre 35 y 50', 35, 50),
		('Mayor a 50', 50, 100)

END

GO

CREATE PROCEDURE migrar_BI_DimCliente AS
BEGIN
	INSERT INTO Pteradata.BI_DimCliente (id_rango_etario,id_localidad)
	SELECT Pteradata.getRangoEtario(c.cliente_fecha_nacimiento), dl.id_localidad FROM Pteradata.Cliente c
	JOIN Pteradata.Direccion d ON d.id_direccion = c.id_direccion
	JOIN Pteradata.Localidad l ON l.id_localidad = d.id_localidad
	JOIN Pteradata.BI_DimLocalidad dl ON l.localidad_nombre = dl.nombre
END

GO

CREATE PROCEDURE migrar_BI_DimCategoria AS
BEGIN
	INSERT INTO Pteradata.BI_DimCategoria(nombre)
	SELECT producto_categoria FROM Pteradata.Categoria
END

GO

CREATE PROCEDURE migrar_BI_DimMedioPago AS
BEGIN
	INSERT INTO Pteradata.BI_DimMedioPago(descripcion)
	SELECT pago_medio_pago FROM Pteradata.MedioPago
END

GO

CREATE PROCEDURE migrar_BI_DimTipoCaja AS
BEGIN
	INSERT INTO Pteradata.BI_DimTipoCaja(descripcion)
	SELECT caja_tipo FROM Pteradata.CajaTipo
END

GO

----------------------------
-- MIGRACI�N TABLA HECHOS --
----------------------------

CREATE PROCEDURE migrar_BI_HechosEnvio AS
BEGIN
	INSERT INTO Pteradata.BI_HechosEnvios 
	SELECT dt.id_tiempo, ds.id_sucursal, dc.id_cliente, e.envio_costo, Pteradata.isEntregadoATiempo(e.envio_fecha_programada, e.fecha_entregado)
		FROM Pteradata.Envio e
			JOIN Pteradata.BI_DimTiempo dt ON dt.id_a�o = YEAR(e.envio_fecha_programada) AND dt.id_mes = MONTH(e.envio_fecha_programada)
			JOIN Pteradata.Ticket t ON t.id_ticket = e.id_ticket
			JOIN Pteradata.BI_DimSucursal ds ON ds.nombre = t.sucursal_nombre
			JOIN Pteradata.Cliente c ON c.id_cliente = e.id_cliente
			JOIN Pteradata.Direccion d ON d.id_direccion = c.id_direccion
			JOIN Pteradata.Localidad l ON L.id_localidad = d.id_localidad
			JOIN Pteradata.Provincia p ON p.id_provincia = l.id_provincia
			JOIN Pteradata.BI_DimProvincia dp ON dp.nombre = p.provincia_nombre
			JOIN Pteradata.BI_DimLocalidad dl ON dl.nombre = l.localidad_nombre AND dl.id_provincia = dp.id_provincia
			JOIN Pteradata.BI_DimCliente dc ON dc.id_rango_etario = Pteradata.getRangoEtario(c.cliente_fecha_nacimiento) AND dc.id_localidad =  dl.id_localidad
END

GO

CREATE PROCEDURE migrar_BI_HechosVentas AS
BEGIN
	INSERT INTO Pteradata.BI_HechosVentas
	SELECT dt.id_tiempo, Pteradata.getTurno(t.ticket_fecha_hora), ds.id_localidad, Pteradata.getRangoEtario(e.empleado_fecha_nacimiento), 
			dtc.id_tipo_caja, t.ticket_total, (t.ticket_total_Descuento_aplicado*100)/t.ticket_subtotal_productos, t.ticket_total_Descuento_aplicado,
			SUM(tp.ticket_det_cantidad)
	FROM Pteradata.Ticket t
		JOIN Pteradata.BI_DimTiempo dt ON dt.id_a�o = YEAR(t.ticket_fecha_hora) AND dt.id_mes = MONTH(t.ticket_fecha_hora)
		JOIN Pteradata.Sucursal s ON t.sucursal_nombre = s.sucursal_nombre
		JOIN Pteradata.BI_DimSucursal ds ON ds.nombre = s.sucursal_nombre
		JOIN Pteradata.Empleado e ON e.legajo_empleado = t.legajo_empleado
		JOIN Pteradata.Caja c ON c.id_caja = t.id_caja
		JOIN Pteradata.CajaTipo ct ON ct.id_caja_tipo = c.id_caja_tipo
		JOIN Pteradata.BI_DimTipoCaja dtc ON dtc.descripcion = ct.caja_tipo
		JOIN Pteradata.TicketPorProducto tp ON tp.id_ticket = t.id_ticket
		
END

GO

CREATE PROCEDURE migrar_BI_HechosPagos AS
BEGIN
	INSERT INTO Pteradata.BI_HechosPagos
	SELECT dt.id_tiempo, ds.id_sucursal, dmp.id_medio_pago, Pteradata.getRangoEtario(c.cliente_fecha_nacimiento),
	p.pago_importe, Pteradata.getImportePorCuota(p.pago_importe, dp.cant_cuotas), t.ticket_det_Descuento_medio_pago
	FROM Pteradata.Pago p
		JOIN Pteradata.BI_DimTiempo dt ON dt.id_a�o = YEAR(p.pago_fecha) AND dt.id_mes = MONTH(p.pago_fecha) 
		JOIN Pteradata.Ticket t ON t.id_ticket = p.id_ticket
		JOIN Pteradata.BI_DimSucursal ds ON ds.nombre = t.sucursal_nombre
		JOIN Pteradata.MedioPago mp ON p.id_medio_pago = mp.id_medio_pago
		JOIN Pteradata.BI_DimMedioPago dmp ON dmp.descripcion = mp.pago_medio_pago
		JOIN Pteradata.DetallePago dp ON dp.ID_pago = p.ID_pago
		JOIN Pteradata.Cliente c ON c.id_cliente = dp.id_cliente

END






----------------------------
--   CREACION DE VISTAS   --
----------------------------


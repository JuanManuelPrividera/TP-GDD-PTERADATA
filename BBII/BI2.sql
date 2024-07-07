-- Funciones auxiliares
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

-- Creación tablas de Dimensiones --
CREATE TABLE Pteradata.BI_DimProvincia (
	id_provincia INT IDENTITY(1, 1) PRIMARY KEY,
	nombre NVARCHAR(255)
);

GO

CREATE TABLE Pteradata.BI_DimLocalidad (
	id_localidad INT IDENTITY(1, 1) PRIMARY KEY,
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

CREATE TABLE Pteradata.BI_DimAño (
	id_año INT PRIMARY KEY,
);

GO

CREATE TABLE Pteradata.BI_DimTiempo (
	id_tiempo INT IDENTITY(1, 1) PRIMARY KEY,
	id_año INT REFERENCES Pteradata.BI_DimAño,
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

-- Creación Tablas de Hechos --
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


-- Migracion de tabla de dimensiones
CREATE PROCEDURE migrar_BI_DimProvincia AS
BEGIN
	INSERT INTO Pteradata.BI_DimProvincia
	SELECT DISTINCT provincia_nombre FROM Pteradata.Provincia
END

GO

CREATE PROCEDURE migrar_BI_DimLocalidad AS
BEGIN
	INSERT INTO Pteradata.BI_DimLocalidad
	SELECT DISTINCT localidad_nombre FROM Pteradata.Localidad
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

CREATE PROCEDURE migrar_BI_DimAño AS
BEGIN
	INSERT INTO Pteradata.BI_DimAño(id_año)
	SELECT DISTINCT año FROM (
		SELECT YEAR(ticket_fecha_hora) año FROM Pteradata.Ticket
		UNION
		SELECT YEAR(envio_fecha_programada) año FROM Pteradata.Envio
		UNION
		SELECT YEAR(fecha_entregado) año FROM Pteradata.Envio
	) años
END

GO

CREATE PROCEDURE migrar_BI_DimTiempo AS
BEGIN
	INSERT INTO Pteradata.BI_DimTiempo
	SELECT da.id_año, dm.id_mes FROM Pteradata.BI_DimAño da
		JOIN Pteradata.BI_DimMes dm ON 1=1  
END

GO

CREATE PROCEDURE migrar_BI_DimTurno AS
BEGIN
	INSERT INTO Pteradata.BI_DimTurno (nombre,hora_inicio,hora_fin) VALUES 
		('Mañana', '08:00:00','12:00:00'),
		('Tarde', '12:00:01','16:00:00'),
		('Noche', '16:00:01','20:00:00')
END

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
	SELECT Pteradata.getRangoEtario(c.cliente_fecha_nacimiento) FROM Pteradata.Cliente c
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
-- Migracion tablas de hechos
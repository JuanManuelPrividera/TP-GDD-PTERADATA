----------------------------------------CREACION DE TABLAS -----------------------------------------------------------------
CREATE TABLE Pteradata.BI_Tiempo(
	Id_Tiempo INT PRIMARY KEY,
	A�O INT,
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


-----------------------------------------------MIGRO DATOS--------------------------------------------------------------
GO
CREATE PROCEDURE migrarBI_Tiempo AS
BEGIN
	INSERT INTO Pteradata.BI_Tiempo(Id_Tiempo,A�O,MES)
	SELECT DISTINCT (YEAR(pago_fecha)*100+MONTH(pago_fecha) ),YEAR(pago_fecha),MONTH(pago_fecha)
	FROM Pteradata.Pago
	ORDER BY MONTH(pago_fecha)
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
-------------------------------------------------CREACION DE VISTAS--------------------------------------------------------
-- 1 --
-- No estoy seguro de si ticket_total es el total total...
-- Estan todas las sucursales en la mimsa localidad ? 
/*
Valor promedio de las ventas (en $) seg�n la
localidad, a�o y mes. Se calcula en funci�n de la sumatoria del importe de las
ventas sobre el total de las mismas.
*/
CREATE VIEW TicketPromedioMensual AS
SELECT SUM(t.ticket_total)/COUNT(t.id_ticket) AS Promedio_Por_Localidad, YEAR(t.ticket_fecha_hora) AS a�o,MONTH(t.ticket_fecha_hora) AS mes,u.Localidad 
FROM Pteradata.BI_Ticket t
	JOIN Pteradata.BI_Sucursal s ON t.sucursal_nombre = s.Sucursal_Nombre
	JOIN Pteradata.BI_Ubicacion u ON u.id_direccion = s.Id_Direccion
GROUP BY u.Localidad, YEAR(t.ticket_fecha_hora),MONTH(t.ticket_fecha_hora)
ORDER BY a�o,mes

-- 2 --
/*
Cantidad unidades promedio. 
Cantidad promedio de art�culos que se venden
en funci�n de los tickets seg�n el turno para cada cuatrimestre de cada a�o. Se
obtiene sumando la cantidad de art�culos de todos los tickets correspondientes
sobre la cantidad de tickets. Si un producto tiene m�s de una unidad en un ticket,
para el indicador se consideran todas las unidades
*/
CREATE VIEW CantidadUnidadesPromedio AS


















--10--
CREATE VIEW Top3SucursalesCuotas AS
WITH PagosPorSucursal AS (
    SELECT 
        mp.Medio_Pago,
        ti.A�O,
        ti.MES,
        s.Sucursal_Nombre,
        SUM(p.pago_importe) AS Importe_Total,
        ROW_NUMBER() OVER (PARTITION BY mp.Medio_Pago, ti.A�O, ti.MES ORDER BY SUM(p.pago_importe) DESC) AS Sucursal_Ranking
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
        mp.Medio_Pago, ti.A�O, ti.MES, s.Sucursal_Nombre
)
SELECT
    Medio_Pago,
    A�O,
    MES,
    Sucursal_Nombre,
    Importe_Total
FROM 
    PagosPorSucursal
WHERE 
    Sucursal_Ranking <= 3;

GO

---11---

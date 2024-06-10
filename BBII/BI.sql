----------------------------------------CREACION DE TABLAS -----------------------------------------------------------------
CREATE TABLE Pteradata.BI_Tiempo(
	Id_Tiempo INT PRIMARY KEY,
	AÑO INT,
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



-----------------------------------------------MIGRO DATOS--------------------------------------------------------------

CREATE PROCEDURE migrarBI_Tiempo AS
BEGIN
	INSERT INTO Pteradata.BI_Tiempo(Id_Tiempo,AÑO,MES)
	SELECT DISTINCT (YEAR(pago_fecha)*100+MONTH(pago_fecha) ),YEAR(pago_fecha),MONTH(pago_fecha)
	FROM Pteradata.Pago
	ORDER BY MONTH(pago_fecha)
END
-- A ESTA MIGRACION LE HACE FALTA AGREGAR UNIONS CON EL RESTO DE FECHAS Q HAY A MEDIDA QUE LAS NECESITEMOS

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

CREATE PROCEDURE migrarBI_MedioPago AS
BEGIN
	INSERT INTO Pteradata.BI_MedioPago(id_medio_pago,Medio_Pago)
	SELECT id_medio_pago,pago_medio_pago
	FROM Pteradata.MedioPago
END

CREATE PROCEDURE migrarBI_Ticket AS
BEGIN
	INSERT INTO Pteradata.BI_Ticket(id_ticket,sucursal_nombre,ticket_numero,ticket_total,ticket_total_envio,ticket_total_Descuento_aplicado,ticket_fecha_hora,ticket_subtotal_productos)
	SELECT DISTINCT id_ticket,sucursal_nombre,ticket_numero,ticket_total,ticket_total_envio,ticket_total_Descuento_aplicado,ticket_fecha_hora,ticket_subtotal_productos
	FROM Pteradata.Ticket
END

CREATE PROCEDURE migrarBI_Pago AS
BEGIN
	INSERT INTO Pteradata.BI_Pago(ID_Pago,id_medio_pago,id_ticket,pago_fecha,pago_importe)
	SELECT DISTINCT ID_Pago,id_medio_pago,id_ticket,(YEAR(pago_fecha)*100+MONTH(pago_fecha)) AS pago_fecha,pago_importe
	FROM Pteradata.Pago
END

CREATE PROCEDURE migrarBI_Cliente AS
BEGIN
	INSERT INTO Pteradata.BI_Cliente(id_cliente,id_direccion,cliente_nombre,cliente_apellido,cliente_fecha_registro,cliente_telefono,cliente_mail,cliente_fecha_nacimiento,edad,cliente_dni)
	SELECT DISTINCT id_cliente,id_direccion,cliente_nombre,cliente_apellido,cliente_fecha_registro,cliente_telefono,cliente_mail,cliente_fecha_nacimiento, 
			DATEDIFF(YEAR,cliente_fecha_nacimiento,GETDATE()) AS edad, cliente_dni
	FROM Pteradata.Cliente
END

-------------------------------------------------CREACION DE VISTAS--------------------------------------------------------

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

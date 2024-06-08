--CREATE SCHEMA Pteradata

GO

CREATE PROCEDURE crearTodasLasTablas AS 
BEGIN

CREATE TABLE Pteradata.Descuento(
	descuento_codigo DECIMAL (18,0) PRIMARY KEY,
	descuento_descripcion VARCHAR (255),
	descuento_fecha_inicio DATE,
	descuento_fecha_fin DATE,
	descuento_porcentaje_desc DECIMAL(18,2),
	descuento_tope DECIMAL(18,2)
);


CREATE TABLE Pteradata.CajaTipo(
	id_caja_tipo INT PRIMARY KEY IDENTITY(1,1),
	caja_tipo VARCHAR(255)

);

CREATE TABLE Pteradata.EnvioEstado(
	id_estado INT PRIMARY KEY IDENTITY(1,1),
	estado VARCHAR(255)
);

CREATE TABLE Pteradata.ContactoEmpleado(
	id_contacto INT PRIMARY KEY IDENTITY(1,1),
	email VARCHAR(255),
	telefono DECIMAL(18,0)
);

CREATE TABLE Pteradata.Marca(
	producto_marca VARCHAR(255) PRIMARY KEY
);


CREATE TABLE Pteradata.TipoDeComprobante(
	tipo_comprobante VARCHAR(255) PRIMARY KEY
);

CREATE TABLE Pteradata.Reglas(
	id_reglas INT PRIMARY KEY IDENTITY(1,1),
	regla_aplica_misma_marca DECIMAL(18,0),
	regla_aplica_mismo_prod DECIMAL(18,0),
	regla_cant_aplica_descuento DECIMAL(18,0),
	regla_cant_aplicable_regla DECIMAL (18,0),
	regla_cant_max_prod DECIMAL (18,0),
	regla_descripcion VARCHAR(255),
	regla_descuento_aplicable_prod DECIMAL(18,2)
);

CREATE TABLE Pteradata.Provincia (
	id_provincia INT PRIMARY KEY IDENTITY(1,1),
	provincia_nombre VARCHAR(255) UNIQUE,
);

CREATE TABLE Pteradata.Localidad (
	id_localidad INT PRIMARY KEY IDENTITY(1,1),
	id_provincia INT,
	FOREIGN KEY (id_provincia) REFERENCES Pteradata.Provincia(id_provincia),
	localidad_nombre VARCHAR(255) 
);

CREATE TABLE Pteradata.Direccion(
	id_direccion INT PRIMARY KEY IDENTITY(1,1),
	domicilio VARCHAR(255),
	id_localidad INT,
	FOREIGN KEY(id_localidad) REFERENCES Pteradata.Localidad(id_localidad) 
)

CREATE TABLE Pteradata.Supermercado(
	cuit VARCHAR(255) PRIMARY KEY,
	id_direccion INT,
	nombre VARCHAR(255),
	razon VARCHAR(255),
	iibb VARCHAR(255),
	fecha_ini_actividad DATETIME,
	condicion_fiscal VARCHAR(255),
	FOREIGN KEY (id_direccion) REFERENCES Pteradata.Direccion(id_direccion)

);


CREATE TABLE Pteradata.Sucursal(
	sucursal_nombre VARCHAR(255) PRIMARY KEY,
	id_direccion INT,
	cuit VARCHAR(255),
	FOREIGN KEY(id_direccion) REFERENCES Pteradata.Direccion(id_direccion),
	FOREIGN KEY(cuit) REFERENCES Pteradata.Supermercado(cuit)
);

CREATE TABLE Pteradata.Caja(
	id_caja INT PRIMARY KEY IDENTITY(1,1),
	caja_num DECIMAL(18,0),
	sucursal_nombre VARCHAR(255),
	id_caja_tipo INT,
	FOREIGN KEY(sucursal_nombre) REFERENCES Pteradata.Sucursal(sucursal_nombre),
	FOREIGN KEY(id_caja_tipo) REFERENCES Pteradata.CajaTipo(id_caja_tipo)
);

CREATE TABLE Pteradata.Empleado(
	legajo INT PRIMARY KEY IDENTITY(100000,1),
	id_contacto INT,
	sucursal_nombre VARCHAR(255),
	dni DECIMAL(18,0),
	nombre VARCHAR(255),
	apellido VARCHAR(255),
	fecha_nacimiento DATETIME,
	fecha_registro DATETIME,

	FOREIGN KEY(id_contacto) REFERENCES Pteradata.ContactoEmpleado(id_contacto),
	FOREIGN KEY(sucursal_nombre) REFERENCES Pteradata.Sucursal(sucursal_nombre),

);

CREATE TABLE Pteradata.Cliente(
	id_cliente INT PRIMARY KEY IDENTITY(1,1), 
	dni_cliente DECIMAL(18,0),
	id_direccion INT,
	FOREIGN KEY(id_direccion) REFERENCES Pteradata.Direccion(id_direccion),
	cliente_nombre VARCHAR(255),
	cliente_apellido VARCHAR(255),
	cliente_fecha_registro DATE,
	cliente_telefono DECIMAL (18,0),
	cliente_mail VARCHAR(255),
	cliente_fecha_nacimiento DATE,
);

CREATE TABLE Pteradata.Ticket(
	id_ticket INT PRIMARY KEY IDENTITY(1,1),
	ticket_num DECIMAL(18,0),
	sucursal_nombre VARCHAR(255),
	id_caja INT,
	legajo_empleado INT,
	tipo_comprobante VARCHAR(255),
	ticket_total DECIMAL (18,2),
	ticket_subtotal_productos DECIMAL(18,2),
	ticket_total_descuento_aplicado DECIMAL(18,2),
	ticket_det_descuento_medio_pago  DECIMAL(18,2),
	ticket_fecha_hora DATETIME,
	ticket_total_envio DECIMAL(18,2),
	FOREIGN KEY (sucursal_nombre) REFERENCES Pteradata.Sucursal (sucursal_nombre),
	FOREIGN KEY (id_caja) REFERENCES Pteradata.Caja(id_caja),
	FOREIGN KEY (legajo_empleado) REFERENCES Pteradata.Empleado(legajo),
	FOREIGN KEY (tipo_comprobante) REFERENCES Pteradata.TipoDeComprobante(tipo_comprobante)
);

CREATE TABLE Pteradata.Envio(
	id_envio INT PRIMARY KEY IDENTITY(1,1),
	cliente_id INT,
	id_ticket INT,
	costo DECIMAL(18,2),
	fecha_programada DATETIME,
	hora_inicio DATETIME,
	hora_fin DATETIME,
	id_estado INT,
	fecha_entregado DATETIME,
	
	FOREIGN KEY(cliente_id) REFERENCES Pteradata.Cliente(id_cliente),
	FOREIGN KEY(id_ticket) REFERENCES Pteradata.Ticket(id_ticket),
	FOREIGN KEY (id_estado) REFERENCES Pteradata.EnvioEstado(id_estado)
);


CREATE TABLE Pteradata.Categoria(
	producto_categoria VARCHAR(255) PRIMARY KEY,
);

CREATE TABLE Pteradata.SubCategoria(
	producto_sub_categoria VARCHAR(255),
	producto_categoria VARCHAR(255),
	PRIMARY KEY (producto_sub_categoria, producto_categoria),
	FOREIGN KEY (producto_categoria) REFERENCES Pteradata.Categoria(producto_categoria)
);


CREATE TABLE Pteradata.Producto(
	producto_nombre VARCHAR(255) PRIMARY KEY,
	producto_descripcion VARCHAR(255),
);

CREATE TABLE Pteradata.ProductoPorMarca(
	id_producto_marca INT PRIMARY KEY IDENTITY(1,1),
	producto_marca VARCHAR(255),
	producto_nombre VARCHAR(255),
	precio DECIMAL(18,2),
	FOREIGN KEY (producto_marca) REFERENCES Pteradata.Marca(producto_marca),
	FOREIGN KEY (producto_nombre) REFERENCES Pteradata.Producto(producto_nombre)
);

CREATE TABLE Pteradata.ProductoPorCategoria(
	producto_categoria VARCHAR(255),
	producto_nombre VARCHAR(255),
	PRIMARY KEY (producto_nombre,producto_categoria),
	FOREIGN KEY (producto_categoria) REFERENCES Pteradata.Categoria(producto_categoria),
	FOREIGN KEY (producto_nombre) REFERENCES Pteradata.Producto(producto_nombre),
);


CREATE TABLE Pteradata.Promocion(
	promo_codigo DECIMAL(18,0) PRIMARY KEY,
	id_reglas INT,
	promocion_fecha_inicio DATETIME,
	promocion_fecha_fin DATETIME,
	promocion_descripcion VARCHAR(255),
	FOREIGN KEY (id_reglas) REFERENCES Pteradata.Reglas(id_reglas)
);


CREATE TABLE Pteradata.PromocionPorProducto(
	id_promocion_producto INT PRIMARY KEY IDENTITY(1,1),
	promo_codigo DECIMAL(18,0),
	producto_nombre VARCHAR(255),
	FOREIGN KEY (producto_nombre) REFERENCES Pteradata.Producto(producto_nombre),
	FOREIGN KEY (promo_codigo) REFERENCES Pteradata.Promocion(promo_codigo),
);

CREATE TABLE Pteradata.PromocionAplicada(
	id_promocion_producto INT,
	promo_aplicada_dto DECIMAL(18,2),
	PRIMARY KEY (id_promocion_producto, promo_aplicada_dto),
	FOREIGN KEY (id_promocion_producto) REFERENCES Pteradata.PromocionPorProducto(id_promocion_producto)
);

CREATE TABLE Pteradata.TicketPorProductos(
	id_ticket_producto INT PRIMARY KEY IDENTITY(1,1),
	id_ticket INT,
	id_producto_marca INT,
	ticket_det_cantidad DECIMAL(18,0),
	ticket_det_total DECIMAL(18,2),
	FOREIGN KEY (id_ticket ) REFERENCES Pteradata.Ticket(id_ticket ),
	FOREIGN KEY (id_producto_marca) REFERENCES Pteradata.ProductoPorMarca(id_producto_marca)
);

CREATE TABLE Pteradata.TipoPagoMedioPago (
	id_pago_tipo_medio_pago INT PRIMARY KEY IDENTITY(1,1),
	pago_tipo_medio_pago VARCHAR(255)
);

CREATE TABLE Pteradata.MedioPago (
	id_medio_pago INT PRIMARY KEY IDENTITY(1,1),
	pago_medio_pago VARCHAR(255) UNIQUE,
	id_pago_tipo_medio_pago INT,
	FOREIGN KEY (id_pago_tipo_medio_pago) REFERENCES Pteradata.TipoPagoMedioPago(id_pago_tipo_medio_pago)
);

CREATE TABLE Pteradata.Tarjeta(
	nro_tarjeta VARCHAR(50) PRIMARY KEY,
	tarjeta_fecha_vencimiento DATETIME
);

CREATE TABLE Pteradata.Pago(
	nro_pago INT PRIMARY KEY IDENTITY(1,1),
	pago_fecha DATETIME, 
	pago_importe DECIMAL(18,2),
	id_medio_pago INT,
	FOREIGN KEY(id_medio_pago) REFERENCES Pteradata.MedioPago(id_medio_pago)
);

CREATE TABLE Pteradata.DetallePago (
	id_pago_detalle INT PRIMARY KEY IDENTITY(1,1),
	nro_tarjeta VARCHAR(50),
	nro_pago INT,
	FOREIGN KEY(nro_pago) REFERENCES Pteradata.Pago(nro_pago),
	FOREIGN KEY (nro_tarjeta) REFERENCES Pteradata.Tarjeta(nro_tarjeta),
	cant_cuotas INT
);



CREATE TABLE Pteradata.DescuetoPorPago(
	id_pago INT,
	descuento_codigo DECIMAL(18,0),
	FOREIGN KEY(id_pago) REFERENCES Pteradata.Pago(nro_pago),
	FOREIGN KEY(descuento_codigo) REFERENCES Pteradata.Descuento(descuento_codigo),

	PRIMARY KEY (id_pago, descuento_codigo)
);

CREATE TABLE Pteradata.PagoPorTicket(
	nro_pago INT,
	id_ticket INT,
	FOREIGN KEY(nro_pago) REFERENCES Pteradata.Pago(nro_pago),
	FOREIGN KEY (id_ticket ) REFERENCES Pteradata.Ticket(id_ticket ),
	PRIMARY KEY (nro_pago, id_ticket)
);
END
/*
Con este procedure creamos todas las tablas con los datos necesarios 
segun el modelo de datos que creamos
*/


GO

EXEC crearTodasLasTablas

GO

CREATE PROCEDURE migrarTipoComprobantes AS
BEGIN
	INSERT INTO Pteradata.TipoDeComprobante(tipo_comprobante)
	SELECT DISTINCT TICKET_TIPO_COMPROBANTE FROM gd_esquema.Maestra
END
/*
El objetivo de este procedimiento es el de migrar los distintos tipos de comprobantes 
que existen en la tabla maestra hacia la tabla TipoDeComprobante
*/
GO

CREATE PROCEDURE migrarProvincia AS
BEGIN
	INSERT INTO Pteradata.Provincia(provincia_nombre) 
	SELECT DISTINCT SUPER_PROVINCIA FROM gd_esquema.Maestra
	UNION
	SELECT DISTINCT CLIENTE_PROVINCIA FROM gd_esquema.Maestra
	WHERE CLIENTE_PROVINCIA IS NOT NULL AND SUPER_PROVINCIA IS NOT NULL
	UNION 
	SELECT DISTINCT SUCURSAL_PROVINCIA FROM gd_esquema.Maestra	
END
/*
El objetivo de este procedimiento es migrar las distintas provincias existentes 
hacia la tabla Provincia. Utilizamos SELECT DISTINCT y UNION para asegurarnos e que se insterten provincias 
únicas.
*/
go

CREATE PROCEDURE migrarLocalidad AS
BEGIN
	INSERT INTO Pteradata.Localidad(localidad_nombre, id_provincia)
	SELECT DISTINCT SUPER_LOCALIDAD, p.id_provincia FROM gd_esquema.Maestra g 
	JOIN Pteradata.Provincia p ON p.provincia_nombre = g.SUPER_PROVINCIA
	UNION
	SELECT DISTINCT CLIENTE_LOCALIDAD, p.id_provincia FROM gd_esquema.Maestra g 
	JOIN Pteradata.Provincia p ON p.provincia_nombre = g.CLIENTE_PROVINCIA
	UNION
	SELECT DISTINCT SUCURSAL_LOCALIDAD, p.id_provincia FROM gd_esquema.Maestra
	JOIN Pteradata.Provincia p ON SUCURSAL_PROVINCIA = p.provincia_nombre
	
END
/*
El objetivo de este procedimiento es migrar los nombres de todas las localidades existentes
hacia la tabla Localidad, y asociarlas con sus provincias correspondientes.
Utilizamos SELECT DISTINCT y UNION para evitar repeticiones y JOINS 
para relacionar las localidades con la provincia en la que se encuentra.
*/
GO

CREATE PROCEDURE migrarDireccion AS
BEGIN 
	INSERT INTO Pteradata.Direccion(domicilio, id_localidad)
	SELECT DISTINCT SUPER_DOMICILIO, p.id_localidad FROM gd_esquema.Maestra g 
	JOIN Pteradata.Localidad p ON p.localidad_nombre = g.SUPER_LOCALIDAD
	UNION
	SELECT DISTINCT CLIENTE_DOMICILIO, p.id_localidad FROM gd_esquema.Maestra g 
	JOIN Pteradata.Localidad p ON p.localidad_nombre = g.CLIENTE_LOCALIDAD
	UNION
	SELECT DISTINCT SUCURSAL_DIRECCION, p.id_localidad FROM gd_esquema.Maestra g
	JOIN Pteradata.Localidad p ON p.localidad_nombre = g.SUCURSAL_LOCALIDAD
END
/*
El objetivo de este procedimiento es el de migrar los nombres de todas las direcciones existentes
hacia la tabla Direccion, y asociarlas con su localidad correspondiente.
Utilizamos SELECT DISTINCT y UNION para evitar repeticiones y JOIN
para relacionar las direcciones con la localidad en la que se encuentra.

*/

GO

CREATE PROCEDURE migrarClientes AS
BEGIN
	INSERT INTO Pteradata.Cliente(dni_cliente,id_direccion, cliente_nombre,cliente_apellido,cliente_fecha_registro,cliente_telefono,cliente_mail,cliente_fecha_nacimiento)
	SELECT DISTINCT CLIENTE_DNI, d.id_direccion, CLIENTE_NOMBRE, CLIENTE_APELLIDO, CLIENTE_FECHA_REGISTRO,CLIENTE_TELEFONO,CLIENTE_MAIL,CLIENTE_FECHA_NACIMIENTO
	FROM gd_esquema.Maestra m JOIN Pteradata.Direccion d ON m.CLIENTE_DOMICILIO = d.domicilio
							  JOIN Pteradata.Localidad l ON l.id_localidad = d.id_localidad AND l.localidad_nombre = m.CLIENTE_LOCALIDAD
							  JOIN Pteradata.Provincia p ON l.id_provincia = p.id_provincia AND p.provincia_nombre = m.CLIENTE_PROVINCIA
END
/*
Este procedimiento tiene como objetivo migrar los datos de los clientes 
hacia la tabla Cliente.
Utilizamos SELECT DISTINCT para evitar repeticiones de los mismos clientes
y JOINS para relacionar al cliente con la direccion en la que vive.
*/

GO

CREATE PROCEDURE migrarSupermercado AS
BEGIN
	INSERT INTO Pteradata.Supermercado(cuit, id_direccion, nombre, razon,iibb,fecha_ini_actividad,condicion_fiscal)
	SELECT DISTINCT SUPER_CUIT, d.id_direccion,SUPER_NOMBRE ,SUPER_RAZON_SOC,SUPER_IIBB,SUPER_FECHA_INI_ACTIVIDAD,SUPER_CONDICION_FISCAL
	FROM gd_esquema.Maestra m JOIN Pteradata.Direccion d ON m.SUPER_DOMICILIO = d.domicilio
							  JOIN Pteradata.Localidad l ON l.id_localidad = d.id_localidad AND l.localidad_nombre = m.SUPER_LOCALIDAD
							  JOIN Pteradata.Provincia p ON l.id_provincia = p.id_provincia AND p.provincia_nombre = m.SUPER_PROVINCIA
END
/*
Este procedimiento tiene como objetivo migrar los datos del supermercado 
hacia la tabla Supermercado.
Utilizamos SELECT DISTINCT para evitar la repeticion del supermercado
y JOINS para relacionar al supermercado con la direccion en la que se encuentra.
*/
GO

CREATE PROCEDURE migrarSucursal AS
BEGIN
	INSERT INTO Pteradata.Sucursal(sucursal_nombre,id_direccion,cuit)
	SELECT DISTINCT SUCURSAL_NOMBRE, d.id_direccion, SUPER_CUIT
	FROM gd_esquema.Maestra m JOIN Pteradata.Direccion d ON m.SUCURSAL_DIRECCION = d.domicilio
							  JOIN Pteradata.Localidad l ON l.id_localidad = d.id_localidad AND l.localidad_nombre = m.SUCURSAL_LOCALIDAD
							  JOIN Pteradata.Provincia p ON l.id_provincia = p.id_provincia AND p.provincia_nombre = m.SUCURSAL_PROVINCIA
END
/*
Este procedimiento tiene como objetivo migrar los datos de las disitntas sucursales 
hacia la tabla Sucursal.
Utilizamos SELECT DISTINCT para evitar la repeticion de las sucursales
y JOINS para relacionar las sucursales con la direccion en la que se encuentran.
*/
GO

CREATE PROCEDURE migrarCajaTipo AS
BEGIN
	INSERT INTO Pteradata.CajaTipo(caja_tipo)
	SELECT DISTINCT CAJA_TIPO FROM gd_esquema.Maestra
	WHERE CAJA_TIPO IS NOT NULL
END
/*
Este procedimiento tiene como objetivo migrar los tipos de cajas que hay
hacia la tabla CajaTipo.
Utilizamos SELECT DISTINCT para migrar un unico tipo de caja
*/
GO

CREATE PROCEDURE migrarCajas AS
BEGIN
	INSERT INTO Pteradata.Caja(caja_num,sucursal_nombre,id_caja_tipo)
	SELECT DISTINCT m.CAJA_NUMERO, sc.sucursal_nombre, ct.id_caja_tipo
	FROM gd_esquema.Maestra m JOIN Pteradata.Sucursal sc ON m.SUCURSAL_NOMBRE = sc.sucursal_nombre
							  JOIN Pteradata.CajaTipo ct ON m.CAJA_TIPO = ct.caja_tipo
							  WHERE m.CAJA_NUMERO IS NOT NULL
END
/*
Este procedimiento tiene como objetivo migrar los datos de las disitntas cajas 
hacia la tabla Caja.
Utilizamos SELECT DISTINCT para evitar la repeticion de las cajas
y JOINS para relacionar las cajas con el tipo de caja que son y la sucursal a la que pertenecen.
*/
GO

CREATE PROCEDURE migrarContactoEmpleado AS
BEGIN
	INSERT INTO Pteradata.ContactoEmpleado(email, telefono)
	SELECT DISTINCT EMPLEADO_MAIL, EMPLEADO_TELEFONO FROM gd_esquema.Maestra
	WHERE EMPLEADO_MAIL IS NOT NULL AND EMPLEADO_TELEFONO IS NOT NULL
END
/*
Este procedimiento tiene como objetivo migrar los contactos que existen de los empleados 
hacia la tabla ContactoEmpleado.
Utilizamos SELECT DISTINCT para evitar la repeticion de los contactos.
*/
GO

CREATE PROCEDURE migrarEmpleados AS
BEGIN
	INSERT INTO Pteradata.Empleado(id_contacto, sucursal_nombre,dni,nombre,apellido,fecha_nacimiento,fecha_registro)
	SELECT DISTINCT ce.id_contacto, s.sucursal_nombre,EMPLEADO_DNI,EMPLEADO_NOMBRE,EMPLEADO_APELLIDO,EMPLEADO_FECHA_NACIMIENTO,EMPLEADO_FECHA_REGISTRO
	FROM gd_esquema.Maestra m JOIN Pteradata.ContactoEmpleado ce ON ce.email = m.EMPLEADO_MAIL AND ce.telefono = m.EMPLEADO_TELEFONO
							  JOIN Pteradata.Sucursal s ON m.SUCURSAL_NOMBRE = s.sucursal_nombre
END
/*
Este procedimiento tiene como objetivo migrar los datos de los diferentes empleados 
hacia la tabla Empleado.
Utilizamos SELECT DISTINCT para evitar la repeticion de empleados y JOINS
para relacionarlos con sus datos de contacto y la sucursal en la que trabajan.
*/
GO

CREATE PROCEDURE migrarReglas AS
BEGIN
	INSERT INTO Pteradata.Reglas(regla_aplica_misma_marca,regla_aplica_mismo_prod,regla_cant_aplica_descuento,
	regla_cant_aplicable_regla,regla_cant_max_prod,regla_descripcion,regla_descuento_aplicable_prod)
	
	SELECT DISTINCT REGLA_APLICA_MISMA_MARCA, REGLA_APLICA_MISMO_PROD, REGLA_CANT_APLICA_DESCUENTO, 
	REGLA_CANT_APLICABLE_REGLA, REGLA_CANT_MAX_PROD, REGLA_DESCRIPCION, REGLA_DESCUENTO_APLICABLE_PROD 
	FROM gd_esquema.Maestra
	WHERE REGLA_DESCRIPCION IS NOT NULL
END
/*
Este procedimiento tiene como objetivo migrar las diferentes reglas que hay sobre las promociones
hacia la tabla Reglas.
Utilizamos SELECT DISTINCT para evitar la repeticion de las reglas.
*/
GO

CREATE PROCEDURE migrarDescuentos AS
BEGIN
	INSERT INTO Pteradata.Descuento(descuento_codigo,descuento_descripcion, descuento_fecha_inicio, 
	descuento_fecha_fin, descuento_porcentaje_desc, descuento_tope)
	SELECT DISTINCT DESCUENTO_CODIGO,DESCUENTO_DESCRIPCION, DESCUENTO_FECHA_INICIO, DESCUENTO_FECHA_FIN,
	DESCUENTO_PORCENTAJE_DESC, DESCUENTO_TOPE FROM gd_esquema.Maestra
	WHERE DESCUENTO_CODIGO IS NOT NULL
END
/*
Este procedimiento tiene como objetivo migrar los diferentes descuentos que hay sobre los pagos
hacia la tabla Descuento.
Utilizamos SELECT DISTINCT para evitar la repeticion de los descuentos.
*/
GO

CREATE PROCEDURE migrarMarcas AS
BEGIN
	INSERT INTO Pteradata.Marca(producto_marca)
	SELECT DISTINCT PRODUCTO_MARCA FROM gd_esquema.Maestra
	WHERE PRODUCTO_MARCA IS NOT NULL
END
/*
Este procedimiento tiene como objetivo migrar las diferentes marcas que hay
hacia la tabla Marca.
Utilizamos SELECT DISTINCT para evitar la repeticion de marcas.
*/
GO

CREATE PROCEDURE migrarCategorias AS
BEGIN
	INSERT INTO Pteradata.Categoria(producto_categoria)
	SELECT DISTINCT PRODUCTO_CATEGORIA FROM gd_esquema.Maestra
	WHERE PRODUCTO_CATEGORIA IS NOT NULL
END
/*
Este procedimiento tiene como objetivo migrar las diferentes categorias que puede pertenecer un producto
hacia la tabla Categoria.
Utilizamos SELECT DISTINCT para evitar la repeticion de categorias.
*/
GO

CREATE PROCEDURE migrarSubCategorias AS
BEGIN 
	INSERT INTO Pteradata.SubCategoria(producto_sub_categoria, producto_categoria)
	SELECT DISTINCT PRODUCTO_SUB_CATEGORIA, PRODUCTO_CATEGORIA FROM gd_esquema.Maestra
	WHERE PRODUCTO_CATEGORIA IS NOT NULL AND PRODUCTO_SUB_CATEGORIA IS NOT NULL
END
/*
Este procedimiento tiene como objetivo migrar las diferentes subcategorias que puede tener una categoria
hacia la tabla SubCategoria.
Utilizamos SELECT DISTINCT para evitar la repeticion de subcategorias.
*/
GO

CREATE PROCEDURE migrarProductos AS
BEGIN
	INSERT INTO Pteradata.Producto(producto_nombre,producto_descripcion)
	SELECT DISTINCT PRODUCTO_NOMBRE, PRODUCTO_DESCRIPCION
	FROM gd_esquema.Maestra
	where PRODUCTO_NOMBRE is not null
END
/*
Este procedimiento tiene como objetivo migrar todos los productos que hay
hacia la tabla Producto.
Utilziamos SELECT DISTINCT para evitar la repeticion de productos.
*/
GO

CREATE PROCEDURE migrarProductoPorCategoria AS
BEGIN 

	INSERT INTO Pteradata.ProductoPorCategoria(producto_categoria, producto_nombre)
		SELECT DISTINCT c.producto_categoria, p.producto_nombre
			FROM gd_esquema.Maestra m
			JOIN Pteradata.Categoria c on c.producto_categoria = m.PRODUCTO_CATEGORIA
			JOIN Pteradata.Producto p on p.producto_nombre = m.PRODUCTO_NOMBRE

END 
/*
Este procedimiento tiene como objetivo unir los productos con la categoria a la que pertenecen
mediante la utilzacion de los JOINS hacia la tabla Categoria y Producto.
*/
GO

CREATE PROCEDURE migrarProductoPorMarca AS
BEGIN 

	INSERT INTO Pteradata.ProductoPorMarca(producto_marca, producto_nombre, precio)
		SELECT DISTINCT m.producto_marca, p.producto_nombre, g.PRODUCTO_PRECIO
			FROM gd_esquema.Maestra g 
			JOIN Pteradata.Marca m on m.producto_marca = g.PRODUCTO_MARCA
			JOIN Pteradata.Producto p on p.producto_nombre = g.PRODUCTO_NOMBRE
END
/*
Este procedimiento tiene como objetivo unir los productos con la marca que los provee
mediante la utilzacion de los JOINS hacia la tabla Marca y Producto.
*/
GO

CREATE PROCEDURE migrarTarjetas AS
BEGIN
	INSERT INTO Pteradata.Tarjeta(nro_tarjeta, tarjeta_fecha_vencimiento)
	SELECT DISTINCT PAGO_TARJETA_NRO, PAGO_TARJETA_FECHA_VENC FROM gd_esquema.Maestra
	WHERE PAGO_TARJETA_NRO IS NOT NULL AND PAGO_TARJETA_FECHA_VENC IS NOT NULL
END
/*
Este procedimiento tiene como objetivo migrar los datos de las Tarjetas de los clientes
hacia la tabla Tarjeta.
Utilizamos SELECT DISTINCT para evitar la repeticion de tarjetas.
*/
GO

CREATE PROCEDURE migrarTipoPagoMedioPago AS
BEGIN 
	INSERT INTO Pteradata.TipoPagoMedioPago(pago_tipo_medio_pago)
		SELECT DISTINCT PAGO_TIPO_MEDIO_PAGO
			FROM gd_esquema.Maestra
			WHERE PAGO_TIPO_MEDIO_PAGO is not null
END
/*
Este procedimiento tiene como objetivo migrar los diferentes tipos de medio de pago
hacia la tabla TipoPagoMedioPago.
Utilizamos SELECT DISTINCT para evitar la repeticion de tipos medios de pago.
*/
GO

CREATE PROCEDURE migrarMedioPago AS
BEGIN
	INSERT INTO Pteradata.MedioPago(pago_medio_pago, id_pago_tipo_medio_pago)
	SELECT DISTINCT g.PAGO_MEDIO_PAGO, t.id_pago_tipo_medio_pago FROM gd_esquema.Maestra g
	JOIN Pteradata.TipoPagoMedioPago t ON g.PAGO_TIPO_MEDIO_PAGO = t.pago_tipo_medio_pago
END
/*
Este procedimiento tiene como objetivo migrar los diferentes medios de pago
hacia la tabla MedioPago.
Utilizamos SELECT DISTINCT para evitar la repeticion de medios de pago.
*/
GO


CREATE PROCEDURE migrarPago AS
BEGIN
	INSERT INTO Pteradata.Pago(pago_fecha,pago_importe, id_medio_pago)
	SELECT PAGO_FECHA, PAGO_IMPORTE, m.id_medio_pago FROM gd_esquema.Maestra g
	JOIN Pteradata.MedioPago m ON m.pago_medio_pago = g.PAGO_MEDIO_PAGO
	JOIN Pteradata.TipoPagoMedioPago t ON (t.id_pago_tipo_medio_pago = m.id_pago_tipo_medio_pago
	AND g.PAGO_TIPO_MEDIO_PAGO = t.pago_tipo_medio_pago)
END
/*
Este procedimiento tiene como objetivo migrar los diferentes pagos
hacia la tabla MedioPago.
Utilizamos los JOIN hacia las tablas MedioPago y TipoPagoMedioPago
para relacionar cada pago con el tipo y medio de pago al que pertenecen.
*/
go

CREATE PROCEDURE migrarDetallePago AS
BEGIN 
	INSERT INTO Pteradata.DetallePago(nro_tarjeta, nro_pago, cant_cuotas)
	SELECT t.nro_tarjeta, nro_pago, PAGO_TARJETA_CUOTAS FROM gd_esquema.Maestra m
	JOIN Pteradata.Tarjeta t ON m.PAGO_TARJETA_NRO = t.nro_tarjeta
	JOIN Pteradata.Pago p ON p.pago_fecha = m.PAGO_FECHA AND p.pago_importe = m.PAGO_IMPORTE
END
/*
Este procedimiento tiene como objetivo relacionar los datos de los pagos con tarjeta con su detalle
hacia la tabla DetallePago.
Utilizamos los JOIN a las tablas Tarjeta y Pago para relacionar la cantidad de cuotas que se saco el pago
*/
GO

CREATE PROCEDURE migrarPromocion AS
BEGIN
	INSERT INTO Pteradata.Promocion(promo_codigo, id_reglas, promocion_fecha_inicio, promocion_fecha_fin, promocion_descripcion)
	SELECT DISTINCT g.PROMO_CODIGO, r.id_reglas, PROMOCION_FECHA_INICIO, PROMOCION_FECHA_FIN, PROMOCION_DESCRIPCION 
		FROM gd_esquema.Maestra g
		JOIN Pteradata.Reglas r ON r.regla_descripcion = g.REGLA_DESCRIPCION
END
/*
Este procedimiento tiene como objetivo migrar las diferentes promociones existentes
hacia la tabla Promocion.
Utilizamos SELECT DISTINCT para evitar la repeticion de promociones y el JOIN
con la tabla Reglas para relacionar la promocion con la regla que sigue.
*/
GO

CREATE PROCEDURE migrarPromocionPorProducto AS
BEGIN
	INSERT INTO Pteradata.PromocionPorProducto(promo_codigo, producto_nombre)
	SELECT DISTINCT PROMO_CODIGO, p.producto_nombre
		FROM gd_esquema.Maestra m 
		JOIN Pteradata.Producto p ON m.PRODUCTO_NOMBRE = p.producto_nombre
	where PROMO_CODIGO is not null
END
/*
Este procedimiento tiene como objetivo relacionar las diferentes promociones con los productos sobre las que se aplican.
*/
GO

CREATE PROCEDURE migrarPomocionAplicada AS
BEGIN

	INSERT INTO Pteradata.PromocionAplicada(id_promocion_producto, promo_aplicada_dto)
		SELECT DISTINCT pn.id_promocion_producto, g.PROMO_APLICADA_DESCUENTO
			FROM gd_esquema.Maestra g
			LEFT JOIN Pteradata.PromocionPorProducto pn on pn.promo_codigo = g.PROMO_CODIGO
			where id_promocion_producto is not null
END
/*
Este procedimiento tiene como objetivo guardar el descuento aplicado sobre un producto en promocion.
*/
GO

CREATE PROCEDURE migrarEnvioEstados AS
BEGIN
	INSERT INTO Pteradata.EnvioEstado(estado)
	SELECT DISTINCT ENVIO_ESTADO FROM gd_esquema.Maestra
	WHERE ENVIO_ESTADO IS NOT NULL 
END
/*
Este procedimiento tiene como objetivo migrar los diferentes estados que puede tener un envio
hacia la tabla EnvioEstado.
Utilizamos SELECT DISTINCT para evitar la repeticion de estados.
*/
GO

CREATE PROCEDURE migrarEnvio AS
BEGIN
	INSERT INTO Pteradata.Envio(cliente_id, id_ticket, costo, fecha_programada, hora_inicio, hora_fin, id_estado, fecha_entregado)
		SELECT DISTINCT c.id_cliente, t.id_ticket, g.ENVIO_COSTO, g.ENVIO_FECHA_PROGRAMADA, g.ENVIO_HORA_INICIO, g.ENVIO_HORA_FIN, e.id_estado, g.ENVIO_FECHA_ENTREGA
			FROM gd_esquema.Maestra g
			JOIN Pteradata.EnvioEstado e ON e.estado = g.ENVIO_ESTADO
			JOIN Pteradata.Cliente c ON c.dni_cliente = g.CLIENTE_DNI
			LEFT JOIN Pteradata.Ticket t on t.ticket_num = g.TICKET_NUMERO
END
/*
Este procedimiento tiene como objetivo migrar los diferentes envios que hay
hacia la tabla EnvioEstado.
Utilizamos SELECT DISTINCT para evitar la repeticion de envios y los JOIN
hacia las tablas Cliente, EnvioEstado y Ticket para relacionar cada envio con el cliente al que pertenecen, su estado y el ticket correspondiente.
*/
GO

CREATE PROCEDURE migrarTicket AS
BEGIN

	INSERT INTO Pteradata.Ticket(ticket_num, sucursal_nombre, id_caja, legajo_empleado, tipo_comprobante, ticket_total, ticket_total_envio, ticket_total_descuento_aplicado, 
								 ticket_det_descuento_medio_pago, ticket_fecha_hora)

		SELECT DISTINCT m.TICKET_NUMERO, s.sucursal_nombre, c.id_caja ,e.legajo, t.tipo_comprobante, m.TICKET_TOTAL_TICKET, m.TICKET_TOTAL_ENVIO, m.TICKET_TOTAL_DESCUENTO_APLICADO, 
						m.TICKET_TOTAL_DESCUENTO_APLICADO_MP, m.TICKET_FECHA_HORA
			FROM gd_esquema.Maestra m
			right JOIN Pteradata.Sucursal s on s.sucursal_nombre = m.SUCURSAL_NOMBRE
			right JOIN Pteradata.Caja c on c.caja_num = m.CAJA_NUMERO and c.sucursal_nombre = m.SUCURSAL_NOMBRE 
			right JOIN Pteradata.Empleado e on  e.dni = m.EMPLEADO_DNI
			right JOIN Pteradata.TipoDeComprobante t on t.tipo_comprobante = m.TICKET_TIPO_COMPROBANTE
			
END
/*
Este procedimiento tiene como objetivo migrar los diferentes tickets que hay
hacia la tabla Ticket.
Utilizamos SELECT DISTINCT para evitar la repeticion de tickets y los JOIN
hacia las tablas Sucursal, Caja, Empleado y TipoDeComprobante para relacionar cada ticket con la sucursal y la caja donde se creo el ticket, 
el empleado que lo genero y el tipo de comprobante del ticket.
*/
GO

CREATE PROCEDURE migrarTicketPorProductos AS 
BEGIN

	INSERT INTO Pteradata.TicketPorProductos(id_ticket, id_producto_marca, ticket_det_cantidad, ticket_det_total)
		SELECT t.id_ticket, p.id_producto_marca,  m.TICKET_DET_CANTIDAD, m.TICKET_DET_TOTAL
			FROM gd_esquema.Maestra m
			LEFT JOIN Pteradata.ProductoPorMarca p on (p.producto_nombre = m.PRODUCTO_NOMBRE and p.producto_marca = m.PRODUCTO_MARCA)
			LEFT JOIN Pteradata.Ticket t on t.ticket_num = m.TICKET_NUMERO 

END
/*
Este procedimiento tiene como objetivo migrar los diferentes items que tiene un ticket
hacia la tabla TicketPorProductos.
*/
GO

CREATE PROCEDURE migrarPagoXTicket AS
BEGIN
	INSERT INTO Pteradata.PagoPorTicket(nro_pago, id_ticket)
	SELECT p.nro_pago, t.id_ticket
	FROM gd_esquema.Maestra m JOIN Pteradata.Pago p ON m.PAGO_FECHA = p.pago_fecha AND m.PAGO_IMPORTE = p.pago_importe
	JOIN Pteradata.Ticket t ON m.TICKET_NUMERO = t.ticket_num
END
/*
Este procedimiento tiene como objetivo migrar el o los pagos que se realizaron a un ticket
hacia la tabla PagoPorTicket.
*/
GO

CREATE PROCEDURE migrarDescuentoXPago AS
BEGIN
	INSERT INTO Pteradata.DescuetoPorPago(id_pago,descuento_codigo)
	SELECT p.nro_pago, d.descuento_codigo
	FROM gd_esquema.Maestra m
	JOIN Pteradata.Descuento d ON m.DESCUENTO_CODIGO = d.descuento_codigo
	JOIN Pteradata.Pago p ON m.PAGO_FECHA = p.pago_fecha AND m.PAGO_IMPORTE = p.pago_importe 
END
/*
Este procedimiento tiene como objetivo migrar los descuentos aplicados a los pagos
hacia la tabla DescuetoPorPago
*/
GO

CREATE PROCEDURE migrarTodo AS
BEGIN
	EXEC migrarTipoPagoMedioPago;
	EXEC migrarTipoComprobantes;
	EXEC migrarEnvioEstados;
	EXEC migrarProvincia;
	EXEC migrarLocalidad;
	EXEC migrarDireccion;
	EXEC migrarClientes;
	EXEC migrarSupermercado;
	EXEC migrarSucursal; 
	EXEC migrarCajaTipo;
	EXEC migrarCajas;
	EXEC migrarContactoEmpleado;
	EXEC migrarEmpleados;
	EXEC migrarReglas;
	EXEC migrarDescuentos;
	EXEC migrarMarcas;
	EXEC migrarCategorias;
	EXEC migrarSubCategorias;
	EXEC migrarProductos;
	EXEC migrarProductoPorCategoria;
	EXEC migrarProductoPorMarca;
	EXEC migrarTarjetas;
	EXEC migrarMedioPago;
	EXEC migrarPago;
	EXEC migrarDetallePago;
	EXEC migrarPromocion;
	EXEC migrarPromocionPorProducto;
	EXEC migrarPomocionAplicada;
	EXEC migrarEnvio;
	EXEC migrarTicket;
	EXEC migrarTicketPorProductos;
	EXEC migrarPagoXTicket;
	EXEC migrarDescuentoXPago
END 

/*
Este procedimiento tiene como objetivo realizar la ejecucion de todas las migraciones en orden.
*/
GO

EXEC migrarTodo;

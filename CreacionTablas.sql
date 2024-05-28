--DROP PROCEDURE crearTodasLasTablas;
go
CREATE PROCEDURE crearTodasLasTablas AS 
BEGIN

CREATE TABLE Pteradata.Descuento(
	descuento_codigo DECIMAL (18,0) PRIMARY KEY,
	descuento_descripcion VARCHAR (255),
	descuento_fecha_inicio DATE,
	descuento_fecha_fin DATE,
	descuento_porcentaje_desc DECIMAL(18,2),
	descuento_tope DECIMAL(18,2),
	descuento_medio_pago VARCHAR(50)
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
	id_marca INT PRIMARY KEY IDENTITY(1,1),
	producto_marca VARCHAR(255)
);


CREATE TABLE Pteradata.TipoDeComprobante(
	id_tipo_comprobante INT PRIMARY KEY IDENTITY(1,1),
	tipo_comprobante VARCHAR(255)
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
	sucursal_num INT PRIMARY KEY IDENTITY(1,1),
	nombre VARCHAR(255),
	id_direccion INT,
	cuit VARCHAR(255),
	FOREIGN KEY(id_direccion) REFERENCES Pteradata.Direccion(id_direccion),
	FOREIGN KEY(cuit) REFERENCES Pteradata.Supermercado(cuit)
);

CREATE TABLE Pteradata.Caja(
	id_caja INT PRIMARY KEY IDENTITY(1,1),
	caja_num DECIMAL(18,0),
	sucursal_num INT,
	id_caja_tipo INT,
	FOREIGN KEY(sucursal_num) REFERENCES Pteradata.Sucursal(sucursal_num),
	FOREIGN KEY(id_caja_tipo) REFERENCES Pteradata.CajaTipo(id_caja_tipo)
);



CREATE TABLE Pteradata.Empleado(
	legajo INT PRIMARY KEY IDENTITY(100000,1),
	id_contacto INT,
	sucursal_num INT,
	dni DECIMAL(18,0),
	nombre VARCHAR(255),
	apellido VARCHAR(255),
	fecha_nacimiento DATETIME,
	fecha_registro DATETIME,

	FOREIGN KEY(id_contacto) REFERENCES Pteradata.ContactoEmpleado(id_contacto),
	FOREIGN KEY(sucursal_num) REFERENCES Pteradata.Sucursal(sucursal_num),

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
	cliente_fecha_nacimiento DATE
);

CREATE TABLE Pteradata.Ticket(
	ticket_num DECIMAL(18,0) PRIMARY KEY,
	sucursal_num INT,
	id_caja INT,
	legajo_empleado INT,
	id_tipo_comprobante INT,
	ticket_det_total DECIMAL(18,2),
	ticket_total_descuento_aplicado DECIMAL(18,2),
	ticket_det_descuento_producto DECIMAL(18,2),
	ticket_det_descuento_medio_pago  DECIMAL(18,2),
	ticket_fecha_hora DATETIME,
	ticket_total_envio DECIMAL(18,2),
	FOREIGN KEY (sucursal_num) REFERENCES Pteradata.Sucursal (sucursal_num),
	FOREIGN KEY (id_caja) REFERENCES Pteradata.Caja(id_caja),
	FOREIGN KEY (legajo_empleado) REFERENCES Pteradata.Empleado(legajo),
	FOREIGN KEY (id_tipo_comprobante) REFERENCES Pteradata.TipoDeComprobante(id_tipo_comprobante)
);

CREATE TABLE Pteradata.Envio(
	id_envio INT PRIMARY KEY IDENTITY(1,1),
	cliente_id INT,
	ticket_num DECIMAL(18,0),
	costo DECIMAL(18,2),
	fecha_programada DATETIME,
	hora_inicio DATETIME,
	hora_fin DATETIME,
	id_estado INT,
	
	FOREIGN KEY(cliente_id) REFERENCES Pteradata.Cliente(id_cliente),
	FOREIGN KEY(ticket_num) REFERENCES Pteradata.Ticket(ticket_num),
	FOREIGN KEY (id_estado) REFERENCES Pteradata.EnvioEstado(id_estado)
);


CREATE TABLE Pteradata.Categoria(
	producto_categoria VARCHAR(255) PRIMARY KEY,
	producto_sub_categoria VARCHAR(255),
	FOREIGN KEY (producto_sub_categoria) REFERENCES Pteradata.Categoria(producto_categoria)
);


CREATE TABLE Pteradata.Producto(
	producto_codigo INT PRIMARY KEY IDENTITY(1,1),
	producto_categoria VARCHAR(255),
	producto_nombre VARCHAR(255),
	id_marca INT,
	producto_descripcion VARCHAR(255),
	producto_precio DECIMAL(18,2),
	FOREIGN KEY (producto_categoria) REFERENCES Pteradata.Categoria(producto_categoria),
	FOREIGN KEY (id_marca) REFERENCES Pteradata.Marca(id_marca)
);




CREATE TABLE Pteradata.Promocion(
	promo_codigo DECIMAL(18,0) PRIMARY KEY,
	id_reglas INT,
	promocion_fecha_inicio DATETIME,
	promocion_fecha_fin DATETIME,
	promo_aplicada_descuento DECIMAL(18,2),
	promocion_descripcion VARCHAR(255),
	FOREIGN KEY (id_reglas) REFERENCES Pteradata.Reglas(id_reglas)
);

CREATE TABLE Pteradata.PromocionPorProducto(
	promo_codigo DECIMAL(18,0),
	producto_codigo INT,
	producto_precio_dto DECIMAL(18,2),
	PRIMARY KEY (promo_codigo, producto_codigo),
	FOREIGN KEY (promo_codigo) REFERENCES Pteradata.Promocion(promo_codigo),
	FOREIGN KEY (producto_codigo) REFERENCES Pteradata.Producto(producto_codigo),
);


CREATE TABLE Pteradata.TicketPorProductos(
	ticket_numero DECIMAL(18,0),
	producto_codigo INT,
	ticket_subtotal_con_descuento DECIMAL(18,2),
	ticket_subtotal_productos DECIMAL (18,2),
	ticket_det_cantidad DECIMAL(18,0),
	producto_precio DECIMAL(18,2),
	producto_precio_dto DECIMAL(18,2),
	PRIMARY KEY (ticket_numero, producto_codigo),
	FOREIGN KEY (ticket_numero) REFERENCES Pteradata.Ticket(ticket_num),
	FOREIGN KEY (producto_codigo) REFERENCES Pteradata.Producto(producto_codigo)
);




CREATE TABLE Pteradata.TipoPagoMedioPago (
	id_pago_tipo_medio_pago INT PRIMARY KEY IDENTITY(1,1),
	pago_tipo_medio_pago VARCHAR(255)
);


CREATE TABLE Pteradata.MedioPago (
	id_medio_pago INT PRIMARY KEY IDENTITY(1,1),
	pago_medio_pago VARCHAR(255) UNIQUE,
	id_pago_tipo_medio_pago INT UNIQUE,
	FOREIGN KEY (id_pago_tipo_medio_pago) REFERENCES Pteradata.TipoPagoMedioPago(id_pago_tipo_medio_pago)
);

CREATE TABLE Pteradata.Tarjeta(
	nro_tarjeta VARCHAR(50) PRIMARY KEY,
	id_cliente INT,
	FOREIGN KEY(id_cliente) REFERENCES Pteradata.Cliente(id_cliente),
	tarjeta_fecha_vencimiento DATETIME
);


CREATE TABLE Pteradata.DetallePago (
	id_pago_detalle INT PRIMARY KEY IDENTITY(1,1),
	nro_tarjeta VARCHAR(50),
	FOREIGN KEY (nro_tarjeta) REFERENCES Pteradata.Tarjeta(nro_tarjeta),
	cant_cuotas INT
);

CREATE TABLE Pteradata.Pago(
	nro_pago INT PRIMARY KEY IDENTITY(1,1),
	id_pago_detalle INT,
	FOREIGN KEY(id_pago_detalle) REFERENCES Pteradata.DetallePago(id_pago_detalle),
	pago_fecha DATETIME, 
	pago_importe DECIMAL(18,2),
	id_medio_pago INT,
	FOREIGN KEY(id_medio_pago) REFERENCES Pteradata.MedioPago(id_medio_pago)
);

CREATE TABLE Pteradata.DescuetoPorPago(
	id_pago INT,
	descuento_codigo DECIMAL(18,0),
	FOREIGN KEY(id_pago) REFERENCES Pteradata.Pago(nro_pago),
	FOREIGN KEY(descuento_codigo) REFERENCES Pteradata.Descuento(descuento_codigo),

	PRIMARY KEY (id_pago, descuento_codigo)
);


--TICKET

CREATE TABLE Pteradata.PagoPorTicket(
	nro_pago INT,
	ticket_numero DECIMAL(18,0),
	FOREIGN KEY(nro_pago) REFERENCES Pteradata.Pago(nro_pago),
	FOREIGN KEY(ticket_numero) REFERENCES Pteradata.Ticket(ticket_num),
	PRIMARY KEY (nro_pago, ticket_numero)
);
END
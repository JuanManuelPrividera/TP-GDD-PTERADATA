-- CREATE SCHEMA Pteradata
-- DROP PROCEDURE crearTodasLasTablas
GO

CREATE PROCEDURE crearTodasLasTablas AS 
/*
Con este procedure creamos todas las tablas con los datos necesarios 
segun el modelo de datos que creamos
*/
BEGIN
    CREATE TABLE Pteradata.Descuento(
        Descuento_Codigo DECIMAL (18,0) PRIMARY KEY,
        Descuento_Descripcion NVARCHAR (255),
        Descuento_fecha_inicio DATE,
        Descuento_fecha_fin DATE,
        Descuento_porcentaje_desc DECIMAL(18,2),
        Descuento_tope DECIMAL(18,2)
    );

    CREATE TABLE Pteradata.CajaTipo(
        id_caja_tipo INT PRIMARY KEY IDENTITY(1,1),
        caja_tipo NVARCHAR(255)
    );

    CREATE TABLE Pteradata.EnvioEstado(
        id_envio_estado INT PRIMARY KEY IDENTITY(1,1),
        envio_estado NVARCHAR(255)
    );

    create table Pteradata.Marca(
        id_marca INT PRIMARY KEY IDENTITY(1,1),
        Descripcion_marca NVARCHAR(255)
    );

    CREATE TABLE Pteradata.Reglas(
        id_reglas INT PRIMARY KEY IDENTITY(1,1),
        regla_aplica_misma_marca DECIMAL(18,0),
        regla_aplica_mismo_prod DECIMAL(18,0),
        regla_cant_aplica_Descuento DECIMAL(18,0),
        regla_cant_aplicable_regla DECIMAL (18,0),
        regla_cant_max_prod DECIMAL (18,0),
        regla_Descripcion NVARCHAR(255),
        regla_Descuento_aplicable_prod DECIMAL(18,2)
    );

    CREATE TABLE Pteradata.Provincia (
        id_provincia INT PRIMARY KEY IDENTITY(1,1),
        provincia_nombre NVARCHAR(255) UNIQUE,
    );

    CREATE TABLE Pteradata.Localidad (
        id_localidad INT PRIMARY KEY IDENTITY(1,1),
        id_provincia INT,
        localidad_nombre NVARCHAR(255) 

        FOREIGN KEY (id_provincia) REFERENCES Pteradata.Provincia(id_provincia),
    );

    CREATE TABLE Pteradata.Direccion(
        id_direccion INT PRIMARY KEY IDENTITY(1,1),
        id_localidad INT,
        domicilio NVARCHAR(255),

        FOREIGN KEY(id_localidad) REFERENCES Pteradata.Localidad(id_localidad) 
    );

    CREATE TABLE Pteradata.Supermercado(
        cuit NVARCHAR(255) PRIMARY KEY,
        id_direccion INT,
        nombre NVARCHAR(255),
        razon NVARCHAR(255),
        iibb NVARCHAR(255),
        fecha_ini_actividad DATETIME,
        condicion_fiscal NVARCHAR(255),

        FOREIGN KEY (id_direccion) REFERENCES Pteradata.Direccion(id_direccion)
    );

    CREATE TABLE Pteradata.Sucursal(
        sucursal_nombre NVARCHAR(255) PRIMARY KEY,
        cuit NVARCHAR(255),
        id_direccion INT,

        FOREIGN KEY(id_direccion) REFERENCES Pteradata.Direccion(id_direccion),
        FOREIGN KEY(cuit) REFERENCES Pteradata.Supermercado(cuit)
    );

	CREATE TABLE Pteradata.Caja(
        id_caja INT PRIMARY KEY IDENTITY(1,1),
        sucursal_nombre NVARCHAR(255),
        id_caja_tipo INT,
        caja_numero DECIMAL(18,0),

        FOREIGN KEY(sucursal_nombre) REFERENCES Pteradata.Sucursal(sucursal_nombre),
        FOREIGN KEY(id_caja_tipo) REFERENCES Pteradata.CajaTipo(id_caja_tipo),
    );

	CREATE TABLE Pteradata.Empleado(
        legajo_empleado INT PRIMARY KEY IDENTITY(100000,1),
		ID_Caja INT,
        sucursal_nombre NVARCHAR(255),
        empleado_dni DECIMAL(18,0),
        empleado_nombre NVARCHAR(255),
        empleado_apellido NVARCHAR(255),
        empleado_fecha_nacimiento DATETIME,
        empleado_fecha_registro DATETIME,

		FOREIGN KEY(ID_Caja) REFERENCES Pteradata.Caja(id_caja),
        FOREIGN KEY(sucursal_nombre) REFERENCES Pteradata.Sucursal(sucursal_nombre)
    );

	CREATE TABLE Pteradata.ContactoEmpleado(
        id_contacto_empleado INT PRIMARY KEY IDENTITY(1,1),
	    legajo_empleado INT,
        empleado_email NVARCHAR(255),
        empleado_telefono DECIMAL(18,0),

		FOREIGN KEY (legajo_empleado) REFERENCES Pteradata.Empleado(legajo_empleado)
    );

    CREATE TABLE Pteradata.Cliente(
        id_cliente INT PRIMARY KEY IDENTITY(1,1), 
        id_direccion INT,
        cliente_nombre NVARCHAR(255),
        cliente_apellido NVARCHAR(255),
        cliente_fecha_registro DATE,
        cliente_telefono DECIMAL (18,0),
        cliente_mail NVARCHAR(255),
        cliente_fecha_nacimiento DATE,
        cliente_dni DECIMAL(18,0),

        FOREIGN KEY(id_direccion) REFERENCES Pteradata.Direccion(id_direccion)
    );

-- Hay tickets que no tienen clientes
    CREATE TABLE Pteradata.Ticket(
        id_ticket INT PRIMARY KEY IDENTITY(1,1),
		id_caja INT,
		legajo_empleado INT,
        sucursal_nombre NVARCHAR(255),
        ticket_numero DECIMAL(18,0),
        ticket_total DECIMAL (18,2),
        ticket_total_envio DECIMAL(18,2),
        ticket_total_Descuento_aplicado DECIMAL(18,2),
        ticket_det_Descuento_medio_pago DECIMAL(18,2),
        ticket_fecha_hora DATETIME,
        ticket_subtotal_productos DECIMAL(18,2),

        FOREIGN KEY (sucursal_nombre) REFERENCES Pteradata.Sucursal (sucursal_nombre),
        FOREIGN KEY (id_caja) REFERENCES Pteradata.Caja(id_caja),
		FOREIGN KEY (legajo_empleado) REFERENCES Pteradata.Empleado(legajo_empleado)

    );

-- Si el ticket tiene cliente no tiene tipo y viceversa
	CREATE TABLE Pteradata.TipoDeComprobante(
        id_tipo_comprobante INT PRIMARY KEY IDENTITY(1,1),
        Tipo_Comprobante_Descripcion NVARCHAR(255),
        id_ticket INT,

        FOREIGN KEY (id_ticket) REFERENCES Pteradata.Ticket(id_ticket)
    );

    CREATE TABLE Pteradata.Envio(
        id_envio INT PRIMARY KEY IDENTITY(1,1),
        id_cliente INT,
        id_ticket INT,
        id_envio_estado INT,
        envio_costo DECIMAL(18,2),
        envio_fecha_programada DATETIME,
        envio_hora_inicio DATETIME,
        envio_hora_fin DATETIME,
        fecha_entregado DATETIME,
        
        FOREIGN KEY(id_cliente) REFERENCES Pteradata.Cliente(id_cliente),
        FOREIGN KEY(id_ticket) REFERENCES Pteradata.Ticket(id_ticket),
        FOREIGN KEY (id_envio_estado) REFERENCES Pteradata.EnvioEstado(id_envio_estado)
    );

    CREATE TABLE Pteradata.Categoria(
        producto_categoria NVARCHAR(255) PRIMARY KEY,
    );

    CREATE TABLE Pteradata.SubCategoria(
        id_producto_sub_categoria INT PRIMARY KEY IDENTITY(1,1),
		producto_sub_categoria NVARCHAR(255),
        producto_categoria NVARCHAR(255),

        FOREIGN KEY (producto_categoria) REFERENCES Pteradata.Categoria(producto_categoria)
    );

    CREATE TABLE Pteradata.Producto(
        Producto_Nombre NVARCHAR(255) PRIMARY KEY,
        Producto_Descripcion NVARCHAR(255),
    );

    CREATE TABLE Pteradata.ProductoPorMarca(
		id_producto_marca INT PRIMARY KEY IDENTITY(1,1),
        id_marca INT,
        producto_nombre NVARCHAR(255),
		precio DECIMAL(18,2),

        FOREIGN KEY (producto_nombre) REFERENCES Pteradata.Producto(producto_nombre),
        FOREIGN KEY (id_marca) REFERENCES Pteradata.Marca(id_marca)
    );


    CREATE TABLE Pteradata.ProductoPorCategoria(
        producto_categoria NVARCHAR(255),
        producto_nombre NVARCHAR(255),

        PRIMARY KEY (producto_nombre,producto_categoria),

        FOREIGN KEY (producto_categoria) REFERENCES Pteradata.Categoria(producto_categoria),
        FOREIGN KEY (producto_nombre) REFERENCES Pteradata.Producto(producto_nombre)
    );

    CREATE TABLE Pteradata.Promocion(
        Promocion_Codigo decimal(18,0) PRIMARY KEY,
        id_regla INT,
        Promocion_fecha_inicio DATETIME,
        Promocion_fecha_fin DATETIME,
        Promocion_Descripcion NVARCHAR(255),

        FOREIGN KEY (id_regla) REFERENCES Pteradata.Reglas(id_reglas)
    );

    CREATE TABLE Pteradata.PromocionPorProducto(
        ID_Promocion_Producto INT PRIMARY KEY IDENTITY(1, 1),
        producto_nombre NVARCHAR(255),
        Promocion_Codigo decimal(18,0),

        FOREIGN KEY (producto_nombre) REFERENCES Pteradata.Producto(producto_nombre),
        FOREIGN KEY (Promocion_Codigo) REFERENCES Pteradata.Promocion(Promocion_Codigo)
    );

    CREATE TABLE Pteradata.TicketPorProducto(
        id_ticket_producto INT PRIMARY KEY IDENTITY(1,1),
        id_ticket INT,
        id_Producto_Marca INT,
        ticket_det_cantidad DECIMAL(18,0),
        ticket_det_precio DECIMAL(18,2),
        ticket_det_total DECIMAL(18,2),

        FOREIGN KEY (id_ticket) REFERENCES Pteradata.Ticket(id_ticket),
        FOREIGN KEY (id_Producto_Marca) REFERENCES Pteradata.ProductoPorMarca(id_Producto_Marca)
    );

    CREATE TABLE Pteradata.PromocionAplicada(
        id_promocion_aplicada INT PRIMARY KEY IDENTITY(1,1),
		ID_Promocion_Producto INT,
        id_ticket_producto INT,
        Promocion_aplicada_dto DECIMAL(18,2),

        FOREIGN KEY (ID_Promocion_Producto) REFERENCES Pteradata.PromocionPorProducto(ID_Promocion_Producto),
        FOREIGN KEY (id_ticket_producto) REFERENCES Pteradata.TicketPorProducto(id_ticket_producto)
    );

    CREATE TABLE Pteradata.TipoPagoMedioPago (
        id_pago_tipo_medio_pago INT PRIMARY KEY IDENTITY(1,1),
        pago_tipo_medio_pago NVARCHAR(255)
    );

    CREATE TABLE Pteradata.MedioPago (
        id_medio_pago INT PRIMARY KEY IDENTITY(1,1),
        pago_medio_pago NVARCHAR(255) UNIQUE,
        id_pago_tipo_medio_pago INT,

        FOREIGN KEY (id_pago_tipo_medio_pago) REFERENCES Pteradata.TipoPagoMedioPago(id_pago_tipo_medio_pago)
    );

    CREATE TABLE Pteradata.Tarjeta(
        nro_tarjeta NVARCHAR(50) PRIMARY KEY,
        tarjeta_fecha_vencimiento DATETIME
    );

	--SELECT DISTINCT TICKET_NUMERO,CLIENTE_DNI, PAGO_MEDIO_PAGO, PAGO_TIPO_MEDIO_PAGO, TICKET_TOTAL_ENVIO, ENVIO_HORA_FIN, PAGO_TARJETA_NRO  FROM gd_esquema.Maestra
	--ORDER BY TICKET_NUMERO
	--SELECT * FROM gd_esquema.Maestra WHERE TICKET_NUMERO = 1351318314


    CREATE TABLE Pteradata.Pago(
        ID_Pago INT PRIMARY KEY IDENTITY(1,1),
        id_medio_pago INT,
        id_ticket INT,
        pago_fecha DATETIME, 
        pago_importe DECIMAL(18,2),

        FOREIGN KEY(id_medio_pago) REFERENCES Pteradata.MedioPago(id_medio_pago),
        FOREIGN KEY (id_ticket) REFERENCES Pteradata.Ticket(id_ticket)
    );

    CREATE TABLE Pteradata.DetallePago (
        id_pago_detalle INT PRIMARY KEY IDENTITY(1,1),
        nro_tarjeta NVARCHAR(50),
        ID_Pago INT,
        cant_cuotas DECIMAL(18,0),
		id_cliente INT,
        
	    FOREIGN KEY(ID_Pago) REFERENCES Pteradata.Pago(ID_Pago),
        FOREIGN KEY (nro_tarjeta) REFERENCES Pteradata.Tarjeta(nro_tarjeta),
		FOREIGN KEY (id_cliente) REFERENCES Pteradata.Cliente(id_cliente)
	);

    CREATE TABLE Pteradata.DescuentoPorPago(
        ID_Pago INT,
        Descuento_Codigo DECIMAL(18,0),
        Descuento_aplicado DECIMAL(18,2),

        PRIMARY KEY (ID_Pago, Descuento_Codigo),

        FOREIGN KEY(ID_Pago) REFERENCES Pteradata.Pago(ID_Pago),
        FOREIGN KEY(Descuento_Codigo) REFERENCES Pteradata.Descuento(Descuento_Codigo)
    );

END

GO

EXEC crearTodasLasTablas

GO

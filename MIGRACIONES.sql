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
GO


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
-- Este ya está
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
-- Este ya está
CREATE PROCEDURE migrarCliente AS
BEGIN
	INSERT INTO Pteradata.Cliente(id_direccion, cliente_nombre,cliente_apellido,cliente_fecha_registro,cliente_telefono,cliente_mail,cliente_fecha_nacimiento,cliente_dni)
	SELECT DISTINCT d.id_direccion, CLIENTE_NOMBRE, CLIENTE_APELLIDO, CLIENTE_FECHA_REGISTRO,CLIENTE_TELEFONO,CLIENTE_MAIL,CLIENTE_FECHA_NACIMIENTO,CLIENTE_DNI
	FROM gd_esquema.Maestra m 
	JOIN Pteradata.Direccion d ON m.CLIENTE_DOMICILIO = d.domicilio
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
-- Este ya está
CREATE PROCEDURE migrarSupermercado AS
BEGIN
	INSERT INTO Pteradata.Supermercado(cuit, id_direccion, nombre, razon,iibb,fecha_ini_actividad,condicion_fiscal)
	SELECT DISTINCT SUPER_CUIT, d.id_direccion,SUPER_NOMBRE ,SUPER_RAZON_SOC,SUPER_IIBB,SUPER_FECHA_INI_ACTIVIDAD,SUPER_CONDICION_FISCAL
	FROM gd_esquema.Maestra m 
	JOIN Pteradata.Direccion d ON m.SUPER_DOMICILIO = d.domicilio
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
-- Este ya está
CREATE PROCEDURE migrarSucursal AS
BEGIN
	INSERT INTO Pteradata.Sucursal(sucursal_nombre,id_direccion,cuit)
	SELECT DISTINCT SUCURSAL_NOMBRE, d.id_direccion, SUPER_CUIT
	FROM gd_esquema.Maestra m 
	JOIN Pteradata.Direccion d ON m.SUCURSAL_DIRECCION = d.domicilio
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
-- Este ya está
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
-- Este ya está
CREATE PROCEDURE migrarCaja AS
BEGIN
	INSERT INTO Pteradata.Caja(sucursal_nombre, id_caja_tipo, caja_numero)
	SELECT DISTINCT  sc.sucursal_nombre, ct.id_caja_tipo, m.CAJA_NUMERO
	FROM gd_esquema.Maestra m 
	JOIN Pteradata.Sucursal sc ON m.SUCURSAL_NOMBRE = sc.sucursal_nombre
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
-- Este ya está
CREATE PROCEDURE migrarEmpleados AS
BEGIN
	INSERT INTO Pteradata.Empleado(ID_Caja,sucursal_nombre,empleado_dni,empleado_nombre,empleado_apellido,empleado_fecha_nacimiento,empleado_fecha_registro)
	SELECT DISTINCT c.ID_Caja,s.sucursal_nombre,EMPLEADO_DNI,EMPLEADO_NOMBRE,EMPLEADO_APELLIDO,EMPLEADO_FECHA_NACIMIENTO,EMPLEADO_FECHA_REGISTRO
	FROM gd_esquema.Maestra g 
	JOIN Pteradata.Sucursal s ON g.SUCURSAL_NOMBRE = s.sucursal_nombre
	JOIN Pteradata.Caja c ON g.CAJA_NUMERO = c.caja_numero AND g.SUCURSAL_NOMBRE = c.sucursal_nombre
	WHERE EMPLEADO_DNI IS NOT NULL
END
/*
Este procedimiento tiene como objetivo migrar los datos de los diferentes empleados 
hacia la tabla Empleado.
Utilizamos SELECT DISTINCT para evitar la repeticion de empleados y JOINS
para relacionarlos con sus datos de contacto y la sucursal en la que trabajan.
*/
GO
-- Este ya está
CREATE PROCEDURE migrarContactoEmpleado AS
BEGIN
	INSERT INTO Pteradata.ContactoEmpleado(legajo_empleado,empleado_email,empleado_telefono)
	SELECT DISTINCT e.legajo_empleado, EMPLEADO_MAIL,EMPLEADO_TELEFONO
	FROM gd_esquema.Maestra g 
	JOIN Pteradata.Empleado e on g.EMPLEADO_DNI = e.empleado_dni 
END
/*
Este procedimiento tiene como objetivo migrar los contactos que existen de los empleados 
hacia la tabla ContactoEmpleado.
Utilizamos SELECT DISTINCT para evitar la repeticion de los contactos.
*/

GO
-- Este ya está
CREATE PROCEDURE migrarRegla AS
BEGIN
	INSERT INTO Pteradata.Reglas(regla_aplica_misma_marca,regla_aplica_mismo_prod,regla_cant_aplica_Descuento,
	regla_cant_aplicable_regla,regla_cant_max_prod,regla_Descripcion,regla_Descuento_aplicable_prod)

	SELECT DISTINCT REGLA_APLICA_MISMA_MARCA, REGLA_APLICA_MISMO_PROD, REGLA_CANT_APLICA_DESCUENTO, 
	REGLA_CANT_APLICABLE_REGLA, REGLA_CANT_MAX_PROD, REGLA_DESCRIPCION, REGLA_DESCUENTO_APLICABLE_PROD 
	FROM gd_esquema.Maestra
	WHERE REGLA_DESCRIPCION IS NOT NULL
END
/*
Este procedimiento tiene como objetivo migrar las diferentes reglas que hay sobre las Promociones
hacia la tabla Reglas.
Utilizamos SELECT DISTINCT para evitar la repeticion de las reglas.
*/
GO
-- Este ya está
CREATE PROCEDURE migrarDescuento AS
BEGIN
	INSERT INTO Pteradata.Descuento(Descuento_Codigo,Descuento_Descripcion, Descuento_fecha_inicio, 
	Descuento_fecha_fin, Descuento_porcentaje_desc, Descuento_tope)
	SELECT DISTINCT DESCUENTO_CODIGO,DESCUENTO_DESCRIPCION, DESCUENTO_FECHA_INICIO, DESCUENTO_FECHA_FIN,
	DESCUENTO_PORCENTAJE_DESC, DESCUENTO_TOPE 
	FROM gd_esquema.Maestra
	WHERE DESCUENTO_CODIGO IS NOT NULL
END
/*
Este procedimiento tiene como objetivo migrar los diferentes Descuentos que hay sobre los pagos
hacia la tabla Descuento.
Utilizamos SELECT DISTINCT para evitar la repeticion de los Descuentos.
*/
GO
-- Este ya está
CREATE PROCEDURE migrarMarca AS
BEGIN
	INSERT INTO Pteradata.Marca(Descripcion_marca)
	SELECT DISTINCT PRODUCTO_MARCA
	FROM gd_esquema.Maestra WHERE PRODUCTO_MARCA IS NOT NULL
END
/*
Este procedimiento tiene como objetivo migrar las diferentes marcas que hay
hacia la tabla Marca.
Utilizamos SELECT DISTINCT para evitar la repeticion de marcas.
*/
GO
-- Este ya está
CREATE PROCEDURE migrarCategoria AS
BEGIN
	INSERT INTO Pteradata.Categoria(producto_categoria)
	SELECT DISTINCT PRODUCTO_CATEGORIA
	FROM gd_esquema.Maestra WHERE PRODUCTO_CATEGORIA IS NOT NULL
END
/*
Este procedimiento tiene como objetivo migrar las diferentes categorias que puede pertenecer un producto
hacia la tabla Categoria.
Utilizamos SELECT DISTINCT para evitar la repeticion de categorias.
*/
GO
-- Este ya está
CREATE PROCEDURE migrarSubCategoria AS
BEGIN
	INSERT INTO Pteradata.SubCategoria(producto_categoria, producto_sub_categoria)
	SELECT DISTINCT c.producto_categoria, m.PRODUCTO_SUB_CATEGORIA FROM gd_esquema.Maestra m
	JOIN Pteradata.Categoria c ON c.producto_categoria = m.PRODUCTO_CATEGORIA
END

/*
Este procedimiento tiene como objetivo migrar las diferentes subcategorias que puede tener una categoria
hacia la tabla SubCategoria.
Utilizamos SELECT DISTINCT para evitar la repeticion de subcategorias.
*/
GO

-- Este ya está
CREATE PROCEDURE migrarProducto AS
BEGIN
	INSERT INTO Pteradata.Producto(Producto_Nombre,Producto_Descripcion)
	SELECT DISTINCT PRODUCTO_NOMBRE, PRODUCTO_DESCRIPCION
	FROM gd_esquema.Maestra WHERE PRODUCTO_NOMBRE IS NOT NULL	
END
/*
Este procedimiento tiene como objetivo migrar todos los productos que hay
hacia la tabla Producto.
Utilziamos SELECT DISTINCT para evitar la repeticion de productos.
*/
GO

-- Este ya está
CREATE PROCEDURE migrarProductoPorCategoria AS
BEGIN 
	INSERT INTO Pteradata.ProductoPorCategoria(producto_categoria, id_producto)
	SELECT DISTINCT PRODUCTO_CATEGORIA, p.id_producto FROM gd_esquema.Maestra M
	JOIN Pteradata.Producto p ON p.producto_nombre = M.PRODUCTO_NOMBRE
END 
/*
Este procedimiento tiene como objetivo unir los productos con la categoria a la que pertenecen
mediante la utilzacion de los JOINS hacia la tabla Categoria y Producto.
*/
GO

GO

-- Este ya está
CREATE PROCEDURE migrarTarjeta AS
BEGIN
	INSERT INTO Pteradata.Tarjeta(nro_tarjeta, tarjeta_fecha_vencimiento)
	SELECT DISTINCT  PAGO_TARJETA_NRO, PAGO_TARJETA_FECHA_VENC FROM gd_esquema.Maestra M
	WHERE PAGO_TARJETA_NRO IS NOT NULL AND PAGO_TARJETA_FECHA_VENC IS NOT NULL
END
/*
Este procedimiento tiene como objetivo migrar los datos de las Tarjetas de los clientes
hacia la tabla Tarjeta.
Utilizamos SELECT DISTINCT para evitar la repeticion de tarjetas.
*/

GO
-- Este ya está
CREATE PROCEDURE migrarPromocion AS
BEGIN
	INSERT INTO Pteradata.Promocion(Promocion_Codigo,id_regla,Promocion_fecha_inicio, Promocion_fecha_fin, Promocion_Descripcion)
	SELECT DISTINCT PROMO_CODIGO, r.id_reglas, PROMOCION_FECHA_INICIO, PROMOCION_FECHA_FIN,PROMOCION_DESCRIPCION
	FROM gd_esquema.Maestra m JOIN Pteradata.Reglas r ON m.REGLA_DESCRIPCION = r.regla_Descripcion
	WHERE PROMO_CODIGO IS NOT NULL
END
/*
Este procedimiento tiene como objetivo migrar las diferentes Promociones existentes
hacia la tabla Promocion.
Utilizamos SELECT DISTINCT para evitar la repeticion de Promociones y el JOIN
con la tabla Reglas para relacionar la Promocion con la regla que sigue.
*/
GO


CREATE PROCEDURE migrarProductoPorMarca AS
BEGIN
	INSERT INTO Pteradata.ProductoPorMarca(id_producto,id_marca, precio)
	SELECT DISTINCT p.id_producto,m.id_marca, PRODUCTO_PRECIO
	FROM gd_esquema.Maestra g 
	JOIN Pteradata.Marca m ON g.PRODUCTO_MARCA = m.Descripcion_marca
	JOIN Pteradata.Producto p ON g.PRODUCTO_NOMBRE = p.producto_nombre
END
/*
Este procedimiento tiene como objetivo unir los productos con la marca que los provee
mediante la utilzacion de los JOINS hacia la tabla Marca y Producto.
*/

GO

CREATE PROCEDURE migrarPromocionPorProducto AS
BEGIN
	INSERT INTO Pteradata.PromocionPorProducto(id_producto_marca,Promocion_Codigo)
	SELECT DISTINCT pm.id_producto_marca,PROMO_CODIGO FROM gd_esquema.Maestra M
	JOIN Pteradata.Producto p ON p.producto_nombre = M.PRODUCTO_NOMBRE
	JOIN Pteradata.Marca ma ON ma.Descripcion_marca = M.PRODUCTO_MARCA
	JOIN Pteradata.ProductoPorMarca pm ON p.id_producto = pm.id_producto AND ma.id_marca = pm.id_marca
	WHERE PROMO_CODIGO IS NOT NULL
END
/*
Este procedimiento tiene como objetivo relacionar las diferentes Promociones con los productos sobre las que se aplican.
*/

GO

CREATE PROCEDURE migrarEnvioEstado AS
BEGIN
	INSERT INTO Pteradata.EnvioEstado(envio_estado)
	SELECT DISTINCT
		CASE
			WHEN ENVIO_ESTADO = 'Finalizado' THEN 'Finalizado'
			WHEN ENVIO_ESTADO IS NULL THEN 'En proceso' 
		END envio_estado
	FROM gd_esquema.Maestra
END
/*
Este procedimiento tiene como objetivo migrar los diferentes estados que puede tener un envio
hacia la tabla EnvioEstado.
Utilizamos SELECT DISTINCT para evitar la repeticion de estados.
*/
GO

CREATE PROCEDURE migrarTicket AS
BEGIN
	INSERT INTO Pteradata.Ticket(id_caja,legajo_empleado,sucursal_nombre,ticket_numero,ticket_total, ticket_total_envio,ticket_total_Descuento_aplicado, ticket_det_Descuento_medio_pago, 
								ticket_fecha_hora,ticket_subtotal_productos)
	SELECT DISTINCT c.id_caja,e.legajo_empleado,s.sucursal_nombre,TICKET_NUMERO,TICKET_TOTAL_TICKET,TICKET_TOTAL_ENVIO,TICKET_TOTAL_DESCUENTO_APLICADO,
					TICKET_TOTAL_DESCUENTO_APLICADO_MP,TICKET_FECHA_HORA,TICKET_SUBTOTAL_PRODUCTOS
	FROM gd_esquema.Maestra g 
	JOIN Pteradata.Sucursal s ON s.sucursal_nombre = g.SUCURSAL_NOMBRE
	JOIN Pteradata.Caja c ON c.caja_numero = g.CAJA_NUMERO AND c.sucursal_nombre = g.SUCURSAL_NOMBRE
	JOIN Pteradata.Empleado e ON e.empleado_dni = g.EMPLEADO_DNI
	ORDER BY TICKET_NUMERO
	
END

/*
Este procedimiento tiene como objetivo migrar los diferentes tickets que hay
hacia la tabla Ticket.
Utilizamos SELECT DISTINCT para evitar la repeticion de tickets y los JOIN
hacia las tablas Sucursal, Caja, Empleado y TipoDeComprobante para relacionar cada ticket con la sucursal y la caja donde se creo el ticket, 
el empleado que lo genero y el tipo de comprobante del ticket.
*/

GO

/*
Este procedimiento tiene como objetivo relacionar los datos de los pagos con tarjeta con su detalle
hacia la tabla DetallePago.
Utilizamos los JOIN a las tablas Tarjeta y Pago para relacionar la cantidad de cuotas que se saco el pago
*/


CREATE PROCEDURE migrarTipoPagoMedioPago AS
BEGIN 
	INSERT INTO Pteradata.TipoPagoMedioPago(pago_tipo_medio_pago)
	SELECT DISTINCT PAGO_TIPO_MEDIO_PAGO
	FROM gd_esquema.Maestra
	WHERE PAGO_TIPO_MEDIO_PAGO IS NOT NULL
END
/*
Este procedimiento tiene como objetivo migrar los diferentes tipos de medio de pago
hacia la tabla TipoPagoMedioPago.
Utilizamos SELECT DISTINCT para evitar la repeticion de tipos medios de pago.
*/
GO

CREATE PROCEDURE migrarEnvio AS
BEGIN
	INSERT INTO Pteradata.Envio(id_cliente, id_ticket, id_envio_estado ,envio_costo, envio_fecha_programada, envio_hora_inicio, envio_hora_fin, fecha_entregado)
	SELECT DISTINCT c.id_cliente, t.id_ticket, e.id_envio_estado, g.ENVIO_COSTO, g.ENVIO_FECHA_PROGRAMADA, g.ENVIO_HORA_INICIO, g.ENVIO_HORA_FIN, g.ENVIO_FECHA_ENTREGA
	FROM gd_esquema.Maestra g
	JOIN Pteradata.EnvioEstado e ON e.envio_estado = g.ENVIO_ESTADO
	JOIN Pteradata.Cliente c ON c.cliente_dni = g.CLIENTE_DNI
	LEFT JOIN Pteradata.Ticket t on t.ticket_numero = g.TICKET_NUMERO
END
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
	INSERT INTO Pteradata.Pago(id_medio_pago, id_ticket, pago_fecha,pago_importe)
	SELECT DISTINCT mp.id_medio_pago, t.id_ticket,PAGO_FECHA, PAGO_IMPORTE FROM gd_esquema.Maestra m
	JOIN Pteradata.MedioPago mp ON mp.pago_medio_pago = m.PAGO_MEDIO_PAGO
	JOIN Pteradata.Ticket t ON t.ticket_numero = m.TICKET_NUMERO
END

/*
Este procedimiento tiene como objetivo migrar los diferentes pagos
hacia la tabla MedioPago.
Utilizamos los JOIN hacia las tablas MedioPago y TipoPagoMedioPago
para relacionar cada pago con el tipo y medio de pago al que pertenecen.
*/
GO
CREATE PROCEDURE migrarDetallePago AS
BEGIN
WITH DetalleCliente AS (
    SELECT DISTINCT
        g.TICKET_NUMERO AS ticket,
        g.PAGO_IMPORTE AS importe,
        g.PAGO_FECHA AS fecha,
        g.PAGO_TARJETA_NRO AS tarjeta,
        g.PAGO_TARJETA_CUOTAS as cuotas,
        g.PAGO_TIPO_MEDIO_PAGO AS tipo_medio,
        g.PAGO_MEDIO_PAGO as medio_pago
    FROM
        gd_esquema.Maestra g
    JOIN
        Pteradata.Ticket t ON t.ticket_numero = g.TICKET_NUMERO
    WHERE
        g.PAGO_IMPORTE IS NOT NULL 
        AND g.TICKET_NUMERO IS NOT NULL 
        AND g.PAGO_FECHA IS NOT NULL 
        AND g.PAGO_MEDIO_PAGO IS NOT NULL
)
--INSERT INTO Pteradata.DetallePago(nro_tarjeta, cant_cuotas, ID_Pago, id_cliente)
SELECT
    (CASE 
        WHEN dc.tipo_medio IN ('Ejectivo') THEN NULL
        ELSE tr.nro_tarjeta
    END) AS TARJETA,
    dc.cuotas,
	p.ID_Pago,
    c.id_cliente
FROM DetalleCliente dc
JOIN gd_esquema.Maestra g ON g.TICKET_NUMERO = dc.ticket
LEFT JOIN Pteradata.Tarjeta tr ON tr.nro_tarjeta = dc.tarjeta
JOIN Pteradata.Cliente c ON c.cliente_dni = g.CLIENTE_DNI
JOIN Pteradata.TipoPagoMedioPago tmp ON tmp.pago_tipo_medio_pago = dc.tipo_medio
JOIN Pteradata.MedioPago mp ON mp.pago_medio_pago =dc.medio_pago AND mp.id_pago_tipo_medio_pago = tmp.id_pago_tipo_medio_pago
JOIN Pteradata.Pago p ON dc.importe = p.pago_importe AND dc.fecha = p.pago_fecha AND p.id_medio_pago = mp.id_medio_pago
WHERE g.CLIENTE_DNI IS NOT NULL 
AND (CASE 
        WHEN dc.tipo_medio IN ('Ejectivo') THEN NULL
        ELSE tr.nro_tarjeta
    END) is not null;
END

GO 

CREATE PROCEDURE migrarTipoComprobante AS
BEGIN
	INSERT INTO Pteradata.TipoDeComprobante(Tipo_Comprobante_Descripcion)
	SELECT DISTINCT TICKET_TIPO_COMPROBANTE
		FROM gd_esquema.Maestra M 
END
/*
El objetivo de este procedimiento es el de migrar los distintos tipos de comprobantes 
que existen en la tabla maestra hacia la tabla TipoDeComprobante
*/
GO

CREATE PROCEDURE migrarTicketPorProducto AS
BEGIN
	INSERT INTO Pteradata.TicketPorProducto(id_ticket,id_Producto_Marca, ticket_det_cantidad, ticket_det_precio, ticket_det_total)
	SELECT DISTINCT t.id_ticket, pm.id_producto_marca, TICKET_DET_CANTIDAD,TICKET_DET_PRECIO,TICKET_DET_TOTAL
	FROM gd_esquema.Maestra g
	JOIN Pteradata.Ticket t ON g.TICKET_NUMERO = t.ticket_numero
	JOIN Pteradata.Marca m ON g.PRODUCTO_MARCA = m.Descripcion_marca
	JOIN Pteradata.Producto p ON p.Producto_Nombre = g.PRODUCTO_NOMBRE
	JOIN Pteradata.ProductoPorMarca pm ON m.id_marca = pm.id_marca AND p.id_producto = pm.id_producto
END


/*
Este procedimiento tiene como objetivo migrar los diferentes items que tiene un ticket
hacia la tabla TicketPorProductos.
*/
GO

CREATE PROCEDURE migrarPomocionAplicada AS
BEGIN
	INSERT INTO Pteradata.PromocionAplicada(id_Promocion_Producto, id_ticket_producto,Promocion_aplicada_dto)
	SELECT DISTINCT pn.id_Promocion_Producto, tp.id_ticket_producto, g.PROMO_APLICADA_DESCUENTO
	FROM gd_esquema.Maestra g
	JOIN Pteradata.Ticket t ON t.ticket_numero = g.TICKET_NUMERO
	JOIN Pteradata.Producto p ON p.Producto_Nombre = g.PRODUCTO_NOMBRE
	JOIN Pteradata.Marca m ON m.Descripcion_marca = g.PRODUCTO_MARCA
	JOIN Pteradata.ProductoPorMarca pm ON pm.id_producto = p.id_producto AND m.id_marca = pm.id_marca
	JOIN Pteradata.PromocionPorProducto pn ON pn.Promocion_Codigo = g.PROMO_CODIGO AND pn.id_producto_marca = pm.id_producto_marca
	JOIN Pteradata.TicketPorProducto tp ON tp.id_ticket = t.id_ticket AND tp.id_Producto_Marca = pm.id_producto_marca	
END

GO

CREATE PROCEDURE migrarDescuentoPorPago AS
BEGIN
	INSERT INTO Pteradata.DescuentoPorPago(id_pago,Descuento_Codigo,Descuento_aplicado)
	SELECT p.ID_Pago, d.Descuento_Codigo, PAGO_DESCUENTO_APLICADO
	FROM gd_esquema.Maestra m
	JOIN Pteradata.Descuento d ON m.DESCUENTO_CODIGO = d.Descuento_Codigo
	JOIN Pteradata.Pago p ON m.PAGO_FECHA = p.pago_fecha AND m.PAGO_IMPORTE = p.pago_importe 
END


/*
Este procedimiento tiene como objetivo migrar los Descuentos aplicados a los pagos
hacia la tabla DescuetoPorPago
*/
GO
CREATE PROCEDURE migrarTodo AS
BEGIN
	EXEC migrarProvincia;
	EXEC migrarLocalidad;
	EXEC migrarDireccion;
	EXEC migrarCliente;
	EXEC migrarSupermercado;
	EXEC migrarSucursal;
	EXEC migrarCajaTipo;
	EXEC migrarCaja;
	EXEC migrarEmpleados; 
	EXEC migrarContactoEmpleado;
	EXEC migrarRegla;
	EXEC migrarDescuento;
	EXEC migrarMarca;
	EXEC migrarCategoria;
	EXEC migrarSubCategoria;
	EXEC migrarProducto;
	EXEC migrarProductoPorCategoria;
	EXEC migrarTarjeta;
	EXEC migrarPromocion;
	EXEC migrarProductoPorMarca;
	EXEC migrarPromocionPorProducto;
	EXEC migrarEnvioEstado;
	EXEC migrarTicket;
	EXEC migrarTipoPagoMedioPago;
	EXEC migrarEnvio;
	EXEC migrarMedioPago;
	EXEC migrarPago;
	EXEC migrarDetallePago;
	EXEC migrarTipoComprobante;
	EXEC migrarTicketPorProducto;
	EXEC migrarPomocionAplicada;
	EXEC migrarDescuentoPorPago
END 
GO
EXEC migrarTodo

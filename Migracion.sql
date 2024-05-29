
--exec migrarTodo
--drop PROCEDURE migrarTodo

--select * from sys.procedures

/*
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
	--EXEC migrarPago;
	--EXEC migrarDetallePago;
	EXEC migrarPromocion;
	EXEC migrarPromocionPorProducto;
	EXEC migrarPomocionAplicada;
	EXEC migrarEnvio;
	EXEC migrarTicket;
	EXEC migrarTicketPorProductos;
END 
*/


CREATE PROCEDURE migrarTipoComprobantes AS
BEGIN
	INSERT INTO Pteradata.TipoDeComprobante(tipo_comprobante)
	SELECT DISTINCT TICKET_TIPO_COMPROBANTE FROM gd_esquema.Maestra
END

go

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
go

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

go

CREATE PROCEDURE migrarClientes AS
BEGIN
	INSERT INTO Pteradata.Cliente(dni_cliente,id_direccion, cliente_nombre,cliente_apellido,cliente_fecha_registro,cliente_telefono,cliente_mail,cliente_fecha_nacimiento)
	SELECT CLIENTE_DNI, d.id_direccion, CLIENTE_NOMBRE, CLIENTE_APELLIDO, CLIENTE_FECHA_REGISTRO,CLIENTE_TELEFONO,CLIENTE_MAIL,CLIENTE_FECHA_NACIMIENTO
	FROM gd_esquema.Maestra m JOIN Pteradata.Direccion d ON m.CLIENTE_DOMICILIO = d.domicilio
							  JOIN Pteradata.Localidad l ON l.id_localidad = d.id_localidad AND l.localidad_nombre = m.CLIENTE_LOCALIDAD
							  JOIN Pteradata.Provincia p ON l.id_provincia = p.id_provincia AND p.provincia_nombre = m.CLIENTE_PROVINCIA
END

go

CREATE PROCEDURE migrarSupermercado AS
BEGIN
	INSERT INTO Pteradata.Supermercado(cuit, id_direccion, nombre, razon,iibb,fecha_ini_actividad,condicion_fiscal)
	SELECT DISTINCT SUPER_CUIT, d.id_direccion,SUPER_NOMBRE ,SUPER_RAZON_SOC,SUPER_IIBB,SUPER_FECHA_INI_ACTIVIDAD,SUPER_CONDICION_FISCAL
	FROM gd_esquema.Maestra m JOIN Pteradata.Direccion d ON m.SUPER_DOMICILIO = d.domicilio
							  JOIN Pteradata.Localidad l ON l.id_localidad = d.id_localidad AND l.localidad_nombre = m.SUPER_LOCALIDAD
							  JOIN Pteradata.Provincia p ON l.id_provincia = p.id_provincia AND p.provincia_nombre = m.SUPER_PROVINCIA
END

go

CREATE PROCEDURE migrarSucursal AS
BEGIN
	INSERT INTO Pteradata.Sucursal(sucursal_nombre,id_direccion,cuit)
	SELECT DISTINCT SUCURSAL_NOMBRE, d.id_direccion, SUPER_CUIT
	FROM gd_esquema.Maestra m JOIN Pteradata.Direccion d ON m.SUCURSAL_DIRECCION = d.domicilio
							  JOIN Pteradata.Localidad l ON l.id_localidad = d.id_localidad AND l.localidad_nombre = m.SUCURSAL_LOCALIDAD
							  JOIN Pteradata.Provincia p ON l.id_provincia = p.id_provincia AND p.provincia_nombre = m.SUCURSAL_PROVINCIA
END

go

CREATE PROCEDURE migrarCajaTipo AS
BEGIN
	INSERT INTO Pteradata.CajaTipo(caja_tipo)
	SELECT DISTINCT CAJA_TIPO FROM gd_esquema.Maestra
	WHERE CAJA_TIPO IS NOT NULL
END

go

CREATE PROCEDURE migrarCajas AS
BEGIN
	INSERT INTO Pteradata.Caja(caja_num,sucursal_nombre,id_caja_tipo)
	SELECT DISTINCT m.CAJA_NUMERO, sc.sucursal_nombre, ct.id_caja_tipo
	FROM gd_esquema.Maestra m JOIN Pteradata.Sucursal sc ON m.SUCURSAL_NOMBRE = sc.sucursal_nombre
							  JOIN Pteradata.CajaTipo ct ON m.CAJA_TIPO = ct.caja_tipo
							  WHERE m.CAJA_NUMERO IS NOT NULL
END

go

CREATE PROCEDURE migrarContactoEmpleado AS
BEGIN
	INSERT INTO Pteradata.ContactoEmpleado(email, telefono)
	SELECT DISTINCT EMPLEADO_MAIL, EMPLEADO_TELEFONO FROM gd_esquema.Maestra
	WHERE EMPLEADO_MAIL IS NOT NULL AND EMPLEADO_TELEFONO IS NOT NULL
END

go

CREATE PROCEDURE migrarEmpleados AS
BEGIN
	INSERT INTO Pteradata.Empleado(id_contacto, sucursal_nombre,dni,nombre,apellido,fecha_nacimiento,fecha_registro)
	SELECT DISTINCT ce.id_contacto, s.sucursal_nombre,EMPLEADO_DNI,EMPLEADO_NOMBRE,EMPLEADO_APELLIDO,EMPLEADO_FECHA_NACIMIENTO,EMPLEADO_FECHA_REGISTRO
	FROM gd_esquema.Maestra m JOIN Pteradata.ContactoEmpleado ce ON ce.email = m.EMPLEADO_MAIL AND ce.telefono = m.EMPLEADO_TELEFONO
							  JOIN Pteradata.Sucursal s ON m.SUCURSAL_NOMBRE = s.sucursal_nombre
END

go

CREATE PROCEDURE migrarReglas AS
BEGIN
	INSERT INTO Pteradata.Reglas(regla_aplica_misma_marca,regla_aplica_mismo_prod,regla_cant_aplica_descuento,
	regla_cant_aplicable_regla,regla_cant_max_prod,regla_descripcion,regla_descuento_aplicable_prod)
	
	SELECT DISTINCT REGLA_APLICA_MISMA_MARCA, REGLA_APLICA_MISMO_PROD, REGLA_CANT_APLICA_DESCUENTO, 
	REGLA_CANT_APLICABLE_REGLA, REGLA_CANT_MAX_PROD, REGLA_DESCRIPCION, REGLA_DESCUENTO_APLICABLE_PROD 
	FROM gd_esquema.Maestra
	WHERE REGLA_DESCRIPCION IS NOT NULL
END

go

CREATE PROCEDURE migrarDescuentos AS
BEGIN
	INSERT INTO Pteradata.Descuento(descuento_codigo,descuento_descripcion, descuento_fecha_inicio, 
	descuento_fecha_fin, descuento_porcentaje_desc, descuento_tope)
	SELECT DISTINCT DESCUENTO_CODIGO,DESCUENTO_DESCRIPCION, DESCUENTO_FECHA_INICIO, DESCUENTO_FECHA_FIN,
	DESCUENTO_PORCENTAJE_DESC, DESCUENTO_TOPE FROM gd_esquema.Maestra
	WHERE DESCUENTO_CODIGO IS NOT NULL
END

go

CREATE PROCEDURE migrarMarcas AS
BEGIN
	INSERT INTO Pteradata.Marca(producto_marca)
	SELECT DISTINCT PRODUCTO_MARCA FROM gd_esquema.Maestra
	WHERE PRODUCTO_MARCA IS NOT NULL
END

go

CREATE PROCEDURE migrarCategorias AS
BEGIN
	INSERT INTO Pteradata.Categoria(producto_categoria)
	SELECT DISTINCT PRODUCTO_CATEGORIA FROM gd_esquema.Maestra
	WHERE PRODUCTO_CATEGORIA IS NOT NULL
END

go

CREATE PROCEDURE migrarSubCategorias AS
BEGIN 
	INSERT INTO Pteradata.SubCategoria(producto_sub_categoria, producto_categoria)
	SELECT DISTINCT PRODUCTO_SUB_CATEGORIA, PRODUCTO_CATEGORIA FROM gd_esquema.Maestra
	WHERE PRODUCTO_CATEGORIA IS NOT NULL AND PRODUCTO_SUB_CATEGORIA IS NOT NULL
END

go

CREATE PROCEDURE migrarProductos AS
BEGIN
	INSERT INTO Pteradata.Producto(producto_nombre,producto_descripcion)
	SELECT DISTINCT PRODUCTO_NOMBRE, PRODUCTO_DESCRIPCION
	FROM gd_esquema.Maestra
	where PRODUCTO_NOMBRE is not null
END

go

--REVISAR
CREATE PROCEDURE migrarProductoPorCategoria AS
BEGIN 

	INSERT INTO Pteradata.ProductoPorCategoria(producto_categoria, producto_nombre)
		SELECT DISTINCT c.producto_categoria, p.producto_nombre
			FROM gd_esquema.Maestra m
			JOIN Pteradata.Categoria c on c.producto_categoria = m.PRODUCTO_CATEGORIA
			JOIN Pteradata.Producto p on p.producto_nombre = m.PRODUCTO_NOMBRE

END 

go

CREATE PROCEDURE migrarProductoPorMarca AS
BEGIN 

	INSERT INTO Pteradata.ProductoPorMarca(producto_marca, producto_nombre, precio)
		SELECT DISTINCT m.producto_marca, p.producto_nombre, g.PRODUCTO_PRECIO
			FROM gd_esquema.Maestra g 
			JOIN Pteradata.Marca m on m.producto_marca = g.PRODUCTO_MARCA
			JOIN Pteradata.Producto p on p.producto_nombre = g.PRODUCTO_NOMBRE
END

go

CREATE PROCEDURE migrarTarjetas AS
BEGIN
	INSERT INTO Pteradata.Tarjeta(nro_tarjeta, tarjeta_fecha_vencimiento)
	SELECT DISTINCT PAGO_TARJETA_NRO, PAGO_TARJETA_FECHA_VENC FROM gd_esquema.Maestra
	WHERE PAGO_TARJETA_NRO IS NOT NULL AND PAGO_TARJETA_FECHA_VENC IS NOT NULL
END

go

CREATE PROCEDURE migrarTipoPagoMedioPago AS
BEGIN 
	INSERT INTO Pteradata.TipoPagoMedioPago(pago_tipo_medio_pago)
		SELECT DISTINCT PAGO_TIPO_MEDIO_PAGO
			FROM gd_esquema.Maestra
			WHERE PAGO_TIPO_MEDIO_PAGO is not null
END

go

CREATE PROCEDURE migrarMedioPago AS
BEGIN
	INSERT INTO Pteradata.MedioPago(pago_medio_pago, id_pago_tipo_medio_pago)
	SELECT DISTINCT g.PAGO_MEDIO_PAGO, t.id_pago_tipo_medio_pago FROM gd_esquema.Maestra g
	JOIN Pteradata.TipoPagoMedioPago t ON g.PAGO_TIPO_MEDIO_PAGO = t.pago_tipo_medio_pago
END

go

/*
CREATE PROCEDURE migrarPago AS --FALTA ID CLIENTE
BEGIN
	INSERT INTO Pteradata.Pago(pago_fecha,pago_importe, id_medio_pago)
	SELECT PAGO_FECHA, PAGO_IMPORTE, m.id_medio_pago FROM gd_esquema.Maestra g
	JOIN Pteradata.MedioPago m ON m.pago_medio_pago = g.PAGO_MEDIO_PAGO
	JOIN Pteradata.TipoPagoMedioPago t ON (t.id_pago_tipo_medio_pago = m.id_pago_tipo_medio_pago
	AND g.PAGO_TIPO_MEDIO_PAGO = t.pago_tipo_medio_pago)
END
*/


/*
CREATE PROCEDURE migrarDetallePago AS
BEGIN 
	INSERT INTO Pteradata.DetallePago(nro_tarjeta, nro_pago, cant_cuotas)
	SELECT t.nro_tarjeta, nro_pago, PAGO_TARJETA_CUOTAS FROM gd_esquema.Maestra m
	JOIN Pteradata.Tarjeta t ON m.PAGO_TARJETA_NRO = t.nro_tarjeta
	JOIN Pteradata.Pago p ON p.
END
*/

CREATE PROCEDURE migrarPromocion AS
BEGIN
	INSERT INTO Pteradata.Promocion(promo_codigo, id_reglas, promocion_fecha_inicio, promocion_fecha_fin, promocion_descripcion)
	SELECT DISTINCT g.PROMO_CODIGO, r.id_reglas, PROMOCION_FECHA_INICIO, PROMOCION_FECHA_FIN, PROMOCION_DESCRIPCION 
		FROM gd_esquema.Maestra g
		JOIN Pteradata.Reglas r ON r.regla_descripcion = g.REGLA_DESCRIPCION
END

go

CREATE PROCEDURE migrarPromocionPorProducto AS
BEGIN
	INSERT INTO Pteradata.PromocionPorProducto(promo_codigo, producto_nombre)
	SELECT DISTINCT PROMO_CODIGO, p.producto_nombre
		FROM gd_esquema.Maestra m 
		JOIN Pteradata.Producto p ON m.PRODUCTO_NOMBRE = p.producto_nombre
	where PROMO_CODIGO is not null
END

go
33501
CREATE PROCEDURE migrarPomocionAplicada AS
BEGIN

	INSERT INTO Pteradata.PromocionAplicada(id_promocion_producto, promo_aplicada_dto)
		SELECT DISTINCT coutn(PROMO_APLICADA_DESCUENTO), pn.id_promocion_producto, g.PROMO_APLICADA_DESCUENTO
			FROM gd_esquema.Maestra g
			JOIN Pteradata.PromocionPorProducto pn on pn.promo_codigo = g.PROMO_CODIGO
END

go

CREATE PROCEDURE migrarEnvioEstados AS
BEGIN
	INSERT INTO Pteradata.EnvioEstado(estado)
	SELECT DISTINCT ENVIO_ESTADO FROM gd_esquema.Maestra
	WHERE ENVIO_ESTADO IS NOT NULL 
END

go

CREATE PROCEDURE migrarEnvio AS
BEGIN
	INSERT INTO Pteradata.Envio(cliente_id, ticket_num, costo, fecha_programada, hora_inicio, hora_fin, id_estado, fecha_entregado)
		SELECT c.id_cliente, t.ticket_num, g.ENVIO_COSTO, g.ENVIO_FECHA_PROGRAMADA, g.ENVIO_HORA_INICIO, g.ENVIO_HORA_FIN, e.id_estado, g.ENVIO_FECHA_ENTREGA
			FROM gd_esquema.Maestra g
			JOIN Pteradata.EnvioEstado e ON e.estado = g.ENVIO_ESTADO
			JOIN Pteradata.Cliente c ON c.dni_cliente = g.CLIENTE_DNI
			JOIN Pteradata.Ticket t on t.ticket_num = g.TICKET_NUMERO
END

go

CREATE PROCEDURE migrarTicket AS
BEGIN

	INSERT INTO Pteradata.Ticket(ticket_num, sucursal_nombre, id_caja, legajo_empleado, tipo_comprobante, ticket_total, ticket_total_envio, ticket_total_descuento_aplicado, 
								 ticket_det_descuento_medio_pago, ticket_fecha_hora)

		SELECT DISTINCT m.TICKET_NUMERO, s.sucursal_nombre, c.id_caja ,e.legajo, t.tipo_comprobante, m.TICKET_TOTAL_TICKET, m.TICKET_TOTAL_ENVIO, m.TICKET_TOTAL_DESCUENTO_APLICADO, 
						m.TICKET_TOTAL_DESCUENTO_APLICADO_MP, m.TICKET_FECHA_HORA
			FROM gd_esquema.Maestra m
			right JOIN Pteradata.Sucursal s on s.sucursal_nombre = m.SUCURSAL_NOMBRE
			right JOIN Pteradata.Caja c on c.caja_num = m.CAJA_NUMERO and c.sucursal_nombre = m.SUCURSAL_NOMBRE 
			right JOIN Pteradata.Empleado e on e.sucursal_nombre = s.sucursal_nombre
			right JOIN Pteradata.TipoDeComprobante t on t.tipo_comprobante = m.TICKET_TIPO_COMPROBANTE
			where m.TICKET_NUMERO = 1353057379 and e.legajo = 100063 and c.id_caja = 90
END

go

CREATE PROCEDURE migrarTicketPorProductos AS 
BEGIN

	INSERT INTO Pteradata.TicketPorProductos(ticket_numero, id_producto_marca, id_caja, ticket_det_cantidad, ticket_det_total)

		SELECT t.ticket_num, p.id_producto_marca, t.id_caja,  m.TICKET_DET_CANTIDAD, m.TICKET_DET_TOTAL
			FROM gd_esquema.Maestra m
			JOIN Pteradata.ProductoPorMarca p on (p.producto_nombre = m.PRODUCTO_NOMBRE and p.producto_marca = m.PRODUCTO_MARCA)
			JOIN Pteradata.Ticket t on t.ticket_num = m.TICKET_NUMERO
END

go

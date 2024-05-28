/*
CREATE PROCEDURE migrarTodo AS
BEGIN
	BEGIN TRANSACTION 
	
	BEGIN TRY 
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
		EXEC migrarEnvioEstado;
		EXEC migrarTipoComprobante;
		EXEC migrarMarcas;
		EXEC migrarCategorias;
		EXEC migrarSubCategorias;
		EXEC migrarProductos;
		EXEC migrarTarjetas;
		EXEC migrarTipoPagoMedioPago;
		EXEC migrarMedioPago;
		-- EXEC migrarPago;
	END TRY 
	BEGIN CATCH 
		ROLLBACK
	END CATCH

	COMMIT TRANSACTION 
END 
*/
--exec migrarTodo


exec migrarTodo
--select * from Provincia
--exec migrarProvincia;
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

CREATE PROCEDURE migrarClientes AS
BEGIN
	INSERT INTO Pteradata.Cliente(dni_cliente,id_direccion, cliente_nombre,cliente_apellido,cliente_fecha_registro,cliente_telefono,cliente_mail,cliente_fecha_nacimiento)
	SELECT CLIENTE_DNI, d.id_direccion, CLIENTE_NOMBRE, CLIENTE_APELLIDO, CLIENTE_FECHA_REGISTRO,CLIENTE_TELEFONO,CLIENTE_MAIL,CLIENTE_FECHA_NACIMIENTO
	FROM gd_esquema.Maestra m JOIN Pteradata.Direccion d ON m.CLIENTE_DOMICILIO = d.domicilio
							  JOIN Pteradata.Localidad l ON l.id_localidad = d.id_localidad AND l.localidad_nombre = m.CLIENTE_LOCALIDAD
							  JOIN Pteradata.Provincia p ON l.id_provincia = p.id_provincia AND p.provincia_nombre = m.CLIENTE_PROVINCIA
END

CREATE PROCEDURE migrarSupermercado AS
BEGIN
	INSERT INTO Pteradata.Supermercado(cuit, id_direccion, nombre, razon,iibb,fecha_ini_actividad,condicion_fiscal)
	SELECT DISTINCT SUPER_CUIT, d.id_direccion,SUPER_NOMBRE ,SUPER_RAZON_SOC,SUPER_IIBB,SUPER_FECHA_INI_ACTIVIDAD,SUPER_CONDICION_FISCAL
	FROM gd_esquema.Maestra m JOIN Pteradata.Direccion d ON m.SUPER_DOMICILIO = d.domicilio
							  JOIN Pteradata.Localidad l ON l.id_localidad = d.id_localidad AND l.localidad_nombre = m.SUPER_LOCALIDAD
							  JOIN Pteradata.Provincia p ON l.id_provincia = p.id_provincia AND p.provincia_nombre = m.SUPER_PROVINCIA
END

CREATE PROCEDURE migrarSucursal AS
BEGIN
	INSERT INTO Pteradata.Sucursal(nombre,id_direccion,cuit)
	SELECT DISTINCT SUCURSAL_NOMBRE, d.id_direccion, SUPER_CUIT
	FROM gd_esquema.Maestra m JOIN Pteradata.Direccion d ON m.SUCURSAL_DIRECCION = d.domicilio
							  JOIN Pteradata.Localidad l ON l.id_localidad = d.id_localidad AND l.localidad_nombre = m.SUCURSAL_LOCALIDAD
							  JOIN Pteradata.Provincia p ON l.id_provincia = p.id_provincia AND p.provincia_nombre = m.SUCURSAL_PROVINCIA
END

CREATE PROCEDURE migrarCajaTipo AS
BEGIN
	INSERT INTO Pteradata.CajaTipo(caja_tipo)
	SELECT DISTINCT CAJA_TIPO FROM gd_esquema.Maestra
	WHERE CAJA_TIPO IS NOT NULL
END

CREATE PROCEDURE migrarCajas AS
BEGIN
	INSERT INTO Pteradata.Caja(caja_num,sucursal_num,id_caja_tipo)
	SELECT DISTINCT m.CAJA_NUMERO, sc.sucursal_num, ct.id_caja_tipo
	FROM gd_esquema.Maestra m JOIN Pteradata.Sucursal sc ON m.SUCURSAL_NOMBRE = sc.nombre
							  JOIN Pteradata.CajaTipo ct ON m.CAJA_TIPO = ct.caja_tipo
							  WHERE m.CAJA_NUMERO IS NOT NULL
END

CREATE PROCEDURE migrarContactoEmpleado AS
BEGIN
	INSERT INTO Pteradata.ContactoEmpleado(email, telefono)
	SELECT DISTINCT EMPLEADO_MAIL, EMPLEADO_TELEFONO FROM gd_esquema.Maestra
	WHERE EMPLEADO_MAIL IS NOT NULL AND EMPLEADO_TELEFONO IS NOT NULL
END

CREATE PROCEDURE migrarEmpleados AS
BEGIN
	INSERT INTO Pteradata.Empleado(id_contacto, sucursal_num,dni,nombre,apellido,fecha_nacimiento,fecha_registro)
	SELECT DISTINCT ce.id_contacto, s.sucursal_num,EMPLEADO_DNI,EMPLEADO_NOMBRE,EMPLEADO_APELLIDO,EMPLEADO_FECHA_NACIMIENTO,EMPLEADO_FECHA_REGISTRO
	FROM gd_esquema.Maestra m JOIN Pteradata.ContactoEmpleado ce ON ce.email = m.EMPLEADO_MAIL AND ce.telefono = m.EMPLEADO_TELEFONO
							  JOIN Pteradata.Sucursal s ON m.SUCURSAL_NOMBRE = s.nombre
END


CREATE PROCEDURE migrarReglas AS
BEGIN
	INSERT INTO Pteradata.Reglas(regla_aplica_misma_marca,regla_aplica_mismo_prod,regla_cant_aplica_descuento,
	regla_cant_aplicable_regla,regla_cant_max_prod,regla_descripcion,regla_descuento_aplicable_prod)
	
	SELECT DISTINCT REGLA_APLICA_MISMA_MARCA, REGLA_APLICA_MISMO_PROD, REGLA_CANT_APLICA_DESCUENTO, 
	REGLA_CANT_APLICABLE_REGLA, REGLA_CANT_MAX_PROD, REGLA_DESCRIPCION, REGLA_DESCUENTO_APLICABLE_PROD 
	FROM gd_esquema.Maestra
	WHERE REGLA_DESCRIPCION IS NOT NULL
END

CREATE PROCEDURE migrarDescuentos AS
BEGIN
	INSERT INTO Pteradata.Descuento(descuento_codigo,descuento_descripcion, descuento_fecha_inicio, 
	descuento_fecha_fin, descuento_porcentaje_desc, descuento_tope)
	-- FALTA descuento_medio_pago nose de donde lo sacamos
	SELECT DISTINCT DESCUENTO_CODIGO,DESCUENTO_DESCRIPCION, DESCUENTO_FECHA_INICIO, DESCUENTO_FECHA_FIN,
	DESCUENTO_PORCENTAJE_DESC, DESCUENTO_TOPE FROM gd_esquema.Maestra
	WHERE DESCUENTO_CODIGO IS NOT NULL
END

CREATE PROCEDURE migrarEnvioEstado AS
BEGIN
	INSERT INTO Pteradata.EnvioEstado(estado)
	SELECT DISTINCT ENVIO_ESTADO FROM gd_esquema.Maestra
	WHERE ENVIO_ESTADO IS NOT NULL
END

CREATE PROCEDURE migrarTipoComprobante AS
BEGIN
	INSERT INTO Pteradata.TipoDeComprobante(tipo_comprobante)
	SELECT DISTINCT TICKET_TIPO_COMPROBANTE FROM gd_esquema.Maestra
END


CREATE PROCEDURE migrarMarcas AS
BEGIN
	INSERT INTO Pteradata.Marca(producto_marca)
	SELECT DISTINCT PRODUCTO_MARCA FROM gd_esquema.Maestra
	WHERE PRODUCTO_MARCA IS NOT NULL
END

CREATE PROCEDURE migrarCategorias AS
BEGIN
	INSERT INTO Pteradata.Categoria(producto_categoria)
	SELECT DISTINCT PRODUCTO_CATEGORIA FROM gd_esquema.Maestra
	WHERE PRODUCTO_CATEGORIA IS NOT NULL
END

CREATE PROCEDURE migrarSubCategorias AS
BEGIN 
	INSERT INTO Pteradata.SubCategoria(producto_sub_categoria, producto_categoria)
	SELECT DISTINCT PRODUCTO_SUB_CATEGORIA, PRODUCTO_CATEGORIA FROM gd_esquema.Maestra
	WHERE PRODUCTO_CATEGORIA IS NOT NULL AND PRODUCTO_SUB_CATEGORIA IS NOT NULL
END

CREATE PROCEDURE migrarProductos AS
BEGIN
	INSERT INTO Pteradata.Producto( producto_categoria, producto_nombre,id_marca,producto_descripcion, producto_precio)
	SELECT m.PRODUCTO_CATEGORIA, m.PRODUCTO_NOMBRE,  mc.id_marca, m.PRODUCTO_DESCRIPCION, m.PRODUCTO_PRECIO
	FROM gd_esquema.Maestra m JOIN Pteradata.Marca mc ON m.PRODUCTO_MARCA = mc.producto_marca
							  JOIN Pteradata.Categoria c ON m.PRODUCTO_CATEGORIA = c.producto_categoria
							  JOIN Pteradata.SubCategoria sc ON m.PRODUCTO_SUB_CATEGORIA = sc.producto_sub_categoria AND c.producto_categoria = sc.producto_categoria
END


CREATE PROCEDURE migrarTarjetas AS
BEGIN
	INSERT INTO Pteradata.Tarjeta(nro_tarjeta, tarjeta_fecha_vencimiento)
	SELECT DISTINCT PAGO_TARJETA_NRO, PAGO_TARJETA_FECHA_VENC FROM gd_esquema.Maestra
	WHERE PAGO_TARJETA_NRO IS NOT NULL AND PAGO_TARJETA_FECHA_VENC IS NOT NULL
END

CREATE PROCEDURE migrarPagoMedioTipoPago AS
BEGIN 
	INSERT INTO Pteradata.TipoPagoMedioPago(pago_tipo_medio_pago)
	SELECT DISTINCT
		CASE 
			WHEN PAGO_TIPO_MEDIO_PAGO = 'Ejectivo' THEN 'Efectivo'
			WHEN PAGO_TIPO_MEDIO_PAGO = 'Tarjeta Crèdito' THEN 'Tarjeta Crédito'
			ELSE PAGO_TIPO_MEDIO_PAGO 
		END AS tipoPagoMedioPago
			FROM gd_esquema.Maestra
			WHERE PAGO_TIPO_MEDIO_PAGO is not null
END


CREATE PROCEDURE migrarMedioPago AS
BEGIN
	INSERT INTO Pteradata.MedioPago(pago_medio_pago, id_pago_tipo_medio_pago)
	SELECT DISTINCT g.PAGO_MEDIO_PAGO, t.id_pago_tipo_medio_pago FROM gd_esquema.Maestra g
	JOIN Pteradata.TipoPagoMedioPago t ON g.PAGO_TIPO_MEDIO_PAGO = t.pago_tipo_medio_pago
END


CREATE PROCEDURE migrarPago AS
BEGIN
	INSERT INTO Pteradata.Pago(pago_fecha,pago_importe, id_medio_pago)
	SELECT PAGO_FECHA, PAGO_IMPORTE, m.id_medio_pago FROM gd_esquema.Maestra g
	JOIN Pteradata.MedioPago m ON m.pago_medio_pago = g.PAGO_MEDIO_PAGO
	JOIN Pteradata.TipoPagoMedioPago t ON (t.id_pago_tipo_medio_pago = m.id_pago_tipo_medio_pago
	AND g.PAGO_TIPO_MEDIO_PAGO = t.pago_tipo_medio_pago)
END

CREATE PROCEDURE migrarDetallePago AS
BEGIN 
	INSERT INTO Pteradata.DetallePago(nro_tarjeta, nro_pago, cant_cuotas)
	SELECT t.nro_tarjeta, nro_pago, PAGO_TARJETA_CUOTAS FROM gd_esquema.Maestra m
	JOIN Pteradata.Tarjeta t ON m.PAGO_TARJETA_NRO = t.nro_tarjeta
	JOIN Pteradata.Pago p ON p.
END


CREATE PROCEDURE migrarPromocion AS
BEGIN
	INSERT INTO Pteradata.Promocion(id_relgas, promocion_fecha_inicio, promocion_fecha_fin, promo_aplicada_descuento, promocion_descripcion)
	SELECT DISTINCT r.id_reglas, PROMOCION_FECHA_INICIO, PROMOCION_FECHA_FIN, PROMO_APLICADA_DESCUENTO, PROMOCION_DESCRIPCION FROM gd_esquema.Maestra g
	JOIN Pteradata.Reglas r ON r.regla_descripcion = g.REGLA_DESCRIPCION
END

CREATE PROCEDURE migrarPromocionPorProducto AS
BEGIN
	INSERT INTO Pteradata.PromocionPorProducto(promo_codigo, producto_codigo)
	SELECT g.PROMO_CODIGO, p.producto_codigo FROM gd_esquema.Maestra g
	JOIN Pteradata.Producto p ON p.producto_descripcion = g.PRODUCTO_DESCRIPCION
END




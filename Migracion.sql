
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
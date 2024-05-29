
DECLARE @SchemaName NVARCHAR(128) = 'Pteradata';  -- Reemplaza 'TuEsquema' con el nombre de tu esquema
DECLARE @Sql NVARCHAR(MAX) = '';
DECLARE @TableName NVARCHAR(128);

-- Obtener la lista de tablas en el esquema especificado
DECLARE TableCursor CURSOR FOR
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = @SchemaName AND TABLE_TYPE = 'BASE TABLE';

OPEN TableCursor;

FETCH NEXT FROM TableCursor INTO @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Construir la instrucción TRUNCATE TABLE o DELETE FROM para cada tabla
    SET @Sql += 'DELETE FROM ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ';' + CHAR(13);

    FETCH NEXT FROM TableCursor INTO @TableName;
END;

CLOSE TableCursor;
DEALLOCATE TableCursor;

-- Ejecutar las instrucciones generadas
EXEC sp_executesql @Sql;
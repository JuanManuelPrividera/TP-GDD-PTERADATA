DECLARE @SchemaName NVARCHAR(128) = 'Pteradata'; -- Especifica el nombre del esquema
DECLARE @sql NVARCHAR(MAX) = N'';

-- Generar las sentencias DROP TABLE
SELECT @sql += N'DROP TABLE ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(t.name) + N';' + CHAR(13)
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = @SchemaName;

-- Ejecutar las sentencias DROP TABLE
EXEC sp_executesql @sql;



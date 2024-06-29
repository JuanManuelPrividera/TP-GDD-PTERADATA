DECLARE @SchemaName NVARCHAR(128) = 'dbo'; -- Reemplaza con el nombre de tu esquema
DECLARE @ViewName NVARCHAR(128);
DECLARE @Sql NVARCHAR(MAX);

DECLARE view_cursor CURSOR FOR
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = @SchemaName;

OPEN view_cursor;

FETCH NEXT FROM view_cursor INTO @ViewName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Sql = 'DROP VIEW ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ViewName);
    EXEC sp_executesql @Sql;

    FETCH NEXT FROM view_cursor INTO @ViewName;
END

CLOSE view_cursor;
DEALLOCATE view_cursor;
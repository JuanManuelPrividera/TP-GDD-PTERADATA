DECLARE @procName NVARCHAR(128)
DECLARE @sql NVARCHAR(MAX)

-- Cursor para recorrer todos los procedimientos almacenados en la base de datos
DECLARE proc_cursor CURSOR FOR
SELECT name 
FROM sys.procedures

OPEN proc_cursor

-- Obtener el primer procedimiento almacenado
FETCH NEXT FROM proc_cursor INTO @procName

-- Bucle para recorrer todos los procedimientos almacenados
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Generar la sentencia DROP PROCEDURE
    SET @sql = 'DROP PROCEDURE ' + QUOTENAME(@procName)
    
    -- Ejecutar la sentencia DROP PROCEDURE
    EXEC sp_executesql @sql
    
    -- Obtener el siguiente procedimiento almacenado
    FETCH NEXT FROM proc_cursor INTO @procName
END

-- Cerrar y liberar el cursor
CLOSE proc_cursor
DEALLOCATE proc_cursor
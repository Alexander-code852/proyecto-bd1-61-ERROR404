USE color_y_pincel;
GO

CREATE OR ALTER PROCEDURE dbo.sp_InsertarProducto
    @nombre VARCHAR(100),
    @tipo VARCHAR(50),
    @precio_venta DECIMAL(10,2),
    @stock_actual INT,
    @stock_minimo INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones previas de integridad
    IF @precio_venta <= 0
    BEGIN
        RAISERROR('El precio de venta debe ser mayor a cero.', 16, 1);
        RETURN;
    END;

    IF @stock_actual < 0 OR @stock_minimo < 0
    BEGIN
        RAISERROR('El stock no puede ser un valor negativo.', 16, 1);
        RETURN;
    END;

    -- Inserción en la tabla maestra de productos
    INSERT INTO productos (nombre, tipo, precio_venta, stock_actual, stock_minimo)
    VALUES (@nombre, @tipo, @precio_venta, @stock_actual, @stock_minimo);

    PRINT 'Producto registrado exitosamente.';
END;
GO
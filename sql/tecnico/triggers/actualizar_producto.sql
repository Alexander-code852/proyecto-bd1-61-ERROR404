USE color_y_pincel;
GO

CREATE OR ALTER PROCEDURE dbo.sp_ModificarProducto
    @id_producto INT,
    @nuevo_precio DECIMAL(10,2),
    @nuevo_stock INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM productos WHERE id_producto = @id_producto)
    BEGIN
        RAISERROR('El producto especificado no existe.', 16, 1);
        RETURN;
    END;

    IF @nuevo_precio <= 0
    BEGIN
        RAISERROR('El precio asignado debe ser mayor a cero.', 16, 1);
        RETURN;
    END;

    UPDATE productos
    SET precio_venta = @nuevo_precio,
        stock_actual = @nuevo_stock
    WHERE id_producto = @id_producto;

    PRINT 'Producto actualizado correctamente.';
END;
GO

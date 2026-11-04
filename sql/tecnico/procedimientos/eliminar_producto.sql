USE color_y_pincel;
GO

CREATE OR ALTER PROCEDURE dbo.sp_EliminarProducto
    @id_producto INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Comprobar si el producto ya forma parte de algún detalle de venta
    IF EXISTS (SELECT 1 FROM detalles_venta WHERE id_producto = @id_producto)
    BEGIN
        RAISERROR('No se puede eliminar el producto porque posee ventas registradas.', 16, 1);
        RETURN;
    END;

    DELETE FROM productos WHERE id_producto = @id_producto;
    PRINT 'Producto eliminado del catálogo.';
END;
GO
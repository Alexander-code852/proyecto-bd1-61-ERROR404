USE color_y_pincel;
GO

CREATE OR ALTER FUNCTION dbo.fn_ObtenerTotalComprasCliente (@id_cliente INT)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @total DECIMAL(12,2);

    SELECT @total = SUM(dv.cantidad * dv.precio_unitario_historico)
    FROM ventas v
    INNER JOIN detalles_venta dv ON v.id_venta = dv.id_venta
    WHERE v.id_cliente = @id_cliente
      AND v.estado = 'CONFIRMADA';

    RETURN ISNULL(@total, 0.00);
END;
GO

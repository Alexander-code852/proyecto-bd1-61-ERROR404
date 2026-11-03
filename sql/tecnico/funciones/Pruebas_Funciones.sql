USE color_y_pincel;
GO

-- Probar el descuento y el total acumulado por cada cliente
SELECT 
    p.id_persona AS id_cliente,
    CONCAT(p.apellido, N', ', p.nombre) AS cliente,
    dbo.fn_ObtenerTotalComprasCliente(p.id_persona) AS total_compras,
    dbo.fn_CalcularDescuentoCliente(p.id_persona) AS porcentaje_descuento
FROM personas p
WHERE p.tipo_persona = 'CLIENTE';
GO

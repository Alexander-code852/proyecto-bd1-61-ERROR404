USE color_y_pincel;
GO

-- PRUEBA 1: Registro de venta exitoso (Asegúrate de que existan IDs válidos en tu base)
PRINT '--- Ejecutando Prueba 1: Venta Exitosa ---';
EXEC dbo.sp_RegistrarVentaConControlStock
    @numero_comprobante = 'FAC-0001',
    @id_cliente = 1,
    @id_vendedor = 1,
    @id_sesion = 1,
    @id_producto = 1,
    @cantidad_comprada = 2;
GO

-- PRUEBA 2: Intento de venta con stock insuficiente (Debe disparar el ROLLBACK)
PRINT '--- Ejecutando Prueba 2: Venta Fallida por Stock Insuficiente ---';
EXEC dbo.sp_RegistrarVentaConControlStock
    @numero_comprobante = 'FAC-0002',
    @id_cliente = 1,
    @id_vendedor = 1,
    @id_sesion = 1,
    @id_producto = 1,
    @cantidad_comprada = 9999; -- Cantidad superior al stock disponible
GO
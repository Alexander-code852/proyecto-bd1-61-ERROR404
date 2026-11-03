USE color_y_pincel;
GO

CREATE OR ALTER PROCEDURE dbo.sp_RegistrarVentaConControlStock
    @numero_comprobante VARCHAR(20),
    @id_cliente INT,
    @id_vendedor INT,
    @id_sesion INT,
    @id_producto INT,
    @cantidad_comprada INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        -- 1. Validar stock actual
        DECLARE @stock_disponible INT;
        DECLARE @precio_actual DECIMAL(10,2);

        SELECT @stock_disponible = stock_actual, @precio_actual = precio_venta
        FROM productos
        WHERE id_producto = @id_producto;

        IF @stock_disponible IS NULL OR @stock_disponible < @cantidad_comprada
        BEGIN
            RAISERROR('Stock insuficiente para completar la operación.', 16, 1);
        END

        -- 2. Registrar Cabecera de Venta
        INSERT INTO ventas (numero_comprobante, fecha_hora, estado, id_cliente, id_vendedor, id_sesion)
        VALUES (@numero_comprobante, GETDATE(), 'CONFIRMADA', @id_cliente, @id_vendedor, @id_sesion);

        DECLARE @id_nueva_venta INT = SCOPE_IDENTITY();

        -- 3. Registrar Detalle de Venta (Precio histórico)
        INSERT INTO detalles_venta (id_venta, id_producto, cantidad, precio_unitario_historico)
        VALUES (@id_nueva_venta, @id_producto, @cantidad_comprada, @precio_actual);

        -- 4. Actualizar Stock del Producto (RN02: nunca negativo)
        UPDATE productos
        SET stock_actual = stock_actual - @cantidad_comprada
        WHERE id_producto = @id_producto;

        COMMIT TRANSACTION;
        PRINT 'Venta registrada y stock actualizado con éxito.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        PRINT 'Error en la transacción. Se aplicó ROLLBACK completo.';
        THROW;
    END CATCH;
END;
GO
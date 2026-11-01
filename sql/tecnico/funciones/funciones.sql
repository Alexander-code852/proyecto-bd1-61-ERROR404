USE color_y_pincel;
GO

-- ---------------------------------------------------------------------
-- A. FUNCIÓN: Calcular Descuento por Fidelización de Cliente
-- ---------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_CalcularDescuentoCliente (@id_cliente INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @total_acumulado DECIMAL(12,2);

    -- Sumar el total de ventas confirmadas del cliente
    SELECT @total_acumulado = SUM(dv.cantidad * dv.precio_unitario_historico)
    FROM ventas v
    INNER JOIN detalles_venta dv ON v.id_venta = dv.id_venta
    WHERE v.id_cliente = @id_cliente
      AND v.estado = 'CONFIRMADA';

    SET @total_acumulado = ISNULL(@total_acumulado, 0);

    -- Aplicar reglas de negocio según monto acumulado
    IF @total_acumulado > 150000.00
        RETURN 10.00; -- 10% de descuento
    ELSE IF @total_acumulado > 50000.00
        RETURN 5.00;  -- 5% de descuento

    RETURN 0.00;
END;
GO

-- Prueba de uso de la función en el catálogo de clientes:
SELECT 
    p.id_persona AS id_cliente,
    CONCAT(p.apellido, N', ', p.nombre) AS cliente,
    dbo.fn_CalcularDescuentoCliente(p.id_persona) AS porcentaje_descuento
FROM personas p
WHERE p.tipo_persona = 'CLIENTE';
GO

-- ---------------------------------------------------------------------
-- B. PROCEDIMIENTO: Registrar Cabecera de Venta Básica
-- ---------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_RegistrarVentaSimple
    @numero_comprobante VARCHAR(20),
    @id_cliente INT,
    @id_vendedor INT,
    @id_sesion INT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO ventas (numero_comprobante, fecha_hora, estado, id_cliente, id_vendedor, id_sesion)
    VALUES (@numero_comprobante, GETDATE(), 'CONFIRMADA', @id_cliente, @id_vendedor, @id_sesion);
    
    SELECT SCOPE_IDENTITY() AS id_venta_generada;
END;
GO


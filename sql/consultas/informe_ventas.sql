-- =====================================================================
--  PROYECTO INTEGRADOR - BASES DE DATOS I
--  Equipo ERROR 404 - Librería "Color & Pincel"
--  Consultas de Resumen General: Ventas por Vendedor y por Categoría/Producto
-- =====================================================================

USE color_y_pincel;
GO

-- Definición del rango de fechas compartido para ambos reportes
DECLARE @FechaInicio DATETIME = '2026-09-01 00:00:00';
DECLARE @FechaFin    DATETIME = '2026-09-30 23:59:59';

-- ---------------------------------------------------------------------
--  1. REPORTE: TOTAL ACUMULADO DE VENTAS POR VENDEDOR
-- ---------------------------------------------------------------------
PRINT '=============================================================';
PRINT 'REPORTE 1: TOTAL ACUMULADO DE VENTAS POR VENDEDOR';
PRINT '=============================================================';

WITH VentasCalculadas AS (
    SELECT 
        v.id_venta,
        v.id_vendedor,
        SUM(dv.cantidad * dv.precio_unitario_historico) AS total_venta
    FROM ventas v
    INNER JOIN detalles_venta dv ON v.id_venta = dv.id_venta
    WHERE v.estado = 'CONFIRMADA'
      AND v.fecha_hora BETWEEN @FechaInicio AND @FechaFin
    GROUP BY v.id_venta, v.id_vendedor
)
SELECT 
    p.id_persona AS id_vendedor,
    CONCAT(p.nombre, ' ', p.apellido) AS vendedor,
    COUNT(vc.id_venta) AS cantidad_comprobantes,
    SUM(vc.total_venta) AS total_acumulado_ventas,
    AVG(vc.total_venta) AS promedio_venta_por_comprobante
FROM VentasCalculadas vc
INNER JOIN personas p ON vc.id_vendedor = p.id_persona
GROUP BY p.id_persona, p.nombre, p.apellido
ORDER BY total_acumulado_ventas DESC;

PRINT '';
GO

-- ---------------------------------------------------------------------
--  2. REPORTE: TOTAL ACUMULADO DE VENTAS POR CATEGORÍA Y PRODUCTO
-- ---------------------------------------------------------------------
PRINT '=============================================================';
PRINT 'REPORTE 2: TOTAL ACUMULADO DE VENTAS POR CATEGORÍA Y PRODUCTO';
PRINT '=============================================================';

SELECT 
    pr.tipo AS categoria_producto,
    pr.id_producto,
    pr.nombre AS producto,
    SUM(dv.cantidad) AS unidades_vendidas,
    COUNT(DISTINCT dv.id_venta) AS cantidad_transacciones,
    SUM(dv.cantidad * dv.precio_unitario_historico) AS total_acumulado_ventas,
    AVG(dv.precio_unitario_historico) AS precio_promedio_historico
FROM ventas v
INNER JOIN detalles_venta dv ON v.id_venta = dv.id_venta
INNER JOIN productos pr ON dv.id_producto = pr.id_producto
WHERE v.estado = 'CONFIRMADA'
  AND v.fecha_hora BETWEEN @FechaInicio AND @FechaFin
GROUP BY pr.tipo, pr.id_producto, pr.nombre
ORDER BY pr.tipo ASC, total_acumulado_ventas DESC;
GO

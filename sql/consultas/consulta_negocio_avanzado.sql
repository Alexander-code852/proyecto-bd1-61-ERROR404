-- =====================================================================
-- PROYECTO INTEGRADOR - BASES DE DATOS I
-- Equipo ERROR 404 - Libreria "Color & Pincel"
-- Archivo: sql/consultas/negocio_avanzado.sql
-- Objetivo: Identificar clientes cuyo total acumulado en compras
-- (ventas CONFIRMADAS) supere el promedio general facturado
--  por cliente.
-- Nota: el promedio general considera solo a los clientes con al menos
-- una venta confirmada.
-- =====================================================================

USE color_y_pincel;
GO

SELECT
    c.id_persona                                    AS id_cliente,
    c.dni_cuit,
    CONCAT(c.apellido, N', ', c.nombre)             AS cliente,
    COUNT(DISTINCT v.id_venta)                      AS cantidad_ventas,
    COUNT(DISTINCT p.id_producto)                   AS productos_distintos,
    SUM(dv.cantidad * dv.precio_unitario_historico) AS total_facturado,
    SUM(dv.cantidad * dv.precio_unitario_historico)
        / COUNT(DISTINCT v.id_venta)                AS ticket_promedio
FROM personas c
    INNER JOIN ventas v
        ON c.id_persona = v.id_cliente
    INNER JOIN detalles_venta dv
        ON v.id_venta = dv.id_venta
    INNER JOIN productos p
        ON dv.id_producto = p.id_producto
WHERE
    v.estado = 'CONFIRMADA'          -- descarta ANULADAS/PENDIENTES antes de agrupar
    AND c.tipo_persona = 'CLIENTE'
GROUP BY
    c.id_persona,
    c.dni_cuit,
    c.apellido,
    c.nombre
HAVING
    SUM(dv.cantidad * dv.precio_unitario_historico) > (
        -- Subconsulta: promedio de facturacion acumulada por cliente
        SELECT AVG(sub.total_cliente)
        FROM (
            SELECT
                v2.id_cliente,
                SUM(dv2.cantidad * dv2.precio_unitario_historico) AS total_cliente
            FROM ventas v2
                INNER JOIN detalles_venta dv2
                    ON v2.id_venta = dv2.id_venta
            WHERE
                v2.estado = 'CONFIRMADA'
            GROUP BY
                v2.id_cliente
        ) AS sub
    )
ORDER BY
    total_facturado DESC;
GO

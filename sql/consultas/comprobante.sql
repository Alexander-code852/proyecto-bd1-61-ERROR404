-- =====================================================================
--  PROYECTO INTEGRADOR - BASES DE DATOS I
--  Equipo ERROR 404 - Librería "Color & Pincel"
--  ETAPA IV: Consultas y Casos de Uso (SQL)
--  Consulta 1: Comprobante de Venta y Facturación Detallada
--  Autor: Gustavo Gabriel Gabutti (DNI: 46064849)
--  Archivo: sql/consultas/comprobante.sql
-- =====================================================================

USE sistema_ventas_inventario;

SELECT 
    v.numero_comprobante AS "Nro Comprobante",
    v.fecha_hora AS "Fecha Hora Emisión",
    CONCAT(c.nombre, ' ', c.apellido) AS "Cliente",
    c.email AS "Email Cliente",
    CONCAT(vend.nombre, ' ', vend.apellido) AS "Vendedor Atendió",
    p.nombre AS "Producto / Servicio",
    p.marca AS "Marca",
    dv.cantidad AS "Cantidad",
    dv.precio_unitario_historico AS "Precio Unit. Histórico",
    (dv.cantidad * dv.precio_unitario_historico) AS "Subtotal Renglón",
    
    -- Total general calculado mediante subconsulta sobre la cabecera
    (SELECT SUM(dvsub.cantidad * dvsub.precio_unitario_historico)
     FROM detalles_venta dvsub
     WHERE dvsub.id_venta = v.id_venta) AS "Total General Comprobante"

FROM ventas v
INNER JOIN personas c ON v.id_cliente = c.id_persona
INNER JOIN personas vend ON v.id_vendedor = vend.id_persona
INNER JOIN detalles_venta dv ON v.id_venta = dv.id_venta
INNER JOIN productos p ON dv.id_producto = p.id_producto
WHERE v.id_venta = 1
ORDER BY p.nombre;

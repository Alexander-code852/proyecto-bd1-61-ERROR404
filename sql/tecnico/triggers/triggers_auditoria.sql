USE color_y_pincel;
GO

-- ============================================================================
-- ETAPA V - TEMA 3: TRIGGERS DE AUDITORÍA Y TRAZABILIDAD HISTÓRICA
-- Integrante: Gustavo Gabtti (DNI: 46064849) - Grupo 61 (ERROR404)
-- ============================================================================

-- 1. Asegurar la existencia de la tabla de auditoría de precios
IF NOT OBJECT_ID('auditoria_precios_productos', 'U') IS NOT NULL
BEGIN
    CREATE TABLE auditoria_precios_productos (
        id_auditoria       INT IDENTITY(1,1) PRIMARY KEY,
        id_producto        INT NOT NULL,
        precio_anterior    DECIMAL(10,2) NOT NULL,
        precio_nuevo       DECIMAL(10,2) NOT NULL,
        fecha_modificacion DATETIME NOT NULL DEFAULT GETDATE(),
        usuario            SYSNAME NOT NULL,
        CONSTRAINT FK_auditoria_producto FOREIGN KEY (id_producto) 
            REFERENCES productos(id_producto) ON DELETE CASCADE
    );
END;
GO

-- 2. Creación del Trigger DML sobre actualizaciones de precio en tabla productos
CREATE OR ALTER TRIGGER tr_auditoria_precio_producto
ON productos
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si se modificó la columna precio_venta
    IF UPDATE(precio_venta)
    BEGIN
        INSERT INTO auditoria_precios_productos (
            id_producto, 
            precio_anterior, 
            precio_nuevo, 
            usuario
        )
        SELECT 
            i.id_producto,
            d.precio_venta AS precio_anterior,
            i.precio_venta AS precio_nuevo,
            SYSTEM_USER    AS usuario
        FROM inserted i
        INNER JOIN deleted d ON i.id_producto = d.id_producto
        WHERE i.precio_venta <> d.precio_venta;
    END;
END;
GO

-- ============================================================================
-- PRUEBAS DE DEMOSTRACIÓN Y VERIFICACIÓN
-- ============================================================================

-- Prueba 1: Modificar el precio del producto ID = 1 para disparar la auditoría
UPDATE productos 
SET precio_venta = 3800.00 
WHERE id_producto = 1;
GO

-- Prueba 2: Consultar los registros capturados automáticamente por el Trigger
SELECT 
    id_auditoria,
    id_producto,
    precio_anterior,
    precio_nuevo,
    fecha_modificacion,
    usuario
FROM auditoria_precios_productos;
GO

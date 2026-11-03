USE color_y_pincel;
GO

-- 1. Crear tabla de simulación histórica
CREATE TABLE VentaHistoricaPrueba (
    id_venta BIGINT IDENTITY(1,1),
    fecha_venta DATE NOT NULL,
    importe DECIMAL(12,2) NOT NULL
);
GO

-- 2. Carga masiva de prueba (simulando rendimiento con gran volumen)
SET NOCOUNT ON;
WITH Numeros AS (
    SELECT TOP (500000) ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n
    FROM sys.objects a CROSS JOIN sys.objects b
)
INSERT INTO VentaHistoricaPrueba (fecha_venta, importe)
SELECT 
    DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 1000, '2024-01-01'),
    RAND(CHECKSUM(NEWID())) * 15000
FROM Numeros;
GO

-- 3. Activar estadísticas de rendimiento para la prueba
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

-- Consulta analítica de prueba sin índices específicos adicionales:
SELECT id_venta, fecha_venta, importe
FROM VentaHistoricaPrueba
WHERE fecha_venta BETWEEN '2025-01-01' AND '2025-03-31';
GO

-- 4. Creación de Índice Nonclustered con Cobertura para optimizar la consulta
CREATE NONCLUSTERED INDEX IX_VentaHistorica_Fecha_Cobertura
ON VentaHistoricaPrueba (fecha_venta)
INCLUDE (importe);
GO

-- Al reejecutar la consulta, el plan de ejecución cambiará de 'Table Scan' a 'Index Seek',
-- reduciendo notablemente las lecturas lógicas y el tiempo de CPU requerido[cite: 22, 23].


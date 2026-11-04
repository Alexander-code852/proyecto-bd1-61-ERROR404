USE color_y_pincel;
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

-- Prueba de ejecución masiva mediante procedimiento
EXEC dbo.sp_InsertarProducto 'Pincel Sintético Nº 4', 'Libreria', 850.00, 50, 10;
EXEC dbo.sp_InsertarProducto 'Pincel Sintético Nº 8', 'Libreria', 1100.00, 40, 10;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO
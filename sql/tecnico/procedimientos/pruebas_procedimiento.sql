USE color_y_pincel;
GO

-- 1. Insertar un producto de prueba
EXEC dbo.sp_InsertarProducto 
    @nombre = 'Acuarelas Profesionales 24 Colores', 
    @tipo = 'Libreria', 
    @precio_venta = 12500.00, 
    @stock_actual = 15, 
    @stock_minimo = 3;

-- 2. Modificar el producto recién creado
EXEC dbo.sp_ModificarProducto 
    @id_producto = 1, 
    @nuevo_precio = 13200.00, 
    @nuevo_stock = 20;

-- 3. Consultar la tabla para verificar los cambios
SELECT * FROM productos WHERE id_producto = 1;
GO
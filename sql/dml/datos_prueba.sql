-- =====================================================================
--  PROYECTO INTEGRADOR - BASES DE DATOS I
--  Equipo ERROR 404 - Librería "Color & Pincel"
--  ETAPA III: Implementación Física
--  Script 2/2: DML (Data Manipulation Language) - Poblado inicial
--  Ejecutar DESPUÉS de crear_bd.sql (SQL Server / T-SQL)
-- =====================================================================

USE color_y_pincel;
GO
SET DATEFORMAT ymd;
GO

-- ---------------------------------------------------------------------
--  PERSONAS (10): 4 clientes, 3 empleados, 3 proveedores
-- ---------------------------------------------------------------------
SET IDENTITY_INSERT personas ON;
INSERT INTO personas (id_persona, nombre, apellido, dni_cuit, telefono, email, tipo_persona) VALUES
(1,  N'Martín',    N'Gómez',                 N'30111222',      N'3624-501122', N'martin.gomez@mail.com',       N'CLIENTE'),
(2,  N'Lucía',     N'Fernández',             N'32555666',      N'3624-502233', N'lucia.fernandez@mail.com',    N'CLIENTE'),
(3,  N'Instituto', N'San Martín S.R.L.',     N'30-71234567-8', N'3624-443300', N'compras@institutosanmartin.edu.ar', N'CLIENTE'),
(4,  N'Valeria',   N'Romero',                N'35888999',      N'3624-504455', N'valeria.romero@mail.com',     N'CLIENTE'),
(5,  N'Carolina',  N'Benítez',               N'28444555',      N'3624-505566', N'carolina.benitez@colorypincel.com', N'EMPLEADO'),
(6,  N'Diego',     N'Ruiz',                  N'36777888',      N'3624-506677', N'diego.ruiz@colorypincel.com', N'EMPLEADO'),
(7,  N'Sofía',     N'Acosta',                N'40222333',      N'3624-507788', N'sofia.acosta@colorypincel.com', N'EMPLEADO'),
(8,  N'Distribuidora', N'Papelera del Nordeste S.A.', N'30-70111222-3', N'0379-4421100', N'ventas@papeleranordeste.com.ar', N'PROVEEDOR'),
(9,  N'Editorial',  N'Kapelusz Distribuciones S.A.', N'30-69888777-1', N'011-43217700', N'pedidos@kapelusz-dist.com.ar', N'PROVEEDOR'),
(10, N'Insumos',    N'Gráficos Chaco S.R.L.', N'30-71555444-9', N'3624-455900', N'info@insumoschaco.com.ar',   N'PROVEEDOR');
SET IDENTITY_INSERT personas OFF;
GO

-- ---------------------------------------------------------------------
--  PRODUCTOS (10): 7 artículos + 3 servicios (sin stock ni código de barras)
-- ---------------------------------------------------------------------
SET IDENTITY_INSERT productos ON;
INSERT INTO productos (id_producto, codigo_barras, nombre, tipo, marca, precio_venta, stock_actual, stock_minimo) VALUES
(1,  N'7790001000011', N'Cuaderno espiralado 48 hojas rayado', N'LIBRERIA', N'Rivadavia',  3500.00,  75, 15),
(2,  N'7790002000028', N'Resma papel A4 75g x 500 hojas',      N'PAPELERIA',N'Report',      9800.00,  55, 10),
(3,  N'7790003000035', N'Lapicera azul trazo medio',           N'LIBRERIA', N'BIC',          500.00, 385, 50),
(4,  N'7790004000042', N'Set de 12 marcadores punta fina',     N'LIBRERIA', N'Filgo',       6200.00,  42,  8),
(5,  N'7790005000059', N'Mochila escolar 18 pulgadas',         N'LIBRERIA', N'Footy',      42000.00,  23,  3),
(6,  N'9789501000066', N'Manual de Matemática 3 - Secundaria', N'LIBRO',    N'Kapelusz',   18500.00,  28,  5),
(7,  N'7790007000073', N'Cartucho de tinta negra 664',         N'INSUMO',   N'Epson',      11500.00,  18,  5),
(8,  NULL,            N'Fotocopia A4 blanco y negro',         N'SERVICIO', NULL,            60.00,   0,  0),
(9,  NULL,            N'Impresión A4 color',                  N'SERVICIO', NULL,           250.00,   0,  0),
(10, NULL,            N'Anillado hasta 100 hojas',            N'SERVICIO', NULL,          2500.00,   0,  0);
SET IDENTITY_INSERT productos OFF;
GO

-- ---------------------------------------------------------------------
--  CAJAS (8)
-- ---------------------------------------------------------------------
SET IDENTITY_INSERT cajas ON;
INSERT INTO cajas (id_caja, numero_caja, estado) VALUES
(1, 1, N'ABIERTA'),
(2, 2, N'CERRADA'),
(3, 3, N'CERRADA'),
(4, 4, N'CERRADA'),
(5, 5, N'CERRADA'),
(6, 6, N'CERRADA'),
(7, 7, N'MANTENIMIENTO'),
(8, 8, N'INACTIVA');
SET IDENTITY_INSERT cajas OFF;
GO

-- ---------------------------------------------------------------------
--  SESIONES_CAJA (10): 9 cerradas + 1 abierta (id 10, sin cierre)
--  monto_final = monto_inicial + efectivo cobrado en la sesión (arqueo)
-- ---------------------------------------------------------------------
SET IDENTITY_INSERT sesiones_caja ON;
INSERT INTO sesiones_caja
    (id_sesion, fecha_hora_apertura, fecha_hora_cierre, monto_inicial_efectivo, monto_final_efectivo, id_empleado_cajero, id_caja) VALUES
(1,  '20260921 08:00:00', '20260921 14:00:00', 20000.00, 34100.00, 6, 1),
(2,  '20260921 15:00:00', '20260921 21:00:00', 15000.00, 25000.00, 7, 1),
(3,  '20260922 08:00:00', '20260922 14:00:00', 20000.00, 20000.00, 6, 2),
(4,  '20260922 15:00:00', '20260922 21:00:00', 20000.00, 20000.00, 7, 2),
(5,  '20260923 08:00:00', '20260923 14:00:00', 10000.00, 16900.00, 6, 1),
(6,  '20260923 08:30:00', '20260923 14:30:00', 10000.00, 10000.00, 5, 3),
(7,  '20260924 08:00:00', '20260924 14:00:00', 20000.00, 20000.00, 7, 2),
(8,  '20260925 15:00:00', '20260925 21:00:00', 15000.00, 30300.00, 6, 1),
(9,  '20260928 08:00:00', '20260928 14:00:00', 10000.00, 10000.00, 5, 3),
(10, '20260930 08:30:00', NULL,                  15000.00, NULL,     7, 1);
SET IDENTITY_INSERT sesiones_caja OFF;
GO

-- ---------------------------------------------------------------------
--  COMPRAS (10) a proveedores (ids 8, 9, 10)
-- ---------------------------------------------------------------------
SET IDENTITY_INSERT compras ON;
INSERT INTO compras (id_compra, numero_factura_proveedor, fecha_hora, id_proveedor) VALUES
(1,  N'A-0004-00001201', '20260901 10:00:00', 8),
(2,  N'A-0012-00000587', '20260902 11:30:00', 9),
(3,  N'A-0007-00003345', '20260903 09:45:00', 10),
(4,  N'A-0004-00001260', '20260908 10:15:00', 8),
(5,  N'A-0012-00000602', '20260909 12:00:00', 9),
(6,  N'A-0004-00001311', '20260914 09:30:00', 8),
(7,  N'A-0007-00003410', '20260915 10:45:00', 10),
(8,  N'A-0004-00001355', '20260917 11:00:00', 8),
(9,  N'A-0012-00000640', '20260918 10:20:00', 9),
(10, N'A-0007-00003498', '20260922 09:15:00', 10);
SET IDENTITY_INSERT compras OFF;
GO

-- ---------------------------------------------------------------------
--  DETALLES_COMPRA (16): costos históricos (varían entre compras)
-- ---------------------------------------------------------------------
INSERT INTO detalles_compra (id_compra, id_producto, cantidad, costo_unitario_historico) VALUES
(1,  1, 50,  2500.00),
(1,  2, 40,  7800.00),
(2,  6, 25, 14000.00),
(3,  7, 20,  9000.00),
(3,  4, 30,  4500.00),
(4,  3, 300,  300.00),
(4,  5, 12, 32000.00),
(5,  6, 10, 14500.00),
(6,  1, 30,  2700.00),
(6,  3, 100,  320.00),
(7,  7, 10,  9600.00),
(8,  2, 30,  8200.00),
(8,  4, 15,  4800.00),
(9,  6, 12, 15500.00),
(10, 7,  8, 10000.00),
(10, 5, 10, 34500.00);
GO

-- ---------------------------------------------------------------------
--  VENTAS (10): 9 confirmadas + 1 anulada (id 9)
--  id_cajero de la sesión = quien abre la caja; id_vendedor = quien vende
-- ---------------------------------------------------------------------
SET IDENTITY_INSERT ventas ON;
INSERT INTO ventas (id_venta, numero_comprobante, fecha_hora, estado, id_cliente, id_vendedor, id_sesion) VALUES
(1,  N'0001-00000001', '20260921 09:15:00', N'CONFIRMADA', 1, 6, 1),
(2,  N'0001-00000002', '20260921 16:30:00', N'CONFIRMADA', 2, 7, 2),
(3,  N'0001-00000003', '20260922 10:05:00', N'CONFIRMADA', 3, 6, 3),
(4,  N'0001-00000004', '20260922 17:10:00', N'CONFIRMADA', 4, 7, 4),
(5,  N'0001-00000005', '20260923 09:40:00', N'CONFIRMADA', 1, 6, 5),
(6,  N'0001-00000006', '20260923 11:20:00', N'CONFIRMADA', 2, 5, 6),
(7,  N'0001-00000007', '20260924 10:30:00', N'CONFIRMADA', 3, 7, 7),
(8,  N'0001-00000008', '20260925 18:00:00', N'CONFIRMADA', 4, 6, 8),
(9,  N'0001-00000009', '20260928 12:00:00', N'ANULADA',    1, 5, 9),
(10, N'0001-00000010', '20260930 09:00:00', N'CONFIRMADA', 2, 7, 10);
SET IDENTITY_INSERT ventas OFF;
GO

-- ---------------------------------------------------------------------
--  DETALLES_VENTA (21): precio congelado al momento de la venta (RN01)
--  Totales: V1=14100  V2=28600  V3=131000  V4=40900  V5=6900
--           V6=25200  V7=182000 V8=15300   V9=42000 (anulada)  V10=4300
-- ---------------------------------------------------------------------
INSERT INTO detalles_venta (id_venta, id_producto, cantidad, precio_unitario_historico) VALUES
(1,  1,   3,  3200.00),
(1,  3,  10,   450.00),
(2,  6,   1, 17000.00),
(2,  4,   2,  5800.00),
(3,  2,  10,  9200.00),
(3,  8, 500,    55.00),
(3,  10,  5,  2300.00),
(4,  5,   1, 40000.00),
(4,  3,   2,   450.00),
(5,  9,  20,   230.00),
(5,  10,  1,  2300.00),
(6,  7,   2, 11000.00),
(6,  1,   1,  3200.00),
(7,  6,   8, 17000.00),
(7,  2,   5,  9200.00),
(8,  4,   1,  5800.00),
(8,  3,   5,   500.00),
(8,  1,   2,  3500.00),
(9,  5,   1, 42000.00),
(10, 8,  30,    60.00),
(10, 9,  10,   250.00);
GO

-- ---------------------------------------------------------------------
--  PAGOS_VENTA (10): la suma por venta = total de la venta (RN06)
--  La venta 2 se paga con dos medios (RF07). La venta 9 (anulada) no tiene pagos.
-- ---------------------------------------------------------------------
INSERT INTO pagos_venta (numero_transaccion, metodo_pago, monto, id_venta) VALUES
(N'EF-20260921-0001', N'EFECTIVO',       14100.00,  1),
(N'EF-20260921-0002', N'EFECTIVO',       10000.00,  2),
(N'MP-88120345',      N'MERCADO_PAGO',   18600.00,  2),
(N'TR-00981234',      N'TRANSFERENCIA', 131000.00,  3),
(N'TD-4471120',       N'TARJETA_DEBITO', 40900.00,  4),
(N'EF-20260923-0001', N'EFECTIVO',        6900.00,  5),
(N'MP-88345671',      N'MERCADO_PAGO',   25200.00,  6),
(N'TR-00987766',      N'TRANSFERENCIA', 182000.00,  7),
(N'EF-20260925-0001', N'EFECTIVO',       15300.00,  8),
(N'EF-20260930-0001', N'EFECTIVO',        4300.00, 10);
GO

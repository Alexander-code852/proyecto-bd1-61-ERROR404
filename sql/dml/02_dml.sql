-- =====================================================================
--  PROYECTO INTEGRADOR - BASES DE DATOS I
--  Equipo ERROR 404 - Librería "Color & Pincel"
--  ETAPA III: Implementación Física
--  Script 2/2: DML (Data Manipulation Language) - Poblado inicial
--  Ejecutar DESPUÉS de 01_ddl.sql
-- =====================================================================

USE color_y_pincel;

-- ---------------------------------------------------------------------
--  PERSONAS (10): 4 clientes, 3 empleados, 3 proveedores
-- ---------------------------------------------------------------------
INSERT INTO personas (id_persona, nombre, apellido, dni_cuit, telefono, email, tipo_persona) VALUES
(1,  'Martín',    'Gómez',                 '30111222',      '3624-501122', 'martin.gomez@mail.com',       'CLIENTE'),
(2,  'Lucía',     'Fernández',             '32555666',      '3624-502233', 'lucia.fernandez@mail.com',    'CLIENTE'),
(3,  'Instituto', 'San Martín S.R.L.',     '30-71234567-8', '3624-443300', 'compras@institutosanmartin.edu.ar', 'CLIENTE'),
(4,  'Valeria',   'Romero',                '35888999',      '3624-504455', 'valeria.romero@mail.com',     'CLIENTE'),
(5,  'Carolina',  'Benítez',               '28444555',      '3624-505566', 'carolina.benitez@colorypincel.com', 'EMPLEADO'),
(6,  'Diego',     'Ruiz',                  '36777888',      '3624-506677', 'diego.ruiz@colorypincel.com', 'EMPLEADO'),
(7,  'Sofía',     'Acosta',                '40222333',      '3624-507788', 'sofia.acosta@colorypincel.com', 'EMPLEADO'),
(8,  'Distribuidora', 'Papelera del Nordeste S.A.', '30-70111222-3', '0379-4421100', 'ventas@papeleranordeste.com.ar', 'PROVEEDOR'),
(9,  'Editorial',  'Kapelusz Distribuciones S.A.', '30-69888777-1', '011-43217700', 'pedidos@kapelusz-dist.com.ar', 'PROVEEDOR'),
(10, 'Insumos',    'Gráficos Chaco S.R.L.', '30-71555444-9', '3624-455900', 'info@insumoschaco.com.ar',   'PROVEEDOR');

-- ---------------------------------------------------------------------
--  PRODUCTOS (10): 7 artículos + 3 servicios (sin stock ni código de barras)
-- ---------------------------------------------------------------------
INSERT INTO productos (id_producto, codigo_barras, nombre, tipo, marca, precio_venta, stock_actual, stock_minimo) VALUES
(1,  '7790001000011', 'Cuaderno espiralado 48 hojas rayado', 'LIBRERIA', 'Rivadavia',  3500.00,  75, 15),
(2,  '7790002000028', 'Resma papel A4 75g x 500 hojas',      'PAPELERIA','Report',      9800.00,  55, 10),
(3,  '7790003000035', 'Lapicera azul trazo medio',           'LIBRERIA', 'BIC',          500.00, 385, 50),
(4,  '7790004000042', 'Set de 12 marcadores punta fina',     'LIBRERIA', 'Filgo',       6200.00,  42,  8),
(5,  '7790005000059', 'Mochila escolar 18 pulgadas',         'LIBRERIA', 'Footy',      42000.00,  23,  3),
(6,  '9789501000066', 'Manual de Matemática 3 - Secundaria', 'LIBRO',    'Kapelusz',   18500.00,  28,  5),
(7,  '7790007000073', 'Cartucho de tinta negra 664',         'INSUMO',   'Epson',      11500.00,  18,  5),
(8,  NULL,            'Fotocopia A4 blanco y negro',         'SERVICIO', NULL,            60.00,   0,  0),
(9,  NULL,            'Impresión A4 color',                  'SERVICIO', NULL,           250.00,   0,  0),
(10, NULL,            'Anillado hasta 100 hojas',            'SERVICIO', NULL,          2500.00,   0,  0);

-- ---------------------------------------------------------------------
--  CAJAS (8)
-- ---------------------------------------------------------------------
INSERT INTO cajas (id_caja, numero_caja, estado) VALUES
(1, 1, 'ABIERTA'),
(2, 2, 'CERRADA'),
(3, 3, 'CERRADA'),
(4, 4, 'CERRADA'),
(5, 5, 'CERRADA'),
(6, 6, 'CERRADA'),
(7, 7, 'MANTENIMIENTO'),
(8, 8, 'INACTIVA');

-- ---------------------------------------------------------------------
--  SESIONES_CAJA (10): 9 cerradas + 1 abierta (id 10, sin cierre)
--  monto_final = monto_inicial + efectivo cobrado en la sesión (arqueo)
-- ---------------------------------------------------------------------
INSERT INTO sesiones_caja
    (id_sesion, fecha_hora_apertura, fecha_hora_cierre, monto_inicial_efectivo, monto_final_efectivo, id_empleado_cajero, id_caja) VALUES
(1,  '2026-09-21 08:00:00', '2026-09-21 14:00:00', 20000.00, 34100.00, 6, 1),
(2,  '2026-09-21 15:00:00', '2026-09-21 21:00:00', 15000.00, 25000.00, 7, 1),
(3,  '2026-09-22 08:00:00', '2026-09-22 14:00:00', 20000.00, 20000.00, 6, 2),
(4,  '2026-09-22 15:00:00', '2026-09-22 21:00:00', 20000.00, 20000.00, 7, 2),
(5,  '2026-09-23 08:00:00', '2026-09-23 14:00:00', 10000.00, 16900.00, 6, 1),
(6,  '2026-09-23 08:30:00', '2026-09-23 14:30:00', 10000.00, 10000.00, 5, 3),
(7,  '2026-09-24 08:00:00', '2026-09-24 14:00:00', 20000.00, 20000.00, 7, 2),
(8,  '2026-09-25 15:00:00', '2026-09-25 21:00:00', 15000.00, 30300.00, 6, 1),
(9,  '2026-09-28 08:00:00', '2026-09-28 14:00:00', 10000.00, 10000.00, 5, 3),
(10, '2026-09-30 08:30:00', NULL,                  15000.00, NULL,     7, 1);

-- ---------------------------------------------------------------------
--  COMPRAS (10) a proveedores (ids 8, 9, 10)
-- ---------------------------------------------------------------------
INSERT INTO compras (id_compra, numero_factura_proveedor, fecha_hora, id_proveedor) VALUES
(1,  'A-0004-00001201', '2026-09-01 10:00:00', 8),
(2,  'A-0012-00000587', '2026-09-02 11:30:00', 9),
(3,  'A-0007-00003345', '2026-09-03 09:45:00', 10),
(4,  'A-0004-00001260', '2026-09-08 10:15:00', 8),
(5,  'A-0012-00000602', '2026-09-09 12:00:00', 9),
(6,  'A-0004-00001311', '2026-09-14 09:30:00', 8),
(7,  'A-0007-00003410', '2026-09-15 10:45:00', 10),
(8,  'A-0004-00001355', '2026-09-17 11:00:00', 8),
(9,  'A-0012-00000640', '2026-09-18 10:20:00', 9),
(10, 'A-0007-00003498', '2026-09-22 09:15:00', 10);

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

-- ---------------------------------------------------------------------
--  VENTAS (10): 9 confirmadas + 1 anulada (id 9)
--  id_cajero de la sesión = quien abre la caja; id_vendedor = quien vende
-- ---------------------------------------------------------------------
INSERT INTO ventas (id_venta, numero_comprobante, fecha_hora, estado, id_cliente, id_vendedor, id_sesion) VALUES
(1,  '0001-00000001', '2026-09-21 09:15:00', 'CONFIRMADA', 1, 6, 1),
(2,  '0001-00000002', '2026-09-21 16:30:00', 'CONFIRMADA', 2, 7, 2),
(3,  '0001-00000003', '2026-09-22 10:05:00', 'CONFIRMADA', 3, 6, 3),
(4,  '0001-00000004', '2026-09-22 17:10:00', 'CONFIRMADA', 4, 7, 4),
(5,  '0001-00000005', '2026-09-23 09:40:00', 'CONFIRMADA', 1, 6, 5),
(6,  '0001-00000006', '2026-09-23 11:20:00', 'CONFIRMADA', 2, 5, 6),
(7,  '0001-00000007', '2026-09-24 10:30:00', 'CONFIRMADA', 3, 7, 7),
(8,  '0001-00000008', '2026-09-25 18:00:00', 'CONFIRMADA', 4, 6, 8),
(9,  '0001-00000009', '2026-09-28 12:00:00', 'ANULADA',    1, 5, 9),
(10, '0001-00000010', '2026-09-30 09:00:00', 'CONFIRMADA', 2, 7, 10);

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

-- ---------------------------------------------------------------------
--  PAGOS_VENTA (10): la suma por venta = total de la venta (RN06)
--  La venta 2 se paga con dos medios (RF07). La venta 9 (anulada) no tiene pagos.
-- ---------------------------------------------------------------------
INSERT INTO pagos_venta (numero_transaccion, metodo_pago, monto, id_venta) VALUES
('EF-20260921-0001', 'EFECTIVO',       14100.00,  1),
('EF-20260921-0002', 'EFECTIVO',       10000.00,  2),
('MP-88120345',      'MERCADO_PAGO',   18600.00,  2),
('TR-00981234',      'TRANSFERENCIA', 131000.00,  3),
('TD-4471120',       'TARJETA_DEBITO', 40900.00,  4),
('EF-20260923-0001', 'EFECTIVO',        6900.00,  5),
('MP-88345671',      'MERCADO_PAGO',   25200.00,  6),
('TR-00987766',      'TRANSFERENCIA', 182000.00,  7),
('EF-20260925-0001', 'EFECTIVO',       15300.00,  8),
('EF-20260930-0001', 'EFECTIVO',        4300.00, 10);

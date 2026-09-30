# Etapa III - Pruebas y Validación

**Proyecto:** Librería "Color & Pincel" - Equipo ERROR 404

**Entorno de prueba:** MariaDB 10.11, base `color_y_pincel` recién creada con `sql/01_ddl.sql` y poblada con `sql/02_dml.sql`.
Los resultados de este documento son salidas reales obtenidas al ejecutar cada sentencia.

## 1. Validación de la carga

Los dos scripts se ejecutaron sin errores y en orden (DDL, luego DML).

### 1.1 Registros por tabla

Consulta 1 de `sql/03_verificacion.sql`. Se pide un mínimo de 8 a 10 registros coherentes por tabla:

| Tabla | Registros | Cumple |
|---|---|---|
| personas | 10 | Sí |
| productos | 10 | Sí |
| cajas | 8 | Sí |
| sesiones_caja | 10 | Sí |
| ventas | 10 | Sí |
| compras | 10 | Sí |
| pagos_venta | 10 | Sí |
| detalles_venta | 21 | Sí |
| detalles_compra | 16 | Sí |

### 1.2 Coherencia de los datos (RN06)

Total de cada venta (calculado con los detalles) contra la suma de sus pagos:

| Venta | Estado | Total venta | Total pagos | Resultado |
|---|---|---|---|---|
| 1 | CONFIRMADA | 14100.00 | 14100.00 | OK |
| 2 | CONFIRMADA | 28600.00 | 28600.00 | OK (dos medios de pago) |
| 3 | CONFIRMADA | 131000.00 | 131000.00 | OK |
| 4 | CONFIRMADA | 40900.00 | 40900.00 | OK |
| 5 | CONFIRMADA | 6900.00 | 6900.00 | OK |
| 6 | CONFIRMADA | 25200.00 | 25200.00 | OK |
| 7 | CONFIRMADA | 182000.00 | 182000.00 | OK |
| 8 | CONFIRMADA | 15300.00 | 15300.00 | OK |
| 9 | ANULADA | 42000.00 | 0.00 | OK (anulada, sin cobro) |
| 10 | CONFIRMADA | 4300.00 | 4300.00 | OK |

### 1.3 Arqueo de caja

Consulta 3 de `sql/03_verificacion.sql`. En las 9 sesiones cerradas, el monto final declarado coincide con el esperado (monto inicial más efectivo cobrado en ventas confirmadas). La sesión 10 sigue abierta, por eso su monto final es `NULL` (el efectivo esperado hasta ahora es 19300.00).

## 2. Pruebas de restricciones (casos que deben fallar)

Cada caso intenta violar una restricción. **Resultado esperado: la base rechaza la operación.** En todos los casos se cumplió.

| N.º | Restricción probada | Sentencia | Resultado obtenido |
|---|---|---|---|
| T1 | PK duplicada | `INSERT INTO cajas(id_caja,numero_caja,estado) VALUES (1,99,'CERRADA');` | `ERROR 1062: Duplicate entry '1' for key 'PRIMARY'` |
| T2 | UNIQUE (DNI/CUIT, RN05) | `INSERT INTO personas(...) VALUES('Ana','Test','30111222','CLIENTE');` | `ERROR 1062: Duplicate entry '30111222' for key 'uq_personas_dni_cuit'` |
| T3 | UNIQUE (comprobante) | `INSERT INTO ventas(...) VALUES('0001-00000001',1,6,1);` | `ERROR 1062: Duplicate entry '0001-00000001' for key 'uq_ventas_comprobante'` |
| T4 | FK inexistente | `INSERT INTO ventas(...) VALUES('0001-00000099',999,6,1);` | `ERROR 1452: Cannot add or update a child row: a foreign key constraint fails (... CONSTRAINT fk_venta_cliente ...)` |
| T5 | NOT NULL | `INSERT INTO personas(nombre,...) VALUES(NULL,'X','111','CLIENTE');` | `ERROR 1048: Column 'nombre' cannot be null` |
| T6 | CHECK stock no negativo | `INSERT INTO productos(...,stock_actual) VALUES(...,-1);` | `ERROR 4025: CONSTRAINT ck_productos_stock_actual failed` |
| T7 | CHECK dominio de tipo | `INSERT INTO personas(...) VALUES('a','b','999','ALIEN');` | `ERROR 4025: CONSTRAINT ck_personas_tipo failed` |
| T8 | CHECK cantidad positiva | `INSERT INTO detalles_venta(...) VALUES(5,4,0,100);` | `ERROR 4025: CONSTRAINT ck_detventa_cantidad failed` |
| T9 | CHECK cierre posterior a apertura | `INSERT INTO sesiones_caja(...) VALUES('2026-09-29 10:00','2026-09-29 09:00',...);` | `ERROR 4025: CONSTRAINT ck_sesion_fechas failed` |
| T10 | CHECK método de pago | `INSERT INTO pagos_venta VALUES('X-1','BITCOIN',10,1);` | `ERROR 4025: CONSTRAINT ck_pagos_metodo failed` |
| T11 | PK compuesta duplicada | `INSERT INTO detalles_venta VALUES(1,1,1,100);` | `ERROR 1062: Duplicate entry '1-1' for key 'PRIMARY'` |

> El código de error 4025 corresponde a MariaDB. En MySQL 8 el mensaje equivalente es `ERROR 3819: Check constraint '...' is violated`.

## 3. Pruebas de reglas de borrado y modificación

### 3.1 `ON DELETE RESTRICT` (debe fallar)

| N.º | Sentencia | Resultado obtenido |
|---|---|---|
| T12 | `DELETE FROM productos WHERE id_producto=1;` | `ERROR 1451: Cannot delete or update a parent row` (restricción `fk_detcompra_producto`) |
| T13 | `DELETE FROM personas WHERE id_persona=6;` | `ERROR 1451` (restricción `fk_sesion_cajero`) |
| T14 | `DELETE FROM sesiones_caja WHERE id_sesion=1;` | `ERROR 1451` (restricción `fk_venta_sesion`) |

Un producto, una persona o una sesión con historial no se pueden eliminar.

### 3.2 `ON DELETE CASCADE` (debe propagar)

**T15.** Dentro de una transacción con `ROLLBACK` posterior, se eliminaron las ventas 9 y 2:

```sql
START TRANSACTION;
DELETE FROM ventas WHERE id_venta IN (9,2);
SELECT (SELECT COUNT(*) FROM detalles_venta WHERE id_venta IN (9,2)) det_restantes,
       (SELECT COUNT(*) FROM pagos_venta WHERE id_venta=2) pagos_restantes;
ROLLBACK;
```

| Antes (venta 9: detalles / venta 2: pagos) | Después (detalles restantes / pagos restantes) |
|---|---|
| 1 detalle / 2 pagos | 0 detalles / 0 pagos |

Al borrar la cabecera se eliminaron sus detalles y pagos. Como se hizo `ROLLBACK`, los datos de prueba quedaron intactos.

### 3.3 `ON UPDATE CASCADE` (debe propagar)

**T16.** Dentro de una transacción con `ROLLBACK`, se cambió la PK de una persona:

```sql
START TRANSACTION;
UPDATE personas SET id_persona=100 WHERE id_persona=1;
SELECT id_cliente, COUNT(*) ventas FROM ventas GROUP BY id_cliente HAVING id_cliente=100;
ROLLBACK;
```

Resultado: `id_cliente = 100`, `ventas = 3`. Las 3 ventas del cliente 1 pasaron a referenciar el nuevo id.

## 4. Verificación del esquema creado

**T17.** Consulta a `information_schema.table_constraints`. Se crearon las siguientes restricciones en las 9 tablas:
- 9 claves primarias
- 11 claves foráneas
- 6 restricciones `UNIQUE` (además de las claves primarias)
- 17 restricciones `CHECK`

**T18.** Consulta a `information_schema.referential_constraints`. Las 11 FK quedaron con las reglas de borrado y modificación documentadas en `restricciones-integridad.md`, sección 2:

| Regla | Cantidad | FK |
|---|---|---|
| `DELETE RESTRICT` / `UPDATE CASCADE` | 8 | maestras, sesiones y productos en detalles |
| `DELETE CASCADE` / `UPDATE CASCADE` | 3 | `fk_pago_venta`, `fk_detventa_venta`, `fk_detcompra_compra` |

## 5. Conclusión

- Los scripts DDL y DML se ejecutan sin errores y son repetibles.
- Todas las tablas superan el mínimo de registros requerido y los datos son coherentes entre sí.
- Las 14 pruebas de violación de restricciones (T1 a T14) fueron rechazadas por el motor, y las reglas `CASCADE` (T15 y T16) se comportaron como se diseñaron.
- Quedan fuera de esta etapa las reglas RN02, RN03, RN04 y RN06 como controles automáticos (ver `restricciones-integridad.md`, sección 5).

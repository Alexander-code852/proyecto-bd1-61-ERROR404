# Modelo Relacional Normalizado (3FN)

A continuación se presenta el esquema relacional definitivo de la base de datos, incorporando las correcciones estructurales aplicadas durante el proceso de normalización para cumplir con la Primera, Segunda y Tercera Forma Normal.

**Simbología:**
* **MAYÚSCULAS:** Nombre de la Relación (Tabla).
* **Subrayado (<u>atributo</u>):** Clave Primaria (PK - Primary Key).
* **Cursiva (*atributo*):** Clave Foránea (FK - Foreign Key).
* **Subrayado y cursiva (<u>*atributo*</u>):** Clave Primaria Compuesta que también es Clave Foránea.

---

### Entidades Maestras

**PERSONAS** (<u>id_persona</u>, nombre, apellido, telefono, email, tipo_persona)
> *Nota:* Se separó el atributo compuesto original en `nombre` y `apellido` para cumplir con la 1FN (atomicidad).

**PRODUCTOS** (<u>id_producto</u>, nombre, tipo, marca, precio_venta, stock_actual, stock_minimo)

**CAJAS** (<u>id_caja</u>, numero_caja, estado)

---

### Entidades Transaccionales y Operativas

**SESIONES_CAJA** (<u>id_sesion</u>, fecha_hora_apertura, fecha_hora_cierre, monto_inicial_efectivo, monto_final_efectivo, *id_empleado_cajero*, *id_caja*)
* *id_empleado_cajero* hace referencia a PERSONAS(id_persona)
* *id_caja* hace referencia a CAJAS(id_caja)

**VENTAS** (<u>id_venta</u>, numero_comprobante, fecha_hora, estado, *id_cliente*, *id_vendedor*, *id_sesion*)
* *id_cliente* hace referencia a PERSONAS(id_persona)
* *id_vendedor* hace referencia a PERSONAS(id_persona)
* *id_sesion* hace referencia a SESIONES_CAJA(id_sesion)
> *Nota:* Se eliminó `monto_total` (3FN) y se agregó `id_sesion` para corregir la cardinalidad (1FN).

**COMPRAS** (<u>id_compra</u>, numero_factura_proveedor, fecha_hora, *id_proveedor*)
* *id_proveedor* hace referencia a PERSONAS(id_persona)
> *Nota:* Se eliminó `id_producto` de la cabecera (1FN) y `monto_total` (3FN).

**PAGOS_VENTA** (<u>numero_transaccion</u>, metodo_pago, monto, *id_venta*)
* *id_venta* hace referencia a VENTAS(id_venta)

---

### Entidades de Detalle (Resolución de relaciones Muchos a Muchos)

**DETALLES_VENTA** (<u>*id_venta*</u>, <u>*id_producto*</u>, cantidad, precio_unitario_historico)
* *id_venta* hace referencia a VENTAS(id_venta)
* *id_producto* hace referencia a PRODUCTOS(id_producto)

**DETALLES_COMPRA** (<u>*id_compra*</u>, <u>*id_producto*</u>, cantidad, costo_unitario_historico)
* *id_compra* hace referencia a COMPRAS(id_compra)
* *id_producto* hace referencia a PRODUCTOS(id_producto)
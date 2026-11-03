# 2. Manejo de Transacciones

Una transacción agrupa múltiples operaciones SQL en una única unidad lógica de trabajo controlada bajo las propiedades **ACID** (*Atomicidad, Consistencia, Aislamiento y Durabilidad*). Si una sentencia falla, se revierte todo el bloque mediante un `ROLLBACK`.

Cabe mencionar como ventaja que evita estados inconsistentes en el sistema (por ejemplo, registrar una venta pero omitir el descuento de stock o dejar un detalle incompleto).

**Aplicado al dominio de nuestro problema:** registrar una venta completa validando de manera estricta que exista stock suficiente para cada producto antes de impactar el inventario.
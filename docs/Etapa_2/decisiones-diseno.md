# Decisiones de Diseño - Modelo de Base de Datos (Etapa 2)

Este documento registra las principales decisiones arquitectónicas y de diseño relacional tomadas durante la revisión y normalización del modelo de base de datos del sistema de ventas e inventario.

## 1. Garantizar la Atomicidad de los Datos (1FN)
*   **Contexto:** La tabla `Personas` contenía un atributo llamado `nombre_apellido`.
*   **Decisión:** Se decidió separar este campo en dos columnas independientes: `nombre` y `apellido`.
*   **Justificación:** Cumplir con la Primera Forma Normal (1FN) que exige que todos los valores de las columnas sean atómicos. Esto facilita futuras consultas, ordenamiento y filtrado por apellido o nombre individualmente.

## 2. Eliminación de Grupos Repetitivos Estructurales (1FN)
*   **Contexto:** Se detectaron claves foráneas mal ubicadas en las cabeceras de transacciones y sesiones.
    *   `Compra` incluía `id_producto`.
    *   `Sesion Caja` incluía `id_venta`.
*   **Decisión:** 
    1. Eliminar `id_producto` de la tabla `Compra`, delegando la relación de múltiples productos a la tabla intermedia `Detalle Compra`.
    2. Eliminar `id_venta` de `Sesion Caja` y, en su lugar, agregar `id_sesion` como clave foránea dentro de la tabla `Venta`.
*   **Justificación:** Una compra tiene muchos productos y una sesión de caja agrupa múltiples ventas. Mantener estas FKs en las tablas originales obligaba a duplicar registros innecesariamente (violación de la 1FN) y rompía la cardinalidad lógica del negocio.

## 3. Prevención de Dependencias Parciales (2FN)
*   **Contexto:** Diseño de las tablas de detalle (`Detalle Venta` y `Detalle Compra`) que poseen claves primarias compuestas (ID de transacción + ID de producto).
*   **Decisión:** Mantener atributos descriptivos del producto (como `marca`, `tipo`, `nombre`) estrictamente en la tabla maestra `Producto`, e incluir en los detalles únicamente los valores transaccionales históricos (`precio_unitario_historico`, `costo_unitario_historico`, `cantidad`).
*   **Justificación:** Cumplir con la Segunda Forma Normal (2FN). Si se incluían datos como la "marca" en el detalle de la venta, estos dependerían solo de una parte de la clave primaria (`id_producto`), generando redundancia y posibles anomalías de actualización.

## 4. Manejo de Campos Calculados (3FN vs. Desnormalización Controlada)
*   **Contexto:** Las tablas `Venta` y `Compra` incluyen un campo `monto_total`.
*   **Decisión:** Para fines de diseño académico y cumplimiento estricto de la Tercera Forma Normal (3FN), se establece que el `monto_total` no debe almacenarse físicamente.
*   **Justificación:** El total es una dependencia transitiva; se puede derivar multiplicando la `cantidad` por el `precio_unitario_historico` en las tablas de detalle. 
*   *Nota de Diseño Práctico:* Se documenta que en un entorno de producción real, retener este campo se consideraría una "desnormalización controlada" aceptable para optimizar tiempos de consulta en reportes financieros.
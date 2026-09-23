

ETAPA 2 - Análisis de Normalización
El presente documento detalla el análisis de las tablas proporcionadas, revelando cómo el
modelo aplica las reglas de normalización y estableciendo las correcciones estructurales
necesarias para que el diseño cumpla estrictamente con cada forma normal.
- Primera Forma Normal (1FN): Eliminación de grupos repetitivos y
atomicidad
Para cumplir con la 1FN, las tablas no deben contener atributos multivaluados (grupos
repetitivos) y cada columna debe contener valores atómicos.
 Logros en el modelo: La separación lógica entre las cabeceras de transacciones (Venta,
Compra) y sus respectivas líneas de artículos (Detalle Venta, Detalle Compra) es el paso
fundamental de la 1FN. Esto evita que una sola fila de venta contenga una lista infinita
de productos.
 Corrección de atomicidad: En la tabla Personas, el atributo nombre_apellido no es
atómico. Para cumplir con la 1FN, debe dividirse en dos campos independientes:
nombre y apellido.
 Corrección de grupos repetitivos estructurales:
 La tabla Compra incluye erróneamente el campo id_producto (FK). Como una
compra está compuesta por múltiples productos, mantener este campo en la
cabecera obliga a repetir la fila de la compra por cada producto. Este campo debe
ser eliminado de Compra.
 La tabla Sesion Caja contiene el campo id_venta (FK). Una sesión de caja abarca
múltiples ventas. Colocar la clave foránea de la venta dentro de la sesión es un error
de cardinalidad. La solución es eliminar id_venta de Sesion Caja y agregar id_sesion
(FK) en la tabla Venta.
- Segunda Forma Normal (2FN): Eliminación de dependencias parciales
La 2FN aplica principalmente a tablas con claves primarias compuestas, garantizando que
los atributos no clave dependan de la totalidad de la clave y no solo de una parte de ella.
 Logros en el modelo: Se observa correctamente en las tablas transaccionales. En
Detalle Venta y Detalle Compra, la clave primaria lógica es compuesta (ID de la
transacción y el id_producto). Atributos como cantidad, costo_unitario_historico y
precio_unitario_historico dependen exclusivamente de esa combinación exacta.
 Si atributos propios del producto (como marca o tipo) se hubieran incluido en Detalle
Venta, existiría una dependencia parcial. El modelo evita esto al mantener esos datos
correctamente aislados en la tabla Producto.

- Tercera Forma Normal (3FN): Eliminación de dependencias transitivas
Para estar en 3FN, la tabla debe estar en 2FN y ningún atributo no clave debe depender de
otro atributo no clave.
 Logros en el modelo: Las entidades maestras como Producto y Caja cumplen esta regla.
Los campos stock_actual y stock_minimo dependen directamente de id_producto, así
como numero_caja y estado dependen directamente de id_caja.
 Corrección de campos calculados: En las tablas Venta y Compra, existe el campo
monto_total. Este valor es una dependencia transitiva, ya que se calcula
matemáticamente sumando los montos de las tablas de detalle. Para cumplir
estrictamente con la 3FN, monto_total no debe almacenarse, sino calcularse
dinámicamente mediante consultas.
Nota de diseño: En entornos reales de producción, almacenar el monto_total se considera una
"desnormalización controlada" aceptable para agilizar el rendimiento de consultas y
auditorías, pero a nivel puramente académico y de normalización estricta, es un dato
redundante que se debe omitir.
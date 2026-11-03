Funciones Almacenadas (User-Defined Functions / UDFs): Son rutinas programadas e integradas dentro del catálogo de la base de datos que reciben parámetros de 
entrada, ejecutan una secuencia computacional y devuelven obligatoriamente un resultado, ya sea un valor escalar (un único dato numérico, cadena o fecha) o una 
estructura tabular (UDF de tabla). En SQL Server, las funciones escalares permiten encapsular algoritmos de cálculo reutilizables que pueden invocarse directamente
dentro de sentencias SELECT, WHERE o HAVING sin alterar el estado de la base de datos (son de solo lectura/efectos secundarios no permitidos).

Procedimientos Almacenados (Stored Procedures / SPs): Son bloques de código T-SQL compilados que concentran flujos de control de flujo, operaciones DML (INSERT, 
UPDATE, DELETE) y gestión de errores. A diferencia de las funciones, los procedimientos pueden modificar el estado físico de los datos, manejar transacciones
explícitas (BEGIN TRANSACTION, COMMIT, ROLLBACK) y retornar múltiples conjuntos de resultados o códigos de estado (RETURN / parámetros OUTPUT).

Ventajas Arquitectónicas y Aplicaciones
Rendimiento y Optimización de Memoria: Al ejecutarse la primera vez, SQL Server compila el procedimiento almacenado y genera un plan de ejecución reutilizable que
se almacena en la Plan Cache. Esto elimina la necesidad de parsear y optimizar la consulta en cada llamada posterior, reduciendo el consumo de CPU y latencia de red.

Encapsulación de Reglas de Negocio: Evita la dispersión de la lógica comercial en las aplicaciones cliente (front-end o backend). Si la regla para calcular el 
descuento de un cliente cambia, solo se actualiza la función en el motor de datos sin necesidad de redesplegar o recompilar el software de venta.

Reducción del Tráfico en Red: En lugar de enviar múltiples sentencias SQL pesadas a través de la red (por ejemplo, crear cabecera, insertar 5 detalles y actualizar
5 stocks individualmente), la aplicación envía una única llamada con parámetros (EXEC sp_RegistrarVentaCompleta ...), disminuyendo significativamente la carga 
de transferencia.

Capa de Seguridad Abstraída (Principio de Mínimo Privilegio): Permite aislar las tablas principales (ventas, detalles_venta, productos). Se puede denegar el 
acceso directo de inserción o lectura a los cajeros sobre las tablas maestras y otorgarles únicamente permiso de ejecución (GRANT EXECUTE) sobre los procedimientos
y funciones autorizados.

Aplicación Concreta al Dominio de Negocio ("Color & Pincel")
En el sistema de la librería, estos componentes resuelven dos necesidades operativas clave:
Cálculo Dinámico de Fidelización (dbo.fn_CalcularDescuentoCliente):
Las políticas comerciales de la librería dictan otorgar descuentos progresivos según la recurrencia e historial de compra. La función calcula en tiempo real el 
volumen total acumulado de ventas CONFIRMADAS del cliente para retornar un porcentaje (0%, 5% o 10%). Al ser una función escalar, se integra nativamente en la 
consulta del punto de venta para calcular el subtotal antes de emitir el comprobante.

Procesamiento Atómico de Ventas (dbo.sp_RegistrarVentaConControlStock):
La venta en mostrador requiere impactar múltiples entidades de forma coordinada. El procedimiento almacenado centraliza en una sola llamada:
La verificación previa de disponibilidad en el inventario (stock_actual >= cantidad).
La generación del encabezado en la tabla ventas.
El registro del renglón en detalles_venta congelando el precio histórico (precio_unitario_historico).

El descuento automático de unidades en el catálogo de productos.

El manejo de excepciones con bloques TRY...CATCH para abortar la operación si algo falla.

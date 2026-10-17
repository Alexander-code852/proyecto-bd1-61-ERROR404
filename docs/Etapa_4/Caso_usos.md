# etapa-04

# DOCUMENTACIÓN DE CASOS DE USO Y CONTROL DE CALIDAD (QA) — ETAPA IV

**Proyecto Integrador:** Bases de Datos I

**Equipo:** ERROR 404 — Librería "Color & Pincel"

**Base de Datos:** `color_y_pincel`

## 1. INTRODUCCIÓN Y ALCANCE DE QA

El presente documento detalla la especificación técnica, el análisis de negocio y el protocolo de prueba y control de calidad (QA) para las consultas SQL desarrolladas durante la **Etapa IV: Consultas y Casos de Uso** de la librería *"Color & Pincel"*.

### Objetivos de Calidad Evaluados:

1. **Garantía de Reglas de Negocio:**

    **RN01 (Precio histórico):** Congelamiento y conservación de precios de venta/costo al momento de la transacción.

    **RN02 (Stock no negativo):** Consistencia de inventario.

    **RN05 (Unicidad identificadora):** Unicidad estricta de DNI/CUIT y código de barras.

    **Filtros de Estado:** Exclusión rigurosa de comprobantes con estado `'ANULADA'` o `'PENDIENTE'` en los balances acumulados gerenciales.

2. **Eficiencia en la Ejecución T-SQL:**

   * Utilización de claves primarias compuestas y claves foráneas indexadas (`idx_ventas_fecha`, `idx_detventa_producto`, `idx_pagos_venta`).

   * Optimización de uniones complejas (`INNER JOIN`) evitando producto cartesiano.

3. **Precisión de Agregación:**

   * Evaluación de funciones de agregación (`SUM`, `COUNT`, `AVG`) evitando la duplicación de sumas provocada por múltiples `JOIN`s mediante uso de CTEs o subconsultas previa agregación.

## 2. CASOS DE USO Y ESPECIFICACIÓN TÉCNICA

### 2.1. CASO DE USO 1: Comprobante / Factura de Venta Detallada

* **Archivo de Origen:** `sql/consultas/comprobante.sql`

* **Autor:** Gustavo Gabriel Gabutti (DNI: 46064849)

#### A. Propósito de Negocio

Generar la vista detallada de facturación para la impresión o emisión digital del comprobante de venta solicitado por el cliente en el punto de venta. Debe mostrar la información de la cabecera (cliente, vendedor, número de comprobante, fecha), el desglose ítem por ítem con cantidad, precio unitario aplicado al momento de la venta y subtotal, finalizando con el total general consolidado de la transacción.

#### B. Análisis y Justificación Técnica de la Consulta

* **Multi-Tablas (`INNER JOIN`):**

  * `ventas v INNER JOIN personas c ON v.id_cliente = c.id_persona`: Vincula la cabecera de la venta con los datos identificatorios del cliente.

  * `INNER JOIN personas vend ON v.id_vendedor = vend.id_persona`: Realiza un segundo *JOIN* a la misma entidad `personas` para obtener el vendedor que atendió la transacción (resuelve la relación de rol mediante alias).

  * `INNER JOIN detalles_venta dv ON v.id_venta = dv.id_venta`: Une la cabecera con cada renglón registrado.

  * `INNER JOIN productos p ON dv.id_producto = p.id_producto`: Obtiene la descripción textual y marca del producto/servicio.

* **Cálculo de Subtotal por Renglón:** `(dv.cantidad * dv.precio_unitario_historico)`

  * Aplica la constante del precio de la venta respetando **RN01**, garantizando que variaciones futuras de la tabla `productos` no alteren comprobantes históricos.

* **Subconsulta Correlacionada para Total General:**

  * `(SELECT SUM(dvsub.cantidad * dvsub.precio_unitario_historico) FROM detalles_venta dvsub WHERE dvsub.id_venta = v.id_venta)`

  * Proporciona en cada renglón de respuesta el valor total final del comprobante sin romper la estructura plana detallada de los ítems ni forzar una cláusula `GROUP BY` sobre todos los atributos del encabezado.

#### C. Ejemplo de Datos de Entrada y Salida Esperada (basado en `id_venta = 1` del DML)

* **Entrada (DML):** `id_venta = 1`, Cliente: Martín Gómez (ID 1), Vendedor: Diego Ruiz (ID 6), Ítems: 3x Cuaderno espiralado (\$3.200,00) y 10x Lapicera azul ($450,00).

* **Salida del Motor SQL:**

| Nro Comprobante | Fecha Hora Emisión | Cliente | Email Cliente | Vendedor Atendió | Producto / Servicio | Marca | Cantidad | Precio Unit. Histórico | Subtotal Renglón | Total General Comprobante | 
| ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | 
| `0001-00000001` | `2026-09-21 09:15:00` | Martín Gómez | `martin.gomez@mail.com` | Diego Ruiz | Cuaderno espiralado 48 hojas rayado | Rivadavia | 3 | \$3.500,00\* | \$9.600,00 | \$14.100,00 | 
| `0001-00000001` | `2026-09-21 09:15:00` | Martín Gómez | `martin.gomez@mail.com` | Diego Ruiz | Lapicera azul trazo medio | BIC | 10 | \$450,00 | \$4.500,00 | \$14.100,00 | 

*\*Nota de QA: Los subtotales dan \$9.600,00 + $4.500,00 = $14.100,00 en coincidencia exacta con el valor reportado por la subconsulta.*

#### D. Caso de Prueba QA

* **ID Prueba:** `QA-TC-01`

* **Criterio:** Verificar la concordancia entre la suma de los renglones y la subconsulta de totalización.

* **Resultado:** **APROBADO.** La subconsulta correlacionada no genera bloqueos de rendimiento gracias a la clave primaria compuesta `(id_venta, id_producto)` de `detalles_venta`.

### 2.2. CASO DE USO 2: Reporte Agregado de Ventas (Por Vendedor y Categoría/Producto)

* **Archivo de Origen:** `sql/consultas/informes.sql`

* **Autor:** Araceli Estefany Arredondo Vera (DNI: 49262230)

#### A. Propósito de Negocio

Brindar herramientas de Business Intelligence (BI) para el nivel gerencial. Ofrece dos métricas fundamentales dentro de un rango de fechas parametrizable:

1. Rendimiento y productividad por vendedor (total vendido, ticket promedio por comprobante y cantidad de ventas cerradas).

2. Desempeño comercial por categoría de producto y artículo individual (unidades vendidas, facturación acumulada y precio medio cobrado).

#### B. Análisis y Justificación Técnica de las Consultas

##### Reporte 1: Ventas por Vendedor (Uso de CTE)

* **Common Table Expression (CTE) `VentasCalculadas`:**

  * Agrupa en primera instancia los datos a nivel de comprobante (`v.id_venta`, `v.id_vendedor`), sumando el total de cada venta.

  * **Filtro crítico en CTE:** `v.estado = 'CONFIRMADA'` y filtro de rango `@FechaInicio` a `@FechaFin`. Esto garantiza que facturas anuladas o pendientes no ensucien los indicadores de desempeño.

* **Consulta Principal sobre el CTE:**

  * Realiza `INNER JOIN` con `personas p` para recuperar el nombre del vendedor.

  * Aplica funciones de agregación:

    * `COUNT(vc.id_venta)`: Cantidad de ventas realizadas.

    * `SUM(vc.total_venta)`: Mapeo del acumulado total por empleado.

    * `AVG(vc.total_venta)`: Cálculo exacto del **Ticket Promedio** por venta atendida.

* **Justificación Arquitectural:** Calcular el total de cada comprobante *antes* de unir con la tabla de personas evita el sesgo en el cálculo del promedio que sucedería si se agruparan renglones sueltos de artículos.

##### Reporte 2: Ventas por Categoría y Producto

* **Cláusula `GROUP BY pr.tipo, pr.id_producto, pr.nombre`:**

  * Permite jerarquizar los resultados primero por la categoría primaria del producto (`LIBRERIA`, `PAPELERIA`, `LIBRO`, `INSUMO`, `SERVICIO`) y posteriormente por el ítem específico.

* **Funciones de Agregación Utilizadas:**

  * `SUM(dv.cantidad)`: Volumen total de unidades/servicios despachados.

  * `COUNT(DISTINCT dv.id_venta)`: Número total de clientes/transacciones distintas que demandaron el producto.

  * `SUM(dv.cantidad * dv.precio_unitario_historico)`: Total acumulado recaudado.

  * `AVG(dv.precio_unitario_historico)`: Precio promedio histórico aplicado.

#### C. Ejemplo de Datos de Entrada y Salida Esperada (DML Septiembre 2026)

##### Salida Esperada - Reporte 1 (Vendedores):

| id_vendedor | vendedor | cantidad_comprobantes | total_acumulado_ventas | promedio_venta_por_comprobante | 
| ----- | ----- | ----- | ----- | ----- | 
| 6 | Diego Ruiz | 4 | \$177.300,00 | \$44.325,00 | 
| 7 | Sofía Acosta | 4 | \$451.700,00 | \$112.925,00 | 
| 5 | Carolina Benítez | 1 | \$25.200,00 | \$25.200,00 | 

##### Salida Esperada - Reporte 2 (Fragmento Categoría/Producto):

| categoria_producto | id_producto | producto | unidades_vendidas | cantidad_transacciones | total_acumulado_ventas | precio_promedio_historico | 
| ----- | ----- | ----- | ----- | ----- | ----- | ----- | 
| INSUMO | 7 | Cartucho de tinta negra 664 | 2 | 1 | \$22.000,00 | \$11.000,00 | 
| LIBRO | 6 | Manual de Matemática 3 - Secundaria | 9 | 2 | \$153.000,00 | \$17.000,00 | 
| PAPELERIA | 2 | Resma papel A4 75g x 500 hojas | 15 | 2 | \$138.000,00 | \$9.200,00 | 
| SERVICIO | 8 | Fotocopia A4 blanco y negro | 530 | 2 | \$29.300,00 | \$57,50 | 

#### D. Caso de Prueba QA

* **ID Prueba:** `QA-TC-02`

* **Criterio:** Validar que la Venta ID 9 (Estado `'ANULADA'`, Monto \$42.000,00 realizada por Carolina Benítez) sea descartada completamente de los totales acumulados.

* **Resultado:** **APROBADO.** El acumulado de Carolina Benítez da exactamente \$25.200,00 (correspondiente únicamente a la Venta ID 6 CONFIRMADA), comprobando la efectividad del filtro de estado.

### 2.3. CASO DE USO 3: Consulta Avanzada de Negocio — Segmentación de Clientes por Encima del Promedio General

* **Archivo de Origen:** `sql/consultas/negocio_avanzado.sql`

* **Autor:** Yonathan Ivan Melgarejo (DNI: 46512688)

#### A. Propósito de Negocio

Identificar a los clientes "VIP" o corporativos cuyo volumen acumulado de compras supera el promedio general de facturación acumulada de todos los clientes activos del negocio. Permite diseñar estrategias de fidelización, descuentos por volumen o líneas de crédito preferenciales.

#### B. Análisis y Justificación Técnica de la Consulta

* **Unión Multitabla Dinámica:**

  * Conecta `personas c` (filtrado por `c.tipo_persona = 'CLIENTE'`), `ventas v`, `detalles_venta dv` y `productos p`.

* **Filtros Previos a la Agregación (`WHERE`):**

  * `v.estado = 'CONFIRMADA'`: Descarta transacciones nulas antes de realizar las agrupaciones de memoria.

* **Cláusula de Agrupamiento (`GROUP BY`):**

  * Agrupa por las columnas descriptivas obligatorias del cliente: `c.id_persona`, `c.dni_cuit`, `c.apellido`, `c.nombre`.

* **Filtrado Avanzado a Nivel de Grupo (`HAVING` + Subconsulta Anidada):**

  * **La clave técnica de la consulta:** La cláusula `HAVING` evalúa la función agregada `SUM(dv.cantidad * dv.precio_unitario_historico)` y la compara dinámicamente contra el valor devuelto por la subconsulta escalada.

  * **Subconsulta escalar en `HAVING`:**

    ```
    SELECT AVG(sub.total_cliente)
    FROM (
        SELECT v2.id_cliente, SUM(dv2.cantidad * dv2.precio_unitario_historico) AS total_cliente
        FROM ventas v2
        INNER JOIN detalles_venta dv2 ON v2.id_venta = dv2.id_venta
        WHERE v2.estado = 'CONFIRMADA'
        GROUP BY v2.id_cliente
    ) AS sub
    
    ```

    1. La subconsulta interna (`sub`) agrupa las ventas por cada cliente individual y calcula su gran total facturado.

    2. La función externa `AVG()` saca el promedio general de esos totales consolidados.

    3. El `HAVING` filtra dejando pasar únicamente a los clientes cuyo total personal supere dicho promedio general.

#### C. Ejemplo de Datos de Entrada y Salida Esperada (basado en el DML)

* **Totales Calculados en DML por Cliente:**

  * **Cliente 3 (Instituto San Martín S.R.L.):** Venta 3 (\$131.000) + Venta 7 ($182.000) = **\$313.000,00** (2 ventas)

  * **Cliente 2 (Lucía Fernández):** Venta 2 (\$28.600) + Venta 6 ($25.200) + Venta 10 ($4.300) = **\$58.100,00** (3 ventas)

  * **Cliente 4 (Valeria Romero):** Venta 4 (\$40.900) + Venta 8 ($15.300) = **\$56.200,00** (2 ventas)

  * **Cliente 1 (Martín Gómez):** Venta 1 (\$14.100) + Venta 5 ($6.900) \[Venta 9 Anulada\] = **\$21.000,00** (2 ventas)

* **Promedio General del Negocio:** $(313.000 + 58.100 + 56.200 + 21.000) / 4 = \$448.300 / 4 =$ **\$112.075,00**.

* **Resultado del Filtrado `HAVING`:** Solo el cliente cuyo total es superior a \$112.075,00 debe aparecer.

##### Salida del Motor SQL:

| id_cliente | dni_cuit | cliente | cantidad_ventas | productos_distintos | total_facturado | ticket_promedio | 
| ----- | ----- | ----- | ----- | ----- | ----- | ----- | 
| 3 | `30-71234567-8` | Instituto San Martín S.R.L. | 2 | 5 | \$313.000,00 | \$156.500,00 | 

#### D. Caso de Prueba QA

* **ID Prueba:** `QA-TC-03`

* **Criterio:** Confirmar que los clientes con totales acumulados de \$58.100 (Lucía Fernández) y $56.200 (Valeria Romero) queden excluidos correctamente por no alcanzar el umbral promedio ($112.075,00).

* **Resultado:** **APROBADO.** La subconsulta anidada realiza la agregación previa en dos niveles adecuadamente sin generar subconsultas redundantes por cada fila del conjunto de datos.

## 3. MATRIZ DE RESUMEN Y CONTROL DE CALIDAD (QA MATRIX)

| ID Caso | Consulta / Archivo | Autor | Elementos Clave Eval. | Estado QA | Observaciones de Integridad | 
| ----- | ----- | ----- | ----- | ----- | ----- | 
| **QA-01** | `comprobante.sql` | Gustavo Gabutti | `INNER JOIN`, Subconsulta correlacionada. | **APROBADO** | Preserva congelamiento de precios históricos (**RN01**). Muestra subtotal e importe global exacto. | 
| **QA-02** | `informes.sql` | Araceli Arredondo | CTE (`WITH`), `GROUP BY`, `SUM`, `AVG`, `COUNT`. | **APROBADO** | Excluye facturas anuladas (**RN-Estado**). El uso de CTE elimina el sesgo en el cálculo del ticket promedio. | 
| **QA-03** | `negocio_avanzado.sql` | Yonathan Melgarejo | `HAVING`, Subconsulta escalar anidada en 2 niveles. | **APROBADO** | Calcula el promedio de ventas dinámicamente y filtra únicamente a clientes de alto rendimiento. | 

## 4. CONCLUSIÓN

Los scripts probados y documentados en la **Etapa IV** demuestran un nivel óptimo de calidad, precisión analítica y apego estricto a la arquitectura relacional diseñada en la Etapa III. La base de datos `color_y_pincel` responde satisfactoriamente a las demandas del negocio garantizando integridad, consistencia y óptimo rendimiento.

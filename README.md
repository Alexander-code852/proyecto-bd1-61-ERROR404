# Proyecto Bases de Datos I — Equipo 61 (`ERROR404`)

Repositorio del proyecto práctico de la asignatura **Bases de Datos I**.

---

## 📊 Etapa IV: Consultas y Casos de Uso

En esta etapa se desarrollan y prueban los scripts SQL para responder a las necesidades operativas y de análisis de información del negocio.

### 📋 1. Requisitos Previos (Preparación del Entorno)
Antes de probar las consultas de esta etapa, asegúrese de ejecutar en el motor de base de datos los scripts de las etapas previas en el siguiente orden:
1. **Creación de Estructura (DDL):** Ejecutar el script de creación de la base de datos, tablas y restricciones (`PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`).
2. **Carga de Datos de Prueba (DML):** Ejecutar el script de inserción de lotes de datos (`INSERT`) para poblar las tablas maestras y transaccionales.

---

### 🚀 2. Orden e Instrucciones de Ejecución de los Scripts (Etapa IV)

Una vez creada la estructura y cargados los datos de prueba, ejecutar los scripts de consulta en el siguiente orden:

#### Paso 1: Factura / Comprobante (`01_factura_comprobante.sql`)
- **Objetivo:** Consolidar el encabezado y el detalle de una venta, calculando los subtotales por renglón y el total acumulado del comprobante.
- **Cómo probarlo:**
  1. Abrir el script correspondiente a la consulta de **Factura/Comprobante**.
  2. Verificar que el identificador de la venta filtrada en la cláusula `WHERE` exista en el lote de datos cargado.
  3. Ejecutar la consulta y corroborar que se listen los datos de cabecera junto con cada ítem, su subtotal (`cantidad * precio`) y el total acumulado.

#### Paso 2: Reporte Agregado (`02_reporte_agregado.sql`)
- **Objetivo:** Obtener el total de ventas realizadas por cada vendedor o por cada categoría de producto dentro de un rango de fechas utilizando `GROUP BY`, `SUM` y `COUNT`.
- **Cómo probarlo:**
  1. Abrir el script correspondiente al **Reporte Agregado**.
  2. Verificar o ajustar el rango de fechas en el filtro `BETWEEN` de acuerdo con los registros insertados.
  3. Ejecutar la consulta y comprobar el resumen agrupado con la cantidad de ventas y el monto total facturado.

#### Paso 3: Consulta de Negocio Avanzada (`03_consulta_avanzada.sql`)
- **Objetivo:** Combinar al menos 3 tablas mediante `JOIN` aplicando filtros condicionales con `HAVING` o subconsultas.
- **Cómo probarlo:**
  1. Abrir el script correspondiente a la **Consulta de Negocio Avanzada**.
  2. Ejecutar la sentencia y verificar que los resultados integren correctamente la información de las tablas relacionadas y filtren los grupos o registros según la condición analítica definida.

---

## 👥 Integrantes — Equipo 61 (`ERROR404`)
- **Gustavo Gabriel Gabutti**
- **Araceli Estefany Arredondo Vera**
- **Yonathan Ivan Melgarejo**
- **Marcos Gabriel Barrios**
- **Alejandro Ezequiel Ratti (DNI: 44553325)** — *Gestión de Git y Guía de Ejecución*
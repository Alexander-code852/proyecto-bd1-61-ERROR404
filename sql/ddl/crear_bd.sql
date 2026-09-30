-- =====================================================================
--  PROYECTO INTEGRADOR - BASES DE DATOS I
--  Equipo ERROR 404 - Librería "Color & Pincel"
--  ETAPA III: Implementación Física
--  Script 1/2: DDL (Data Definition Language)
--  Motor: Microsoft SQL Server 2017+ (T-SQL)
--  Modelo de origen: docs/Etapa_2/modelo_relacional.md (3FN)
--  Ejecutar en SSMS / Azure Data Studio. Los "GO" separan lotes.
-- =====================================================================

USE master;
GO

IF DB_ID(N'color_y_pincel') IS NOT NULL
BEGIN
    ALTER DATABASE color_y_pincel SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE color_y_pincel;
END
GO

CREATE DATABASE color_y_pincel;
GO

USE color_y_pincel;
GO

-- ---------------------------------------------------------------------
--  ENTIDADES MAESTRAS
-- ---------------------------------------------------------------------

-- PERSONAS: clientes, empleados y proveedores en una única entidad.
-- dni_cuit se agrega para cumplir la RN05 (identificador unívoco).
-- Se usa NVARCHAR para admitir tildes y "ñ".
CREATE TABLE personas (
    id_persona   INT           IDENTITY(1,1) NOT NULL,
    nombre       NVARCHAR(60)  NOT NULL,
    apellido     NVARCHAR(60)  NOT NULL,
    dni_cuit     VARCHAR(13)   NOT NULL,
    telefono     VARCHAR(20)   NULL,
    email        VARCHAR(100)  NULL,
    tipo_persona VARCHAR(10)   NOT NULL,
    CONSTRAINT pk_personas PRIMARY KEY (id_persona),
    CONSTRAINT uq_personas_dni_cuit UNIQUE (dni_cuit),
    CONSTRAINT ck_personas_tipo CHECK (tipo_persona IN ('CLIENTE', 'EMPLEADO', 'PROVEEDOR'))
);
GO

-- En SQL Server un UNIQUE normal admite un solo NULL. Como el email es opcional,
-- se usa un índice único filtrado: solo controla los emails cargados.
CREATE UNIQUE INDEX uq_personas_email
    ON personas (email)
    WHERE email IS NOT NULL;
GO

-- PRODUCTOS: catálogo unificado de artículos y servicios (RF01).
-- Los servicios no manejan stock físico (stock 0) ni código de barras (NULL).
CREATE TABLE productos (
    id_producto   INT            IDENTITY(1,1) NOT NULL,
    codigo_barras VARCHAR(13)    NULL,
    nombre        NVARCHAR(100)  NOT NULL,
    tipo          VARCHAR(20)    NOT NULL,
    marca         NVARCHAR(50)   NULL,
    precio_venta  DECIMAL(10,2)  NOT NULL,
    stock_actual  INT            NOT NULL CONSTRAINT df_productos_stock_actual DEFAULT 0,
    stock_minimo  INT            NOT NULL CONSTRAINT df_productos_stock_minimo DEFAULT 0,
    CONSTRAINT pk_productos PRIMARY KEY (id_producto),
    CONSTRAINT ck_productos_tipo CHECK (tipo IN ('LIBRERIA', 'PAPELERIA', 'LIBRO', 'INSUMO', 'SERVICIO')),
    CONSTRAINT ck_productos_precio CHECK (precio_venta >= 0),
    CONSTRAINT ck_productos_stock_actual CHECK (stock_actual >= 0),   -- RN02: nunca stock negativo
    CONSTRAINT ck_productos_stock_minimo CHECK (stock_minimo >= 0)
);
GO

-- Código de barras único (RN05). Los servicios lo dejan en NULL, por eso índice filtrado.
CREATE UNIQUE INDEX uq_productos_codigo_barras
    ON productos (codigo_barras)
    WHERE codigo_barras IS NOT NULL;
GO

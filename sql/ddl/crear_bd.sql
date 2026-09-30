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

-- ---------------------------------------------------------------------
--  CAJAS
-- ---------------------------------------------------------------------
CREATE TABLE cajas (
    id_caja      INT IDENTITY(1,1) NOT NULL,
    numero_caja  INT NOT NULL,
    estado       VARCHAR(20) NOT NULL CONSTRAINT df_cajas_estado DEFAULT 'CERRADA',
    CONSTRAINT pk_cajas PRIMARY KEY (id_caja),
    CONSTRAINT uq_cajas_numero UNIQUE (numero_caja),
    CONSTRAINT ck_cajas_estado CHECK (estado IN ('ABIERTA', 'CERRADA', 'EN_MANTENIMIENTO'))
);
GO

-- ---------------------------------------------------------------------
--  SESIONES_CAJA
-- ---------------------------------------------------------------------
CREATE TABLE sesiones_caja (
    id_sesion              INT IDENTITY(1,1) NOT NULL,
    fecha_hora_apertura    DATETIME NOT NULL CONSTRAINT df_sesiones_apertura DEFAULT GETDATE(),
    fecha_hora_cierre      DATETIME NULL,
    monto_inicial_efectivo DECIMAL(10,2) NOT NULL,
    monto_final_efectivo    DECIMAL(10,2) NULL,
    id_empleado_cajero     INT NOT NULL,
    id_caja                INT NOT NULL,
    CONSTRAINT pk_sesiones_caja PRIMARY KEY (id_sesion),
    CONSTRAINT fk_sesiones_personas FOREIGN KEY (id_empleado_cajero)
        REFERENCES personas (id_persona) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT fk_sesiones_cajas FOREIGN KEY (id_caja)
        REFERENCES cajas (id_caja) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT ck_sesiones_monto_inicial CHECK (monto_inicial_efectivo >= 0)
);
GO

-- ---------------------------------------------------------------------
-- VENTAS
-- ---------------------------------------------------------------------
CREATE TABLE ventas (
    id_venta           INT IDENTITY(1,1) NOT NULL,
    numero_comprobante VARCHAR(20) NOT NULL,
    fecha_hora         DATETIME NOT NULL CONSTRAINT df_ventas_fecha DEFAULT GETDATE(),
    estado             VARCHAR(15) NOT NULL CONSTRAINT df_ventas_estado DEFAULT 'COMPLETADA',
    id_cliente         INT NOT NULL,
    id_vendedor        INT NOT NULL,
    id_sesion          INT NOT NULL,
    CONSTRAINT pk_ventas PRIMARY KEY (id_venta),
    CONSTRAINT uq_ventas_comprobante UNIQUE (numero_comprobante),
    CONSTRAINT fk_ventas_cliente FOREIGN KEY (id_cliente)
        REFERENCES personas (id_persona) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_ventas_vendedor FOREIGN KEY (id_vendedor)
        REFERENCES personas (id_persona) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_ventas_sesion FOREIGN KEY (id_sesion)
        REFERENCES sesiones_caja (id_sesion) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_ventas_estado CHECK (estado IN ('PENDIENTE', 'COMPLETADA', 'ANULADA'))
);
GO

-- ---------------------------------------------------------------------
-- COMPRAS
-- ---------------------------------------------------------------------
CREATE TABLE compras (
    id_compra                 INT IDENTITY(1,1) NOT NULL,
    numero_factura_proveedor  VARCHAR(30) NOT NULL,
    fecha_hora                DATETIME NOT NULL CONSTRAINT df_compras_fecha DEFAULT GETDATE(),
    id_proveedor              INT NOT NULL,
    CONSTRAINT pk_compras PRIMARY KEY (id_compra),
    CONSTRAINT fk_compras_proveedor FOREIGN KEY (id_proveedor)
        REFERENCES personas (id_persona) ON DELETE RESTRICT ON UPDATE CASCADE
);
GO
    
-- PAGOS_VENTA: una venta puede saldarse con varios medios de pago (RF07).
-- Si se elimina la venta, sus pagos se eliminan con ella (RNF02).
CREATE TABLE pagos_venta (
    numero_transaccion VARCHAR(30)   NOT NULL,
    metodo_pago        VARCHAR(20)   NOT NULL,
    monto              DECIMAL(12,2) NOT NULL,
    id_venta           INT           NOT NULL,
    CONSTRAINT pk_pagos_venta PRIMARY KEY (numero_transaccion),
    CONSTRAINT fk_pago_venta FOREIGN KEY (id_venta)
        REFERENCES ventas (id_venta)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT ck_pagos_metodo CHECK (metodo_pago IN
        ('EFECTIVO', 'TARJETA_DEBITO', 'TARJETA_CREDITO', 'TRANSFERENCIA', 'MERCADO_PAGO')),
    CONSTRAINT ck_pagos_monto CHECK (monto > 0)
);
GO

-- ---------------------------------------------------------------------
--  ENTIDADES DE DETALLE (relaciones N:M, PK compuesta)
-- ---------------------------------------------------------------------

-- DETALLES_VENTA: precio_unitario_historico queda congelado (RN01).
CREATE TABLE detalles_venta (
    id_venta                  INT           NOT NULL,
    id_producto               INT           NOT NULL,
    cantidad                  INT           NOT NULL,
    precio_unitario_historico DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_detalles_venta PRIMARY KEY (id_venta, id_producto),
    CONSTRAINT fk_detventa_venta FOREIGN KEY (id_venta)
        REFERENCES ventas (id_venta)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_detventa_producto FOREIGN KEY (id_producto)
        REFERENCES productos (id_producto)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT ck_detventa_cantidad CHECK (cantidad > 0),
    CONSTRAINT ck_detventa_precio CHECK (precio_unitario_historico >= 0)
);
GO

CREATE TABLE detalles_compra (
    id_compra                INT           NOT NULL,
    id_producto              INT           NOT NULL,
    cantidad                 INT           NOT NULL,
    costo_unitario_historico DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_detalles_compra PRIMARY KEY (id_compra, id_producto),
    CONSTRAINT fk_detcompra_compra FOREIGN KEY (id_compra)
        REFERENCES compras (id_compra)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_detcompra_producto FOREIGN KEY (id_producto)
        REFERENCES productos (id_producto)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT ck_detcompra_cantidad CHECK (cantidad > 0),
    CONSTRAINT ck_detcompra_costo CHECK (costo_unitario_historico >= 0)
);
GO

-- ---------------------------------------------------------------------
--  ÍNDICES sobre claves foráneas usadas en JOINs frecuentes
--  (SQL Server no crea índices automáticos sobre las FK)
-- ---------------------------------------------------------------------
CREATE INDEX idx_ventas_fecha       ON ventas (fecha_hora);
CREATE INDEX idx_ventas_sesion      ON ventas (id_sesion);
CREATE INDEX idx_pagos_venta        ON pagos_venta (id_venta);
CREATE INDEX idx_detventa_producto  ON detalles_venta (id_producto);
CREATE INDEX idx_detcompra_producto ON detalles_compra (id_producto);
GO


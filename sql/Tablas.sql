-- ==============================================
-- PROYECTO: SISTEMA DE GESTIÓN BANCARIA
-- AUTOR: JOAQUIN MANUEL ALPAÑEZ LOPEZ
-- DESCRIPCIÓN: MODELO DE DATOS | BASE
-- ==============================================


------------------------------------------------
-- TABLA: CLIENTES
------------------------------------------------
CREATE TABLE CLIENTES (
    ID_CLIENTE        NUMBER(6)       CONSTRAINT PK_CLIENTES PRIMARY KEY,
    NOMBRE            VARCHAR2(50)    NOT NULL,
    APELLIDOS         VARCHAR2(80)    NOT NULL,
    FECHA_ALTA        DATE            DEFAULT SYSDATE NOT NULL,
    EMAIL             VARCHAR2(100),
    TELEFONO          VARCHAR2(15),
	NIF				  VARCHAR2(15),
	ESTADO_CLIENTE    VARCHAR2(15) 	  DEFAULT 'ACTIVO' CHECK (estado_cliente IN ('ACTIVO','INACTIVO','BLOQUEADO'))
);

------------------------------------------------
-- TABLA: CONTACTOS
------------------------------------------------
CREATE TABLE CONTACTOS (
  ID_CONTACTO    NUMBER(8) PRIMARY KEY,
  ID_CLIENTE     NUMBER(6) NOT NULL
                 CONSTRAINT FK_CONTACTOS_CLIENTES REFERENCES CLIENTES(ID_CLIENTE) ON DELETE CASCADE,
  TIPO_CONTACTO  VARCHAR2(20) NOT NULL CHECK (TIPO_CONTACTO IN ('MOVIL','FIJO','TRABAJO','PERSONAL','EMAIL','OTRO')),
  VALOR          VARCHAR2(100) NOT NULL, -- TELEFONO O EMAIL
  VALOR_NORM     VARCHAR2(100),          -- TELEFONO EN E.164 O EMAIL EN MINÚSCULAS
  ES_PRINCIPAL   CHAR(1) DEFAULT 'N' CHECK (ES_PRINCIPAL IN ('S','N')),
  FECHA_ALTA     DATE DEFAULT SYSDATE,
  FUENTE         VARCHAR2(50)            -- P.EJ. 'ALTA_ONLINE','ATENCION_CLIENTE'
);

------------------------------------------------
-- TABLA: CUENTAS
------------------------------------------------
CREATE TABLE CUENTAS (
    ID_CUENTA         NUMBER(8)       CONSTRAINT PK_CUENTAS PRIMARY KEY,
    ID_CLIENTE        NUMBER(6)       CONSTRAINT FK_CUENTAS_CLIENTES
                                      REFERENCES CLIENTES (ID_CLIENTE)
                                      ON DELETE CASCADE,
    SALDO             NUMBER(12,2)    DEFAULT 0 CHECK (SALDO >= 0),
    FECHA_APERTURA    DATE            DEFAULT SYSDATE NOT NULL,
    TIPO_CUENTA       VARCHAR2(20)    DEFAULT 'CORRIENTE' CHECK (TIPO_CUENTA IN ('CORRIENTE', 'AHORRO'))
);

------------------------------------------------
-- TABLA: MOVIMIENTOS
------------------------------------------------
CREATE TABLE MOVIMIENTOS (
    ID_MOVIMIENTO     NUMBER(10)      CONSTRAINT PK_MOVIMIENTOS PRIMARY KEY,
    ID_CUENTA         NUMBER(8)       CONSTRAINT FK_MOVIMIENTOS_CUENTAS
                                      REFERENCES CUENTAS (ID_CUENTA)
                                      ON DELETE CASCADE,
    TIPO              VARCHAR2(15)    NOT NULL CHECK (TIPO IN ('INGRESO', 'RETIRADA', 'TRANSFERENCIA')),
    IMPORTE           NUMBER(12,2)    NOT NULL CHECK (IMPORTE > 0),
    FECHA_MOVIMIENTO  DATE            DEFAULT SYSDATE NOT NULL,
    DESCRIPCION       VARCHAR2(100)
);



------------------------------------------------
------------------------------------------------
------------------------------------------------
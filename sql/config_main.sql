-- ==============================================
-- PROYECTO: SISTEMA DE GESTIÓN BANCARIA Y ANTI FRAUDE
-- AUTOR: JOAQUÍN MANUEL ALPAÑEZ LÓPEZ
-- DESCRIPCIÓN: MODELO DE DATOS | CONFIGURACIÓN BASE
-- VERSION DE ORACLE DATABASE: Oracle 12c Express Edition
-- ENTORNO DE DESARROLLO: Oracle SQL Developer 24.3.1
-- ==============================================

-- ==============================================
-- BLOQUE DE EJECUCIÓN Y TRAZABILIDAD
-- ==============================================
-- Fecha de creación: 2025-10-21
-- Última modificación: 2025-10-21
-- Entorno objetivo: DESARROLLO / PRUEBAS
-- Ejecutar como: SYSTEM --> (rol SYSDBA)
-- Propósito: Configuración inicial de tablespaces, roles y usuarios
-- Requiere: Contenedor XEPDB1 activo
-- Dependencias: Ninguna
-- ==============================================

-- ==========================================================
-- EL SIGUIENTE SCRIPT SE HA EJECUTADO CON USUARIO SYSTEM (LLAMADO AQUI SYSDBA_LOCAL) CON ROL "SYSDBA".
-- ESTE USUARIO SOLO SE USARÁ PARA EJECUTAR ESTE SCRIPT O PARA TAREAS CRITICAS EN LA BASE DE DATOS.
-- ==========================================================

ALTER SESSION SET CONTAINER = CDB$ROOT; -- IMPORTANTE: Solo cambiamos al CDB para activar la siguiente funcionalidad.
ALTER SYSTEM SET AUDIT_TRAIL = DB, EXTENDED SCOPE = SPFILE; -- Activar auditoria para toda la instancia. (IMPORTANTE: REQUIERE REINICIO DE LA INSTANCIA).
ALTER PLUGGABLE DATABASE XEPDB1 OPEN; -- Activar container PDB "XEPDB1".
ALTER PLUGGABLE DATABASE XEPDB1 SAVE STATE; -- Guardar estado para proximas conexiones.

-- NOTA: Los parametros "ALTER PLUGGABLE..." solo son necesarios ejecutarlos una vez ya que guardaran el resultado para posteriores conexiones.
-- NOTA: NECESARIOS PARA CREAR USUARIOS EN EL GESTOR DE CONEXIONES DEL ENTORNO.

ALTER SESSION SET CONTAINER = XEPDB1; -- DEBIDO A ESTAR CONECTADO COMO SYS, PARA LA CREACION DE TABLESPACES, ROLES Y USUARIOS CAMBIO DE CDB A PDB "XEPDB1" (XE propio de Oracle 12c).
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE; -- Permite crear usuarios y roles locales con nombres sin prefijo “C##”, igualmente si nos situamos en el container XEPDB1 no es obligatorio.
ALTER SESSION SET CURRENT_SCHEMA = SYS; -- SOLO POR SEGURIDAD Y CONFIRMACION.
ALTER SESSION SET SQL_TRACE = TRUE; -- Activar trazas. (USAR SOLO PARA CONFIGURACION INICIAL).
ALTER SESSION SET TRACEFILE_IDENTIFIER = 'SISTEMA DE GESTION BANCARIA'; -- Marcar trazas.

--******************************************************************************
-- CONFIGURACIÓN DE TABLESPACES
--******************************************************************************

------------------------------------------------
-- TABLESPACE DE DATOS
------------------------------------------------
CREATE TABLESPACE DATA_TBS 
DATAFILE 'DATA_TBS01.DBF' SIZE 100M 
AUTOEXTEND ON NEXT 10M MAXSIZE 500M
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO;

------------------------------------------------
-- TABLESPACE DE ÍNDICES
------------------------------------------------
CREATE TABLESPACE INDEX_TBS 
DATAFILE 'INDEX_TBS01.DBF' SIZE 100M 
AUTOEXTEND ON NEXT 10M MAXSIZE 500M
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO;

-- NOTA: "AUTOEXTEND ON" debido a que se trata de un entorno de pruebas. 
-- En entornos profesionales se recomienda "AUTOEXTEND OFF" y ampliaciones manuales por parte del DBA.
-- AUTOALLOCATE ON debido a entornos bancarios de primer nivel donde suele haber disparidad de tamaño entre tablas.

-- NOTA: SE USARÁN ESTOS DOS TABLESPACES BASICOS PARA TODOS LOS USUARIOS DEBIDO A ENTORNO DE PRUEBAS, EN ENTORNO PROFESIONAL RECOMENDABLE USAR TABLESPACES UNICOS POR ESQUEMA/USUARIO.

--******************************************************************************
-- CONFIGURACIÓN DE ROLES
--******************************************************************************

------------------------------------------------
-- ROL: ADMINISTRADOR PARCIAL 
-- (Rol administrativo con privilegios elevados, sin llegar a nivel DBA completo)
------------------------------------------------
CREATE ROLE ROLE_ADMIN_ALL;
GRANT CONNECT TO ROLE_ADMIN_ALL;
GRANT 
CREATE ANY TABLE, DROP ANY TABLE, 
CREATE ANY VIEW, DROP ANY VIEW, 
CREATE ANY SEQUENCE, DROP ANY SEQUENCE,
CREATE ANY PROCEDURE, DROP ANY PROCEDURE,
CREATE ANY TRIGGER, DROP ANY TRIGGER,
CREATE ANY SYNONYM, DROP ANY SYNONYM
TO ROLE_ADMIN_ALL;

------------------------------------------------
-- ROL: AUDITOR (Rol de solo lectura para auditoría y revisión de datos)
------------------------------------------------
CREATE ROLE ROLE_AUDITOR_RO;
GRANT CONNECT TO ROLE_AUDITOR_RO;

------------------------------------------------
-- ROL: REPORTING (Rol de solo lectura para generación de informes y consultas analíticas)
------------------------------------------------
CREATE ROLE ROLE_REPORTING_RO;
GRANT CONNECT TO ROLE_REPORTING_RO;

------------------------------------------------
-- ROL: OPERACIONES COMUNES (Rol operativo para el backend bancario con permisos de lectura y escritura limitados)
------------------------------------------------
CREATE ROLE ROLE_APP_RW;
GRANT CONNECT, RESOURCE TO ROLE_APP_RW;

--******************************************************************************
-- CONFIGURACIÓN DE USUARIOS
--******************************************************************************

------------------------------------------------
-- USUARIO: CONFIGURACIÓN GLOBAL (Usuario para tablas de configuración y parámetros globales del sistema bancario)
------------------------------------------------
CREATE USER USR_CFG IDENTIFIED BY CFG123
DEFAULT TABLESPACE DATA_TBS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON DATA_TBS;
GRANT CONNECT, RESOURCE TO USR_CFG;

------------------------------------------------
-- USUARIO: INTEGRACIONES / STAGING (Usuario dedicado a procesos de integración y staging de datos con sistemas externos)
------------------------------------------------
CREATE USER USR_INTEGRACION IDENTIFIED BY INT123
DEFAULT TABLESPACE DATA_TBS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON DATA_TBS;
GRANT CONNECT, RESOURCE TO USR_INTEGRACION;

------------------------------------------------
-- USUARIO: BACKEND BANCARIO (Usuario principal del backend bancario, encargado de las operaciones de negocio)
------------------------------------------------
CREATE USER USR_BACKEND IDENTIFIED BY BACKEND123
DEFAULT TABLESPACE DATA_TBS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON DATA_TBS;
GRANT ROLE_APP_RW TO USR_BACKEND;

------------------------------------------------
-- USUARIO: REPORTING (Usuario dedicado a consultas y reporting de información consolidada)
------------------------------------------------
CREATE USER USR_REPORTING IDENTIFIED BY REPORT123
DEFAULT TABLESPACE DATA_TBS
TEMPORARY TABLESPACE TEMP
ACCOUNT UNLOCK;
GRANT ROLE_REPORTING_RO TO USR_REPORTING;

------------------------------------------------
-- USUARIO: AUDITORÍA (Usuario de auditoría, acceso de solo lectura para revisión de seguridad y trazabilidad)
------------------------------------------------
CREATE USER USR_AUDITOR IDENTIFIED BY AUDIT123
DEFAULT TABLESPACE DATA_TBS
TEMPORARY TABLESPACE TEMP
ACCOUNT UNLOCK;
GRANT ROLE_AUDITOR_RO TO USR_AUDITOR;

------------------------------------------------
-- USUARIO: ADMINISTRADOR (DBA)
------------------------------------------------
CREATE USER USR_ADMIN IDENTIFIED BY ADMIN123
DEFAULT TABLESPACE DATA_TBS
TEMPORARY TABLESPACE TEMP;
GRANT DBA TO USR_ADMIN;

------------------------------------------------
-- USUARIO: ENTORNO DE DESARROLLO / PRUEBAS (Usuario de desarrollo, utilizado para pruebas y creación de objetos no productivos)
------------------------------------------------
CREATE USER USR_DEV IDENTIFIED BY DEV123
DEFAULT TABLESPACE DATA_TBS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON DATA_TBS;
GRANT ROLE_APP_RW TO USR_DEV;
GRANT CREATE PROCEDURE, CREATE VIEW, CREATE SYNONYM TO USR_DEV;

-- NOTAS:
-- - "ACCOUNT UNLOCK" se aplica a usuarios de auditoría y reporting por conveniencia,
--   al tratarse de cuentas de solo lectura para acceso rápido.
-- - "QUOTA UNLIMITED ON" se aplica a usuarios con permisos de desarrollo o backend.
--   El resto, excepto el DBA, no tienen cuota asignada para mantener la seguridad.

-- ==========================================================
-- CONFIGURACIÓN DE AUDITORÍA GENERAL (A NIVEL DE SESIÓN)
-- ==========================================================

-- Auditar inicio y cierre de sesión de cualquier usuario.
AUDIT CREATE SESSION BY ACCESS;

-- Auditar operaciones de creación o eliminación de objetos (nivel básico).
AUDIT CREATE ANY TABLE BY ACCESS;
AUDIT DROP ANY TABLE BY ACCESS;

-- Auditar modificacion de usuarios.
AUDIT ALTER USER BY ACCESS;

-- Auditar privilegios.
AUDIT GRANT ANY PRIVILEGE BY ACCESS;

-- NOTA: Para que las auditorias puedan funcionar se debe verificar el parametro AUDIT TRAIL ON, por seguridad arriba manualmente se fuerza con el comando "ALTER SYSTEM SET AUDIT_TRAIL = DB, EXTENDED SCOPE = SPFILE;".

--******************************************************************************
-- CONFIGURACIÓN DE SEGURIDAD Y POLÍTICAS DE CONTRASEÑAS
--******************************************************************************

ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME 90; -- Vida maxima de la contraseña, 90 dias.
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS 5; -- Numero maximo de logins incorrectos, 5.
ALTER PROFILE DEFAULT LIMIT PASSWORD_VERIFY_FUNCTION ORA12C_VERIFY_FUNCTION; -- Formato de la contraseña. (SIMILAR A VERIFY_FUNCTION_11G).
ALTER PROFILE DEFAULT LIMIT PASSWORD_GRACE_TIME 5;  -- 5 días tras expirar antes de forzar cambio.
ALTER PROFILE DEFAULT LIMIT PASSWORD_REUSE_TIME 365;  -- No se puede reutilizar durante 1 año.
ALTER PROFILE DEFAULT LIMIT PASSWORD_REUSE_MAX 5;     -- No se puede reutilizar tras 5 contraseñas distintas.

-- NOTAS:
-- - LONGITUD mínima: 8 caracteres.
-- - Debe contener mayúsculas, minúsculas, números y símbolos.
-- - No puede coincidir con el nombre de usuario ni reutilizar contraseñas recientes.
-- - Se utiliza el perfil DEFAULT para establecer una configuración básica de seguridad.
--   En entornos profesionales se crearían perfiles separados por tipo de usuario.

-- ==========================================================
-- VERIFICACIÓN POSTERIOR.
-- ==========================================================
SELECT USERNAME, ACCOUNT_STATUS, DEFAULT_TABLESPACE, PROFILE, CREATED FROM DBA_USERS WHERE USERNAME LIKE 'USR_%'; -- Verificar usuarios creados.
SELECT ROLE, AUTHENTICATION_TYPE, COMMON FROM DBA_ROLES WHERE ROLE LIKE 'ROLE_%'; -- Verificar roles creados.
SELECT TABLESPACE_NAME, STATUS, CONTENTS, EXTENT_MANAGEMENT, ALLOCATION_TYPE FROM DBA_TABLESPACES; -- Verificar tablespaces creados.
SELECT GRANTEE AS USUARIO, GRANTED_ROLE AS ROL, DEFAULT_ROLE, ADMIN_OPTION FROM DBA_ROLE_PRIVS WHERE GRANTEE LIKE 'USR_%'; -- Verificar roles asignados a usuarios.
SELECT GRANTEE, PRIVILEGE FROM DBA_SYS_PRIVS WHERE GRANTEE LIKE 'USR_%'; -- Verificar privilegios del sistema.
SELECT USERNAME, TABLESPACE_NAME, MAX_BYTES/1024/1024 AS MAX_MB FROM DBA_TS_QUOTAS WHERE USERNAME LIKE 'USR_%'; -- Verificar cuotas de tablespaces por usuario. (Util para verificar el parametro "QUOTA UNLIMITED").
SELECT USERNAME, ACTION_NAME, PRIV_USED, RETURNCODE FROM DBA_AUDIT_TRAIL WHERE USERNAME LIKE 'USR_%'; -- Verificar auditorías. (SOLO SI "AUDIT TRAIL ON"). Activado manualmente al inicio con parametro: "ALTER SYSTEM SET AUDIT_TRAIL = DB, EXTENDED SCOPE = SPFILE;".
SELECT * FROM DBA_PROFILES WHERE RESOURCE_NAME LIKE 'PASSWORD%' AND PROFILE = 'DEFAULT'; -- Verificar politica de contraseñas para perfil usado DEFAULT.

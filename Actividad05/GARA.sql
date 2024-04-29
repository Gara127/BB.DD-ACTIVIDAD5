
-- EJERCICIO TEMA 9 --
-- EJERCICIO 3--
-- 2.	Añade un nuevo tablespace llamado bd_tunombre con un tamaño de 100 MB.  El fichero se llamará bdtunombre.dbf--

CREATE TABLESPACE bd_gara 
DATAFILE 'C:\Oracle\sqldeveloper-23.1.0.097.1607-x64\bdgara.dbf'
SIZE 100M 
AUTOEXTEND ON; 
-- Comprobamos que se ha creado--
SELECT * 
FROM DBA_TABLESPACES;

--4.Añade 100 MB al tablespace anterior. --

ALTER DATABASE
DATAFILE 'C:\Oracle\sqldeveloper-23.1.0.097.1607-x64\bdgara.dbf'
RESIZE 200M;

-- Comprobamos modificación--
SELECT * FROM DBA_TABLESPACES;

-- 6.Añade 200 MB al tablespace en un fichero llamado bdtunombre-extra.dbf --

ALTER TABLESPACE bd_gara
ADD DATAFILE 'C:\Oracle\sqldeveloper-23.1.0.097.1607-x64\bdgara-extra.dbf' 
SIZE 200M 
AUTOEXTEND ON;

-- Comprobamos con la vista --
SELECT * FROM DBA_DATA_FILES 
WHERE TABLESPACE_NAME='BD_GARA'; 

--  7.Muestra el tamaño total del tablespace bd_tunombre. --

SELECT tablespace_name, sum(bytes)total
FROM dba_data_files
WHERE TABLESPACE_NAME='BD_GARA'
GROUP BY tablespace_name;

-- 8. CAPTURA EN EL WORD --

--9.	Borra el tablespace creado. --

DROP TABLESPACE bd_gara INCLUDING CONTENTS AND DATAFILES;

--10. Lista los tablespaces existentes. --

SELECT *
FROM DBA_TABLESPACES;

-- EJERCICIOS TEMA 10 --
DROP TABLESPACE TBL_tareas INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBL_tareas 
DATAFILE 'C:\Oracle\sqldeveloper-23.1.0.097.1607-x64\bdgara.dbf'
SIZE 200M 
AUTOEXTEND ON;

-- Comprobamos-- 
SELECT tablespace_name, sum(bytes)tama?o
FROM dba_data_files
GROUP BY tablespace_name;

-- 2.	Crea un usuario llamado “supervisor” que tenga todos los privilegios en el sistema Oracle. Asigna el rol dba a este usuario. --
ALTER SESSION SET "_ORACLE_SCRIPT"=true;
                     
CREATE USER supervisor
IDENTIFIED BY "1234" 
DEFAULT TABLESPACE TBL_tareas; 

DROP USER supervisor CASCADE;

GRANT DBA TO supervisor;
-- Comprobamos que se encuentra creado --
SELECT * FROM DBA_USERS;

--3.	Crearemos una tabla llamada tareas para ir guardando todas aquellas que se van asignado.--

CREATE TABLE tareas(
    codigo varchar2(6) primary key,
    nombre varchar2(30) not null,
    descripcion varchar2(200) not null,
    usuario varchar2 (30) not null,
    fecha date not null,
    realizada varchar2(1) CHECK (realizada IN ('S', 'N')) not null,
    horas number not null
)tablespace TBL_tareas;

-- Consultamos --
SELECT * FROM USER_TABLES; 
SELECT OWNER,TABLESPACE_NAME FROM ALL_TABLES WHERE TABLE_NAME= 'TAREAS'; 

-- añadimos 5 registros --
DROP TABLE tareas;

INSERT INTO tareas (codigo, nombre, descripcion, usuario, fecha, realizada, horas)
VALUES ('001', 'Revisar correos', 'Clasificar correos clientes', 'Kathy', TO_DATE('02/03/2023', 'DD/MM/YYYY'), 'S', 8);

INSERT INTO tareas (codigo, nombre, descripcion, usuario, fecha, realizada, horas)
VALUES ('002', 'Presentar demandas', 'Comprobar documentacion y hacer escrito', 'Emely', TO_DATE('03/07/2023', 'DD/MM/YYYY'), 'S', 8);

INSERT INTO tareas (codigo, nombre, descripcion, usuario, fecha, realizada, horas)
VALUES ('003', 'Presentacion comunicacion', 'Revision documentos', 'Alicia', TO_DATE('15/06/2023', 'DD/MM/YYYY'), 'N', 7.5);

INSERT INTO tareas (codigo, nombre, descripcion, usuario, fecha, realizada, horas)
VALUES ('004', 'Realizar facturacion', 'Gestiones con departamento facturacion', 'Gara', TO_DATE('11/10/2023', 'DD/MM/YYYY'), 'N', 9);

INSERT INTO tareas (codigo, nombre, descripcion, usuario, fecha, realizada, horas)
VALUES ('005', 'Coger telefono', 'Sin definir', 'Carmen R', TO_DATE('09/07/2023', 'DD/MM/YYYY'), 'N', 1);

SELECT * FROM tareas;

--4 Crea los siguientes usuarios --

-- a.	Usuario gestor --
DROP USER gestor CASCADE;                       

CREATE USER gestor
IDENTIFIED BY "1234" 
DEFAULT TABLESPACE TBL_tareas; 

-- Comprobamos--
SELECT * FROM DBA_USERS;

GRANT ALL PRIVILEGES TO gestor;
-- Comprobamos--
SELECT * FROM DBA_SYS_PRIVS WHERE GRANTEE = 'GESTOR';

-- b.	Usuario administrativo?. --
DROP USER administrativo CASCADE;

CREATE USER administrativo
IDENTIFIED BY "1234" 
DEFAULT TABLESPACE TBL_tareas; 

-- Comprobamos--
SELECT * FROM DBA_USERS WHERE USERNAME = 'ADMINISTRATIVO'; 

GRANT SELECT, INSERT, UPDATE ON tareas TO administrativo;
-- Comprobamos --
SELECT * FROM DBA_TAB_PRIVS WHERE GRANTEE = 'ADMINISTRATIVO'; 

-- c.	Usuario tecnico. --
DROP USER tecnico CASCADE;
                          
CREATE USER tecnico
IDENTIFIED BY "1234"
DEFAULT TABLESPACE TBL_tareas; 

-- Comprobamos--
SELECT * FROM DBA_USERS WHERE USERNAME = 'TECNICO';

GRANT SELECT, INSERT, UPDATE (realizada, horas) ON tareas TO tecnico;
-- Comprobamos --
SELECT * FROM DBA_TAB_PRIVS WHERE GRANTEE = 'TECNICO';  

--5 hecho en cada ejercicio--

-- 6.	Quita el permiso de insertar en la tabla de tareas al usuario t?cnico. --

REVOKE INSERT ON tareas 
FROM tecnico;

-- Comprobamo--
SELECT * FROM DBA_TAB_PRIVS WHERE GRANTEE = 'TECNICO';

-- 7.Crea un rol llamado roltareas que pueda iniciar una sesi?n interactiva en el entorno de Oracle y pueda leer solo los datos de la tabla tareas. --

CREATE ROLE roltareas;
GRANT CREATE SESSION TO roltareas;
GRANT SELECT ON tareas TO roltareas;

-- Comprobamos roll--
SELECT * FROM DBA_ROLES WHERE ROLE = 'ROLTAREAS';
-- Comprobamos privilegios --
SELECT * FROM DBA_SYS_PRIVS WHERE grantee = 'ROLTAREAS'; 
SELECT * FROM DBA_TAB_PRIVS WHERE TABLE_NAME = 'TAREAS'; 

-- 8.	Crea un usuario con tu nombre y le asignas el roltareas --

CREATE USER gara
IDENTIFIED BY "1234"
DEFAULT TABLESPACE TBL_tareas; 

GRANT roltareas
TO gara;

-- Comprobamos--
SELECT * FROM DBA_USERS WHERE USERNAME = 'GARA';
SELECT * FROM DBA_ROLE_PRIVS WHERE GRANTEE = 'GARA';


-- 9.Crea un perfil de usuario llamado perfiltareas que tenga un tiempo m?ximo de conexi?n de 30 minutos, tres conexiones simult?neas y que le obligue a cambiar la contrase?a cada 30 d?as. Asigna el perfil al usuario con tu nombre. --

CREATE PROFILE perfiltareas LIMIT
CONNECT_TIME 30 
SESSIONS_PER_USER 3 
PASSWORD_LIFE_TIME 30; 

ALTER USER gara
PROFILE perfiltareas;

-- Comprobamos--
SELECT * FROM DBA_PROFILES WHERE PROFILE = 'PERFILTAREAS';
SELECT * FROM DBA_USERS WHERE USERNAME = 'GARA';

-- 10.Borra el perfil, los usuarios, el rol y el tablespace junto con sus datos --

ALTER USER gara 
PROFILE DEFAULT; 
DROP PROFILE perfiltareas;


DROP USER gara CASCADE;
DROP USER gestor CASCADE;
DROP USER administrativo CASCADE;
DROP USER tecnico CASCADE;
DROP USER supervisor CASCADE;                  

DROP ROLE roltareas;

DROP TABLESPACE TBL_tareas INCLUDING CONTENTS AND DATAFILES;

-- Comprobamos--
SELECT tablespace_name, sum(bytes)tama?o
FROM dba_data_files
GROUP BY tablespace_name;

SELECT * FROM DBA_USERS;
SELECT * FROM USER_TABLES; 
SELECT OWNER,TABLESPACE_NAME FROM ALL_TABLES WHERE TABLE_NAME= 'TAREAS';
SELECT * FROM DBA_USERS WHERE USERNAME = 'ADMINISTRATIVO';
SELECT * FROM DBA_TAB_PRIVS WHERE GRANTEE = 'ADMINISTRATIVO';
SELECT * FROM DBA_ROLES WHERE ROLE = 'ROLTAREAS';
SELECT * FROM DBA_USERS WHERE USERNAME = 'GARA';
SELECT * FROM DBA_ROLE_PRIVS WHERE GRANTEE = 'GARA';
SELECT * FROM DBA_PROFILES WHERE PROFILE = 'PERFILTAREAS';
SELECT * FROM DBA_USERS WHERE USERNAME = 'GARA';

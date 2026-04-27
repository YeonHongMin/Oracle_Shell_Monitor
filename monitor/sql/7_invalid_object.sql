set feedback off
set linesize 132
set pagesize 100

col "Con"           format 9999
col "Owner"         format a20
col "Object name"   format a50
col "Last DDL Time" format a19

SELECT con_id     "Con"
 , owner          "OWNER"
 , object_type    "Object type"
 , object_name    "Object name"
 , status         "Status"
 , to_char(last_ddl_time, 'YYYY-MM-DD HH24:MI:SS') "Last DDL Time"
FROM cdb_objects
WHERE status = 'INVALID'
AND object_type != 'SYNONYM'
ORDER BY con_id, owner, object_type, object_name, status
/

exit


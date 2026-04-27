set feedback off
set linesize 132
set pagesize 100

col "Con"   format 9999
col "OWNER" format a20

SELECT con_id   "Con"
 , owner        "OWNER"
 , object_type  "OBJECT_TYPE"
 , count(*)     "COUNT"
FROM cdb_objects
GROUP BY con_id, owner, object_type
ORDER BY con_id, owner, object_type
/

exit


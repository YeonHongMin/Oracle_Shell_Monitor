set feedback off
set linesize 132
set pagesize 100

col "Con"   format 9999
col "Owner" format a20

SELECT con_id   "Con"
 , owner        "Owner"
 , object_type  "Object type"
 , status       "Status"
 , count(*)     "Count"
FROM cdb_objects
WHERE status = 'INVALID'
GROUP BY con_id, owner, object_type, status
ORDER BY con_id, owner, object_type, status
/

exit


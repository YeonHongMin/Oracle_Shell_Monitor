set feedback off
set linesize 150
set pagesize 50

col "Owner"     format a15
col "Sid"       format 9999
col "Object"    format a40
col "Type"      format a15
col "Lock_type" format a16

select sid    "Sid"
     , owner  "Owner"
     , object "Object"
     , type   "Type"
     , 'Library Cache Lock' "Lock_type"
from   v$access
where  sid in (select sid from v$lock where type in ('OD','LB'))
   or  sid in (select session_id from dba_ddl_locks)
   and owner not in ('SYS','SYSTEM','SYSAUX')
order  by 1,2,3
/

exit

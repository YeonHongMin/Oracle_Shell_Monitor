set feedback off
set linesize 150
set pagesize 100
col "Inst-Sid-Path" format a60
col "Con"           format 9999

select path "Inst-Sid-Path"
     , type
     , id1
     , id2
     , lmode
     , request
     , con_id "Con"
from (
  select substr(sys_connect_by_path('('||inst_id||')'||sid, '/'), 2) path
       , level lev
       , l.*
  from   gv$lock l
  start  with lmode > 0 and request = 0
  connect by prior type    = type
         and prior id1     = id1
         and prior id2     = id2
         and prior request != request
         and request > 0
         and level   < 3
) t
where lev = 2
order by type, path
/

exit

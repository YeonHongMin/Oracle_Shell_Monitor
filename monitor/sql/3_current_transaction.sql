set feedback off
set linesize 200

col "SID"        format 999999
col "User"       format a15
col "OBJ"        format a35
col "Status"     format a8
col "Used_blk"   format 999,999,999
col "Usn"        format 99999
col "Time"       format a10
col "[SQL_ID]Text" format a60

select 0 "SID"
     , '[Total : '||count(*)||']' "User"
     , null "OBJ"
     , null "Status"
     , 0    "Usn"
     , 0    "Used_blk"
     , null "Time"
     , null "[SQL_ID]Text"
from   v$transaction
union all
select distinct
       vs.sid
     , decode(va.type,'INDEX',' --> INDEX : ',vs.username)
     , va.owner||'.'||va.object
     , vs.status
     , vt.xidusn
     , vt.used_ublk
     , floor((sysdate - vt.start_date)*24) || ':'||
       lpad(floor(mod((sysdate - vt.start_date)*1440, 60)),2,0) || ':'||
       lpad(floor(mod((sysdate - vt.start_date)*86400, 60)),2,0)
     , '['||nvl(vs.sql_id, vs.prev_sql_id)||'] '||vst.sql_text
from   v$session     vs
     , v$transaction vt
     , (select sql_id, sql_text from v$sqltext where piece=0) vst
     , v$access      va
where  vs.taddr = vt.addr
  and  va.sid   = vs.sid
  and  nvl(vs.sql_id, vs.prev_sql_id) = vst.sql_id(+)
order  by "Time", "SID", "User" desc
/

exit

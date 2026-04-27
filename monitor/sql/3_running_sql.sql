set linesize 200
set pagesize 200
set feedback off

col sid       format 99999
col username  format a15
col piece     format 99999
col "Type"    format a10
col "SQL"     format a120
col "Con"     format 9999

select vs.sid, vs.username, vst.piece, vs.type "Type", vst.sql_text "SQL", vs.con_id "Con"
from   v$session vs, v$sqltext vst
where  vs.sql_id = vst.sql_id
  and  vs.sid    <> sys_context('USERENV','SID')
  and  vs.status = 'ACTIVE'
  and  vs.type   = 'USER'
order  by vs.sid, vst.piece
/

exit

set linesize 150
set feedback off

col tablespace_name format a18
col "SQL Type"      format a15
col "Con"           format 9999
@@sqlid_format.sql

select vs.sid
     , vs.serial#
     , dr.segment_id
     , c.command_name      "SQL Type"
     , nvl(vs.sql_id, vs.prev_sql_id) sql_id
     , dr.tablespace_name
     , vt.used_ublk
     , vr.curext
     , vr.xacts
     , vs.con_id           "Con"
from   cdb_rollback_segs dr
     , v$rollstat vr
     , v$transaction vt
     , v$session vs
     , v$sqlcommand c
where  dr.segment_id = vr.usn
  and  vr.usn        = vt.xidusn
  and  vt.addr       = vs.taddr
  and  vs.command    = c.command_type(+)
order  by vs.con_id, vs.sid
/

exit

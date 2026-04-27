set feedback off
set linesize 150
set pagesize 50

col "User"      format a15
col "Sid"       format 9999
col "Object"    format a40
col "Status"    format a10
col "Lock_time" format a12
col "Lock mode" format a16
col "Con"       format 9999
@@sqlid_format.sql

select s.sid                                           "Sid"
     , s.status                                        "Status"
     , s.username                                      "User"
     , o.owner||'.'||o.object_name                     "Object"
     , floor((sysdate - vt.start_date)*24)            ||':'||
       lpad(floor(mod((sysdate - vt.start_date)*1440, 60)),2,0)||':'||
       lpad(floor(mod((sysdate - vt.start_date)*86400,60)),2,0) "Lock_time"
     , decode(l.lmode, 0,'[0] None',1,'[1] Null',2,'[2] Row-S',
                       3,'[3] Row-X',4,'[4] Share',5,'[5] S/Row-X',6,'[6] Exclusive',
                       to_char(l.lmode))               "Lock mode"
     , nvl(s.sql_id, s.prev_sql_id)                    "SQL_ID"
     , s.con_id                                        "Con"
from   v$lock l
     , v$session s
     , cdb_objects o
     , v$transaction vt
where  l.type    in ('TM','TX')
  and  l.sid     = s.sid
  and  s.taddr   = vt.addr(+)
  and  l.id1     = o.object_id(+)
  and  s.con_id  = o.con_id(+)
order  by "Lock_time" desc
/

exit

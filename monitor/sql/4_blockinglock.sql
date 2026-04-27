set feedback off
set linesize 150
set pagesize 50

col "Blocking User" format a15
col "Waiting User"  format a15
col "Blocking Sid"  format 999999999
col "Waiting Sid"   format 999999999
col "Lock Type"     format a12
col "Holding mode"  format a16
col "Request mode"  format a16
@@sqlid_format.sql

select bs.username "Blocking User"
     , ws.username "Waiting User"
     , bs.sid      "Blocking Sid"
     , ws.sid      "Waiting Sid"
     , wk.type     "Lock Type"
     , decode(hk.lmode, 0,'[0] None',1,'[1] Null',2,'[2] Row-S',
                        3,'[3] Row-X',4,'[4] Share',5,'[5] S/Row-X',6,'[6] Exclusive',
                        to_char(hk.lmode)) "Holding mode"
     , decode(wk.request, 0,'[0] None',1,'[1] Null',2,'[2] Row-S',
                        3,'[3] Row-X',4,'[4] Share',5,'[5] S/Row-X',6,'[6] Exclusive',
                        to_char(wk.request)) "Request mode"
     , nvl(bs.sql_id, bs.prev_sql_id) "SQL_ID"
from   v$lock hk
     , v$session bs
     , v$lock wk
     , v$session ws
where  wk.request > 0
  and  hk.lmode   > 0
  and  wk.type    = hk.type
  and  wk.id1     = hk.id1
  and  wk.id2     = hk.id2
  and  wk.sid     = ws.sid
  and  hk.sid     = bs.sid
  and  bs.sid    != ws.sid
order  by 1,3
/

exit

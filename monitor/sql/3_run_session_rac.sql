set lines 240
set pagesize 1000
set feedback off

col "Inst_ID"    format 999999
col "Sid,Serial" format a13
col "Username"   format a15
col "Status"     format a10
col "Machine"    format a20
col "Logon_Time" format a20
col "Program"    format a25
col "Client_Pid" format a16
col "Con"        format 9999
@@sqlid_format.sql

select s.inst_id                                       "Inst_ID"
     , s.sid || ',' || s.serial#                       "Sid,Serial"
     , s.username                                      "Username"
     , s.status                                        "Status"
     , substr(s.machine, 1, 20)                        "Machine"
     , to_char(s.logon_time,'yyyy/mm/dd hh24:mi:ss')   "Logon_Time"
     , substr(s.program, 1, 25)                        "Program"
     , nvl(s.sql_id, s.prev_sql_id)                    "SQL_ID"
     , substr(s.process, 1, 16)                        "Client_Pid"
     , s.con_id                                        "Con"
from   gv$session s
where  s.status = 'ACTIVE'
  and  s.type   = 'USER'
order  by s.inst_id, s.sid
/

exit

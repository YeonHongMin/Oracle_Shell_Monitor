set lines 240
set pagesize 1000
set feedback off

col "Sid,Serial" format a13
col "Username"   format a15
col "Status"     format a10
col "Machine"    format a20
col "Logon_Time" format a20
col "Program"    format a25
col "PGA(KB)"    format 999,999
col "Block_Sess" format a10
col "Client_Pid" format a16
col "Server_Pid" format a16
col "Con"        format 9999
@@sqlid_format.sql

select * from
(
 select s.sid || ',' || s.serial#                       "Sid,Serial"
      , s.username                                      "Username"
      , s.status                                        "Status"
      , substr(s.machine, 1, 20)                        "Machine"
      , to_char(s.logon_time,'yyyy/mm/dd hh24:mi:ss')   "Logon_Time"
      , substr(s.program, 1, 25)                        "Program"
      , round(p.pga_used_mem/1024)                      "PGA(KB)"
      , nvl(to_char(s.blocking_session), '.')           "Block_Sess"
      , nvl(s.sql_id, s.prev_sql_id)                    "SQL_ID"
      , substr(s.process, 1, 16)                        "Client_Pid"
      , substr(p.spid, 1, 16)                           "Server_Pid"
      , s.con_id                                        "Con"
 from   v$session s, v$process p
 where  s.paddr = p.addr
 order  by 1,5
)
union all
select '[Run: '||sum(decode(status,'ACTIVE',cnt,0))||']'
     , '[Tot: '||sum(cnt)||']'
     , null,null,null,null,null,null,null,null,null,null
from (
   select status, count(*) cnt
   from   v$session
   group  by status
) t
/

exit

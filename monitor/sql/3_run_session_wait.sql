set lines 200
set pagesize 1000
set feedback off
col "Sid,Serial"   format a13
col "Status"       format a10
col "Username"     format a12
col "Program"      format a20
col "PGA(MB)"      format 999,999.99
col "Block_Sess"   format a10
col "SQL"          format a8
col "Wait_Event"   format a30
col "Object_Name"  format a25
col "W_Time(s)"    format 999,999
col "Con"          format 9999
@@sqlid_format.sql

select s.sid || ',' || s.serial#                            "Sid,Serial"
     , s.username                                           "Username"
     , s.status                                             "Status"
     , substr(s.program, 1, 20)                             "Program"
     , round(p.pga_used_mem/1024/1024,2)                    "PGA(MB)"
     , nvl(s.sql_id, s.prev_sql_id)                         "SQL_ID"
     , c.command_name                                       "SQL"
     , nvl(to_char(s.blocking_session), '.')                "Block_Sess"
     , substr(s.event, 1, 30)                               "Wait_Event"
     , substr(o.owner||'.'||o.object_name, 1, 25)            "Object_Name"
     , s.seconds_in_wait                                    "W_Time(s)"
     , s.con_id                                             "Con"
from   v$session s
left  join v$process p     on s.paddr = p.addr
left  join v$sqlcommand c  on s.command = c.command_type
left  join cdb_objects o   on s.row_wait_obj# = o.object_id and s.con_id = o.con_id
where  s.status = 'ACTIVE'
  and  s.type   = 'USER'
order  by 1
/

exit

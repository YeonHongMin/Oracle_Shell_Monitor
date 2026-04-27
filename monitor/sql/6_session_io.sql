set linesize 150
set pagesize 100
set feedback off

col "User"    format a15
col "Program" format a25
col "Sid"     format 999999
col "Con"     format 9999
col block_gets         format 999,999,999
col consistent_gets    format 999,999,999
col physical_reads     format 999,999,999
col block_changes      format 999,999,999
col consistent_changes format 999,999,999

select s.sid           "Sid"
     , s.username      "User"
     , substr(s.program, 1, 25) "Program"
     , si.block_gets
     , si.consistent_gets
     , si.physical_reads
     , si.block_changes
     , si.consistent_changes
     , s.con_id        "Con"
from   v$session s, v$sess_io si
where  s.sid = si.sid
  and  s.type = 'USER'
order  by s.con_id, s.username, s.sid
/

exit

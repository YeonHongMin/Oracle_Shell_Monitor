set linesize 200
set pagesize 1000
set feedback off

col "User"            format a15
col "Machine"         format a20
col "Program"         format a25
col "PID"             format a16
col "Event"           format a35
col "Wait Sec"  format 9,999,999
col "Wait_Time" format 9,999,999
col "State"     format a18

select vsw.sid                    "SID"
     , substr(vs.process, 1, 16)  "PID"
     , vs.username                "User"
     , substr(vsw.event, 1, 35)   "Event"
     , vsw.state                  "State"
     , vsw.wait_time              "Wait_Time"
     , vsw.seconds_in_wait        "Wait Sec"
     , substr(vs.program, 1, 25)  "Program"
     , substr(vs.machine, 1, 20)  "Machine"
from   v$session vs, v$session_wait vsw
where  vs.sid = vsw.sid
  and  vsw.wait_class != 'Idle'
order  by vsw.seconds_in_wait desc
/

exit

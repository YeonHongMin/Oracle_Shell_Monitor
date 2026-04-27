set linesize 150
set feedback off
set pagesize 60

col event          format a45
col total_waits    format 999,999,999
col total_timeouts format 999,999,999
col time_waited    format 9,999,999,999
col average_wait   format 999,999,999.99
col avg_wait_ms    format 9,999,999.99
col "Con"          format 9999

select "Con", event, time_waited, total_waits, total_timeouts, average_wait, avg_wait_ms
from   (
  select con_id "Con"
       , event
       , total_waits
       , total_timeouts
       , time_waited
       , average_wait
       , round(time_waited_micro/decode(total_waits,0,1,total_waits)/1000, 2) avg_wait_ms
  from   v$system_event
  where  wait_class != 'Idle'
  order  by time_waited desc, total_waits desc, event
)
where  rownum < 30
/

exit

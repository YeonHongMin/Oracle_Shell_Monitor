set linesize 150
set feedback off
set pagesize 60

prompt
prompt === Background Process Activity (Top wait class) ===
prompt

col event           format a40
col wait_class      format a18
col total_waits     format 999,999,999,999
col time_waited_sec format 999,999,999.99
col "Con"           format 9999

select * from
(
  select con_id "Con"
       , event
       , wait_class
       , total_waits
       , round(time_waited/100, 2) time_waited_sec
  from   v$system_event
  where  wait_class != 'Idle'
  order  by time_waited desc
)
where rownum < 40
/

exit

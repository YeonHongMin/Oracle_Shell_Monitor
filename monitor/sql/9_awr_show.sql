set serveroutput on
set feedback off
set verify off
set linesize 150
set pagesize 100

col instance_number format 999
col instance_name   format a25
col startup_time    format a20
col begin_interval_time format a22
col end_interval_time   format a22

select instance_number
     , instance_name
     , to_char(startup_time, 'YYYY/MM/DD HH24:MI:SS') startup_time
from   v$instance
/

accept last_day char prompt 'Enter the number of days of snapshots : '

select instance_number
     , snap_id
     , to_char(begin_interval_time, 'YYYY/MM/DD HH24:MI:SS') begin_interval_time
     , to_char(end_interval_time,   'YYYY/MM/DD HH24:MI:SS') end_interval_time
from   dba_hist_snapshot
where  begin_interval_time >= sysdate - &last_day
order  by 1, 2 asc
/

exit

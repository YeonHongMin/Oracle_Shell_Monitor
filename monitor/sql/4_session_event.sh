#!/bin/sh
##### Create Session Event Select Query #####
echo -n "Enter Session ID (ex: 9,10,12) : "
read SESSION_ID

cat > "$MONITOR/sql/4_session_event.sql" <<EOF
!echo
!echo Selected Session ID : ${SESSION_ID}

set feedback off
set linesize 150
set pagesize 60
col event          format a45
col total_waits    format 999,999,999
col total_timeouts format 999,999,999
col time_waited    format 999,999,999
col average_wait   format 999,999,999.99
col max_wait       format 9,999,999
col "Con"          format 9999

select sid
     , event
     , total_waits
     , total_timeouts
     , time_waited
     , average_wait
     , max_wait
     , con_id "Con"
from   v\$session_event
where  sid in ( ${SESSION_ID} )
  and  time_waited > 0
order  by 1, time_waited desc
/
exit
EOF

exit 0

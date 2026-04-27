#!/bin/sh
### Background Monitoring Start ###
### nohup mon.sh >> mon.log & ###

TIME=${1:-60}

DB_USER=${DB_USER:-system}
DB_PASS=${DB_PASS:-manager}
DB_ROLE=${DB_ROLE:-}
if [ -n "$DB_ROLE" ] ; then
  DB_CONN="${DB_USER}/${DB_PASS} as ${DB_ROLE}"
else
  DB_CONN="${DB_USER}/${DB_PASS}"
fi

while :
do
  date '+[%Y/%m/%d %H:%M:%S]'
  echo "------ RTPC(Real Time Process Checker) ---------------------------------------"
  echo "USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND"
  ps aeuwg | grep -E "ora_|oracle" | grep -v "grep|ps|sh|sed" | sort -n -r -k 6 | head -n 50 | cut -c1-120

  echo " "
  echo "------ RTSC(Real Time Storage Checker) ---------------------------------------"
  df -k

  echo " "
  echo "------ RTVC(Real Time VMSTAT Checker) ----------------------------------------"
  vmstat

  echo " "
  echo "------ RTSC(Real Time Session Checker) ---------------------------------------"

  sqlplus -s -L "$DB_CONN" <<EOF
set feedback off
set linesize 180
set pagesize 100

select '[' || to_char(sysdate,'yyyy/mm/dd hh24:mi:ss') || ']' as "Current Time"
     , round(sum(p.pga_used_mem)/1024/1024, 2) as "PGA Used(MB)"
     , count(*)                                as "Server Process Count"
from   v\$process p
where  p.pga_used_mem <> 0;

col username format a15
col program  format a30
col status   format a8
col machine  format a20
col spid     format a12
col "PGA(MB)" format 999,990.99

select s.username
     , substr(s.program, 1, 30) "PROGRAM"
     , s.status
     , substr(s.machine, 1, 20) "MACHINE"
     , p.spid
     , round(p.pga_used_mem/1024/1024, 2) "PGA(MB)"
from   v\$session s, v\$process p
where  s.paddr = p.addr
  and  s.type  = 'USER'
order by p.pga_used_mem desc nulls last
fetch first 30 rows only;

exit
EOF

  echo " "
  echo "------ INTERVAL = $TIME -----------------------------------------------------"
  sleep $TIME
done

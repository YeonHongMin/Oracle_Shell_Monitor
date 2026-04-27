#!/bin/sh
### Background Monitoring Start ###
### nohup ha_mon.sh >> ha_mon.log & ###

TIME=${1:-10}

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
  clear
  date '+[%Y/%m/%d %H:%M:%S]'
  echo ""
  echo "[Disk Mount]"
  df -h | grep -v Filesystem | wc -l

  echo ""
  echo "[Oracle Process Count]"
  ps -ef | grep -E "ora_|oracle$ORACLE_SID" | grep -v grep | wc -l

  echo ""
  echo "[Oracle Sessions]"
  sqlplus -s -L "$DB_CONN" <<EOF
set feedback off
set linesize 120
set pagesize 200
col username format a15
col program  format a30
col "COUNT"  format 999,999

select username
     , substr(program, 1, 30) program
     , count(*) "COUNT"
from   v\$session
group  by username, substr(program, 1, 30)
order  by 3 desc;

exit
EOF
  sleep $TIME
done

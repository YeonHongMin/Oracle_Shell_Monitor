#!/bin/sh

if [ -n "$MONITOR_HOME" ] ; then
  MONITOR=$MONITOR_HOME
else
  MONITOR=`dirname "$0"`
fi
export MONITOR

DB_USER=${DB_USER:-system}
DB_PASS=${DB_PASS:-manager}
DB_ROLE=${DB_ROLE:-}
if [ -n "$DB_ROLE" ] ; then
  DB_CONN="${DB_USER}/${DB_PASS} as ${DB_ROLE}"
else
  DB_CONN="${DB_USER}/${DB_PASS}"
fi
SQL_HOME=$MONITOR/sql

DML_FIND()
{
  clear
  echo "------------------------------------------------------------------"
  echo "Search date input....."
  echo "(input date format -> YYYYMMDDHH24MISS)"
  echo
  echo -n "start date : "; read i_sdate
  echo -n "end date   : "; read i_edate
  echo "------------------------------------------------------------------"

  sqlplus -s -L "$DB_CONN" <<EOF
set linesize 200
set pagesize 200
alter session set nls_date_format='YYYYMMDDHH24MISS';
col sql_id           format a30
col first_load_time  format a20
col last_active_time format a20

select B.sql_id || '/' || B.child_number    as sql_id
     , (select command_name from v\$sqlcommand where command_type = B.command_type) as command_type
     , C.first_load_time
     , to_char(C.last_active_time, 'YYYYMMDDHH24MISS') last_active_time
     , C.elapsed_time
from
   ( select hash_value, sql_id, child_number from v\$sql
     group by hash_value, sql_id, child_number ) A
 , ( select hash_value, sql_id, child_number, command_type from v\$sql
     group by hash_value, sql_id, child_number, command_type ) B
 , ( select sql_id, hash_value, first_load_time, last_active_time, elapsed_time from v\$sqlarea ) C
where A.hash_value     = B.hash_value
  and A.sql_id         = B.sql_id
  and A.child_number   = B.child_number
  and A.sql_id         = C.sql_id
  and A.hash_value     = C.hash_value
  and C.first_load_time             >= '$i_sdate'
  and to_char(C.last_active_time,'YYYYMMDDHH24MISS') <= '$i_edate'
;

EOF

  read tmp || exit 0
}

while true
do
  clear
  echo
  echo "------------------------------------------------------------------"
  echo "1. DML Search"
  echo "2. DML Query View (SQL Plan)"
  echo "x. EXIT"
  echo "------------------------------------------------------------------"
  echo -n " Choose the Number or Command : "
  read i_number || exit 0

  case $i_number in
    1) DML_FIND ;;
    2) clear
       echo "=========="
       echo " SQL PLAN "
       echo "=========="
       sqlplus -s -L "$DB_CONN" @"$SQL_HOME/8_sql_plan.sql"
       read tmp || exit 0 ;;
    x|X) clear; echo "Good bye..."; echo; exit ;;
  esac
done

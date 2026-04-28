#!/bin/sh

print_done(){
  echo "Refresh interval : $1 (sec)"
}

tam_stop(){
  echo -n "Input X key and press ENTER key to exit : "

  INPUT=`sh -c '(sleep $INTERVAL ; kill $$) > /dev/null &
    trap exit 15
    read r_var
    kill $!
    echo $r_var
    ' 2> /dev/null`

  if [ "$INPUT" = "X" -o "$INPUT" = "x" ] ; then
    exit 0
  fi
}

run_sql(){
  sqlplus -s -L "$DB_CONN" @"$MONITOR/sql/$1"
  echo
}

ensure_sqlid_format(){
  echo "column sql_id format a13" > "$MONITOR/sql/sqlid_format.sql"
}

# Configuration ---------------------------------------------------------------
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
export DB_CONN

ensure_sqlid_format

# Argument check --------------------------------------------------------------
if [ $# -ne 2 ] ; then
  echo
  echo "Usage : $0 <Option> <Interval>"
  echo
  echo "   Option     Description                        "
  echo "   --------   -----------------------------------"
  echo "   redowait   redo wait statistics               "
  echo "   runsess    current active session             "
  echo "   session    current session                    "
  echo "   sessio     session i/o information            "
  echo "   sessevent  session event information          "
  echo "   sevent     system event statistics            "
  echo "   spin       latch statistics                   "
  echo "   swait      current session wait information   "
  echo "   sysstat    sysstat information                "
  echo "   topwait    top wait events                    "
  echo "   tempseg    temp segment usage                 "
  echo "   tran       current transaction                "
  echo
  exit 101
fi

OPTION=$1; export OPTION
INTERVAL=$2; export INTERVAL

# Numeric interval check
r_int=`echo $INTERVAL | tr -d '[0-9]'`
if [ -n "$r_int" ]; then
  echo "ERROR : Interval must be numeric"
  exit 102
fi

case $OPTION in
  redowait) loop_sql=4_redonowait.sql;        title="Redo Nowait Information" ;;
  runsess)  loop_sql=3_run_session_wait.sql;  title="Current Active Session (with wait)" ;;
  session)  loop_sql=3_current_session.sql;   title="Current Session Information" ;;
  sessio)   loop_sql=6_session_io.sql;        title="Session I/O Information" ;;
  sessevent)
            sh "$MONITOR/sql/4_session_event.sh"
            loop_sql=4_session_event.sql;     title="Session Event Information" ;;
  sevent)   loop_sql=4_system_event.sql;      title="System Event Information" ;;
  spin)     loop_sql=2_latch.sql;             title="Latch Information" ;;
  swait)    loop_sql=4_session_wait.sql;      title="Session Wait Information" ;;
  sysstat)  loop_sql=4_sysstat.sql;           title="Sysstat Information" ;;
  topwait)  loop_sql=4_jcnt.sql;              title="Top Wait Events" ;;
  tempseg)  loop_sql=5_tempseg_usage.sql;     title="Tempseg Usage Information" ;;
  tran)     loop_sql=3_current_transaction.sql; title="Current Transaction Information" ;;
  *)        echo; echo "You chose wrong option."; echo "Try Again..."; sleep 1; exit 1 ;;
esac

while true
do
  clear
  echo "$title"
  printf '%*s\n' "${#title}" '' | tr ' ' '='
  uptime
  run_sql "$loop_sql"
  print_done $INTERVAL
  tam_stop $INTERVAL
done

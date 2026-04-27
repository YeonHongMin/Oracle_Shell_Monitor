#!/bin/sh
###########################
# Build Monitor Save File #
###########################

if [ -n "$MONITOR_HOME" ] ; then
  MONITOR=$MONITOR_HOME
elif [ -z "$MONITOR" ] ; then
  # called from monitor menu, $MONITOR is already exported
  MONITOR=`dirname "$0"`/..
fi
export MONITOR

SQL_DIR=$MONITOR/sql
SAVE_FILE=$MONITOR/sql/0_save_file.sql
TEMP_FILE=$MONITOR/sql/0_save_file_temp.sql

mkdir -p "$MONITOR/log"
echo "column sql_id format a13" > "$SQL_DIR/sqlid_format.sql"

cat > "$SAVE_FILE" <<EOF
prompt ==========================
prompt  Oracle Monitoring Report
prompt ==========================
!date

EOF

append_section(){
  echo                              >> "$SAVE_FILE"
  echo "-- $1"                      >> "$SAVE_FILE"
  echo                              >> "$SAVE_FILE"
  shift
  for f in "$@" ; do
    if [ -f "$SQL_DIR/$f" ] ; then
      cat "$SQL_DIR/$f"             >> "$SAVE_FILE"
    fi
  done
}

append_section "1.GENERAL"          1_instance.sql 1_parameter.sql 1_sga.sql 1_used_memory.sql 1_backup_status.sql
append_section "2.SHARED MEMORY"    2_bchr.sql 2_sharedcache.sql 2_latch.sql
append_section "3.SESSION"          3_current_session.sql 3_run_session.sql 3_run_session_wait.sql 3_running_sql.sql 3_current_transaction.sql 3_open_cursor.sql
append_section "4.WAIT EVENT/LOCK"  4_blockinglock.sql 4_hierarchical_lock.sql 4_lockinfo.sql 4_lockobj.sql 4_system_event.sql 4_session_event_all.sql 4_session_wait.sql 4_sysstat.sql 4_jcnt.sql 4_redonowait.sql
append_section "5.SPACE"            5_control.sql 5_logfile.sql 5_datafile.sql 5_tablespace.sql 5_temp_tablespace.sql 5_undo.sql 5_undo_usage_type.sql 5_tempseg_usage.sql 5_tempseg_tot_usage.sql
append_section "6.I/O"              6_fileio.sql 6_session_io.sql 6_loghistory.sql
append_section "7.OBJECT"           7_object_count.sql 7_invalid_count.sql 7_invalid_object.sql 7_segment_size.sql
append_section "8.SQL"              8_topquery.sql 8_check_static_query.sql

# Strip per-section "exit" so the whole file runs in one sqlplus invocation,
# then add a single trailing exit.
grep -v -w "exit" "$SAVE_FILE" > "$TEMP_FILE"
echo                         >> "$TEMP_FILE"
echo "exit"                  >> "$TEMP_FILE"
mv "$TEMP_FILE" "$SAVE_FILE"

set linesize 200
set pagesize 200
set verify off
set feedback off

column "Gets/Exec"     format 999,999,999
column "Elap/Exec(ms)" format 999,999,999.99
column sql_text        format a200
column sql_id          format a25
column "Con"           format 9999

accept v_sql_id    char prompt 'INPUT SQL_ID                  : '
accept v_child_no  char prompt 'INPUT CHILD NUMBER (default 0): '

prompt
prompt ===== SQL Info =====================================================================================
select sql_id, child_number, hash_value, plan_hash_value,
       decode(executions, 0, -1, round(buffer_gets/executions, 3))       "Gets/Exec",
       decode(executions, 0, -1, round(elapsed_time/executions/1000, 3)) "Elap/Exec(ms)",
       executions,
       rows_processed,
       con_id "Con"
from   v$sql
where  sql_id       = '&v_sql_id'
   and child_number = nvl(to_number(nullif('&v_child_no','')), 0)
/

prompt
prompt ===== SQL TEXT =====================================================================================
select sql_text from v$sqltext where sql_id = '&v_sql_id' order by piece;

prompt
prompt ===== DBMS_XPLAN.DISPLAY_CURSOR ====================================================================
select * from table(
  dbms_xplan.display_cursor(
    sql_id          => '&v_sql_id',
    cursor_child_no => nvl(to_number(nullif('&v_child_no','')), 0),
    format          => 'ALLSTATS LAST'
  )
);

exit

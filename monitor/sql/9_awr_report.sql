set termout on
set feedback off
set linesize 200
set pagesize 50000
set heading off
set verify off
set trimspool on
set echo off
set long 100000

accept m_begin char prompt 'Enter begin snapshot ID : '
accept m_end   char prompt 'Enter end snapshot ID   : '

column rpt_name new_value rpt_name noprint
column dbid     new_value dbid     noprint
column instn    new_value instn    noprint

select 'awrrpt_'||to_char(sysdate,'YYYYMMDDHH24MISS')||'_&m_begin._&m_end..txt' rpt_name
     , (select dbid from v$database) dbid
     , (select instance_number from v$instance) instn
from   dual
/

prompt Spooling to &rpt_name

spool &rpt_name

select output
from   table(dbms_workload_repository.awr_report_text(&dbid, &instn, &m_begin, &m_end))
/

spool off

prompt Report saved to: &rpt_name

exit

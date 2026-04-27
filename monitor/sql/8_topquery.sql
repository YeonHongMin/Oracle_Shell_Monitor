set linesize 180
set feedback off

col USERNAME format a20
col MODULE   format a30
col "Elapsed_Time(s)" format 999,999,999.999
col "Elap/Exec(s)"    format 999,999.999
col "Gets/Exec"       format 999,999,999.999
col EXECUTIONS        format 999,999,999
col BUFFER_GETS       format 999,999,999,999

@@sqlid_format.sql

prompt
prompt ========  Top 10 SQL Ordered by Elapsed Time =========

select * from
(
   select (select username from all_users where user_id = parsing_user_id) username
        , round(elapsed_time/1000000, 3)                            "Elapsed_Time(s)"
        , executions
        , decode(executions, 0, -1, round(buffer_gets/executions, 3)) "Gets/Exec"
        , decode(executions, 0, -1, round(elapsed_time/executions/1000000, 3)) "Elap/Exec(s)"
        , substr(module, 1, 30) module
        , sql_id
   from   v$sqlarea
   where  elapsed_time > 0 and executions > 0
   order  by 2 desc
) where rownum <= 10
/

prompt
prompt ========  Top 10 SQL Ordered by Buffer Gets =========

select * from
(
   select (select username from all_users where user_id = parsing_user_id) username
        , buffer_gets
        , executions
        , decode(executions, 0, -1, round(buffer_gets/executions, 3)) "Gets/Exec"
        , round(elapsed_time/1000000, 3) "Elapsed_Time(s)"
        , substr(module, 1, 30) module
        , sql_id
   from   v$sqlarea
   where  elapsed_time > 0 and executions > 0
   order  by 2 desc
) where rownum <= 10
/

prompt
prompt ========  Top 10 SQL Ordered by Elap/Exec(s) =========

select * from
(
   select (select username from all_users where user_id = parsing_user_id) username
        , decode(executions, 0, -1, round(elapsed_time/executions/1000000, 3)) "Elap/Exec(s)"
        , executions
        , decode(executions, 0, -1, round(buffer_gets/executions, 3))          "Gets/Exec"
        , round(elapsed_time/1000000, 3) "Elapsed_Time(s)"
        , substr(module, 1, 30) module
        , sql_id
   from   v$sqlarea
   where  elapsed_time > 0 and executions > 0
   order  by 2 desc
) where rownum <= 10
/

exit

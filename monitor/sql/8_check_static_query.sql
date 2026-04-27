set lines 180
set pages 120
set feedback off
col pattern_no  format a12
col sql_pattern format a45
col cnt         format 999,999
col "Con"       format 9999
@@sqlid_format.sql

select 'Pattern #' || lpad(row_number() over(order by cnt desc), 3, '0') pattern_no
     , sql_id, sql_pattern, cnt, con_id "Con"
from (
   select substr(sql_text, 1, 40) sql_pattern
        , min(sql_id)             sql_id
        , count(*)                cnt
        , con_id
   from   v$sqlarea
   group  by substr(sql_text, 1, 40), con_id
   having count(*) > 5
)
order by cnt desc
/

exit

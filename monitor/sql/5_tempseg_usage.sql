set feedback off
set linesize 200
set pagesize 100

col username  format a15
col segtype   format a15
col sql_text  format a90

select tempseg.session_num            sid
     , tempseg.username
     , tempseg.sql_id
     , tempseg.segtype
     , round((tempseg.blocks*pt.value)/1024/1024, 2) "TEMP(MB)"
     , vst.sql_text
from (
       select session_num, username, sql_id, segtype, sum(blocks) blocks
       from   v$tempseg_usage
       group  by session_num, username, sql_id, segtype
     ) tempseg
   , (select sql_id, sql_text from v$sqltext where piece=0) vst
   , (select value from v$parameter where name='db_block_size') pt
where  tempseg.sql_id = vst.sql_id(+)
order  by sid
/

exit

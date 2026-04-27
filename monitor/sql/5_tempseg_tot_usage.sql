set feedback off
set linesize 150
set pagesize 100

col "Con"       format 9999
col "Temp Name" format a20
col "Total(MB)" format 999,999,999.99
col "Used(MB)"  format 999,999,999.99
col "Free(MB)"  format 999,999,999.99
col "Free(%)"   format 999.99
col "Max(MB)"   format 999,999,999.99

select con        "Con"
     , temp_name  "Temp Name"
     , tot        "Total(MB)"
     , use        "Used(MB)"
     , tot-use    "Free(MB)"
     , decode(tot,0,0,round((tot-use)/tot*100, 1)) "Free(%)"
     , ma         "Max(MB)"
from (
   select tf.con_id                                         con
        , tf.tablespace_name                                temp_name
        , round(tf.bytes/1024/1024, 2)                      tot
        , nvl2(tu.blocks, round((tu.blocks*pt.value)/1024/1024, 2), 0) use
        , round(tf.maxbytes/1024/1024, 2)                   ma
   from   (select con_id, tablespace_name, sum(bytes) bytes, sum(maxbytes) maxbytes
           from   cdb_temp_files
           group  by con_id, tablespace_name) tf
        , (select con_id, tablespace, sum(blocks) blocks
           from   v$tempseg_usage
           group  by con_id, tablespace) tu
        , (select value from v$parameter where name='db_block_size') pt
   where  tf.tablespace_name = tu.tablespace(+)
     and  tf.con_id = tu.con_id(+)
)
order  by 1, 2
/

exit

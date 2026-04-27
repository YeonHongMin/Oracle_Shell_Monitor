set linesize 150
set pagesize 100
set feedback off

col tablespace_name format a18
col "Con"           format 9999

prompt
prompt =================================
prompt =====   Undo Freespace    =======
prompt =================================

select  ddf.con_id                                           "Con"
      , ddf.tablespace_name                                  "TABLESPACE_NAME"
      , round(ddf.bytes/1024/1024, 2)                        "TOTAL_SIZE(MB)"
      , round((ddf.bytes - nvl(dfs.bytes,0))/1024/1024, 2)   "USED_SIZE(MB)"
      , round(nvl(dfs.bytes,0)/1024/1024, 2)                 "FREE_SIZE(MB)"
      , round((nvl(dfs.bytes,0)/ddf.bytes) * 100, 2)         "FREE_SIZE(%)"
from   (select con_id, tablespace_name, sum(bytes) bytes
        from   cdb_data_files
        where  (con_id, tablespace_name) in
               (select con_id, tablespace_name from cdb_tablespaces where contents='UNDO')
        group by con_id, tablespace_name) ddf
     , (select con_id, tablespace_name, sum(bytes) bytes
        from   cdb_free_space
        group by con_id, tablespace_name) dfs
where  ddf.tablespace_name = dfs.tablespace_name(+)
  and  ddf.con_id          = dfs.con_id(+)
order  by ddf.con_id, ddf.tablespace_name
/

prompt
prompt =================================
prompt =====  Undo Segment Info  =======
prompt =================================

col status format a10

select dr.con_id "Con"
     , dr.segment_id
     , dr.tablespace_name
     , dr.status
     , vr.extents
     , round(vr.rssize/1024/1024, 1) "RSSIZE(MB)"
     , vr.curext
     , vr.shrinks
     , vr.wraps
     , vr.extends
     , vr.xacts
from   cdb_rollback_segs dr, v$rollstat vr
where  dr.segment_id = vr.usn
  and  dr.con_id     = vr.con_id
order  by dr.con_id, vr.rssize desc, dr.segment_id
/

col "Undoseg Activity" format a30

select con_id "Con", 'Online Undosegs Cnt' "Undoseg Activity", count(*) "COUNT"
from   v$rollstat
group  by con_id
union all
select con_id, 'Active Undosegs Cnt', count(*)
from   v$rollstat
where  xacts > 0
group  by con_id
order  by 1, 2
/

prompt
prompt =================================
prompt ===== Necessary Undo Size =======
prompt =================================

col "Current UNDO SIZE(MB)"   format 999,999.99
col "UNDO RETENTION(s)"       format a17
col "Necessary UNDO SIZE(MB)" format 999,999.99

select d.con_id "Con"
     , d.name "TABLESPACE_NAME"
     , d.undo_size/1024/1024 "Current UNDO SIZE(MB)"
     , e.value               "UNDO RETENTION(s)"
     , round((to_number(e.value) * to_number(f.value) * g.undo_block_per_sec) / (1024*1024), 2)
                             "Necessary UNDO SIZE(MB)"
from (
       select vt.con_id, vt.ts#, vt.name
            , (select sum(bytes) from cdb_data_files
               where tablespace_name = vt.name and con_id = vt.con_id) undo_size
       from   v$tablespace vt
       where  (vt.con_id, vt.name) in
              (select con_id, tablespace_name from cdb_tablespaces where contents='UNDO')
     ) d
   , v$parameter e
   , v$parameter f
   , (
       select con_id, undotsn
            , max(undoblks/decode((end_time-begin_time)*3600*24,0,1,(end_time-begin_time)*3600*24)) undo_block_per_sec
       from   gv$undostat
       group  by con_id, undotsn
     ) g
where e.name = 'undo_retention'
  and f.name = 'db_block_size'
  and d.ts#    = g.undotsn(+)
  and d.con_id = g.con_id(+)
order by d.con_id, d.name
/

exit

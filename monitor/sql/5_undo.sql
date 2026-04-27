set linesize 150
set pagesize 100
set feedback off

col tablespace_name format a18

prompt
prompt =================================
prompt =====   Undo Freespace    =======
prompt =================================

select  ddf.tablespace_name                                  "TABLESPACE_NAME"
      , round(ddf.bytes/1024/1024, 2)                        "TOTAL_SIZE(MB)"
      , round((ddf.bytes - nvl(dfs.bytes,0))/1024/1024, 2)   "USED_SIZE(MB)"
      , round(nvl(dfs.bytes,0)/1024/1024, 2)                 "FREE_SIZE(MB)"
      , round((nvl(dfs.bytes,0)/ddf.bytes) * 100, 2)         "FREE_SIZE(%)"
from   (select tablespace_name, sum(bytes) bytes
        from   dba_data_files
        where  tablespace_name in (select tablespace_name from dba_tablespaces where contents='UNDO')
        group by tablespace_name) ddf
     , (select tablespace_name, sum(bytes) bytes
        from   dba_free_space
        group by tablespace_name) dfs
where  ddf.tablespace_name = dfs.tablespace_name(+)
/

prompt
prompt =================================
prompt =====  Undo Segment Info  =======
prompt =================================

col status format a10

select dr.segment_id
     , dr.tablespace_name
     , dr.status
     , vr.extents
     , round(vr.rssize/1024/1024, 1) "RSSIZE(MB)"
     , vr.curext
     , vr.shrinks
     , vr.wraps
     , vr.extends
     , vr.xacts
from   dba_rollback_segs dr, v$rollstat vr
where  dr.segment_id = vr.usn
order  by 5, 1
/

col "Undoseg Activity" format a30

select 'Online Undosegs Cnt' "Undoseg Activity", count(*) "COUNT" from v$rollstat
union all
select 'Active Undosegs Cnt', count(*) from v$rollstat where xacts > 0
/

prompt
prompt =================================
prompt ===== Necessary Undo Size =======
prompt =================================

select d.name "TABLESPACE_NAME"
     , d.undo_size/1024/1024 "Current UNDO SIZE(MB)"
     , e.value               "UNDO RETENTION(s)"
     , round((to_number(e.value) * to_number(f.value) * g.undo_block_per_sec) / (1024*1024), 2)
                             "Necessary UNDO SIZE(MB)"
from (
       select ts#, name
            , (select sum(bytes) from dba_data_files where tablespace_name = vt.name) undo_size
       from   v$tablespace vt
       where  vt.name in (select tablespace_name from dba_tablespaces where contents='UNDO')
     ) d
   , v$parameter e
   , v$parameter f
   , (
       select undotsn, max(undoblks/decode((end_time-begin_time)*3600*24,0,1,(end_time-begin_time)*3600*24)) undo_block_per_sec
       from   gv$undostat
       group  by undotsn
     ) g
where e.name = 'undo_retention'
  and f.name = 'db_block_size'
  and d.ts# = g.undotsn(+)
/

exit

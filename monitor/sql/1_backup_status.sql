set linesize 220
set pagesize 100
set feedback on

col "Input Type"   format a15
col "Status"       format a25
col "Start Time"   format a20
col "End Time"     format a20
col "Elapsed"      format a14
col "Input"        format a12
col "Output"       format a12
col "Device"       format a12
col "Backup Type"  format a12
col "Pieces"       format 999,990
col "Completion Time" format a20
col "Handle"       format a90
col "Deleted"      format a8
col "Tablespace Name" format a20
col "Datafile"     format a80
col "Backup Mode"  format a12
col "Con"          format 9999

prompt
prompt ===== RMAN Backup Job History (recent 30) =====

select *
from (
  select input_type                         "Input Type"
       , status                             "Status"
       , to_char(start_time, 'YYYY/MM/DD HH24:MI:SS') "Start Time"
       , to_char(end_time,   'YYYY/MM/DD HH24:MI:SS') "End Time"
       , time_taken_display                 "Elapsed"
       , input_bytes_display                "Input"
       , output_bytes_display               "Output"
       , output_device_type                 "Device"
  from   v$rman_backup_job_details
  order  by start_time desc nulls last
)
where rownum <= 30
/

prompt
prompt ===== RMAN Backup Sets (recent 30) =====

select *
from (
  select decode(backup_type, 'D', 'FULL/DATAFILE',
                            'I', 'INCREMENTAL',
                            'L', 'ARCHIVELOG',
                            backup_type) "Backup Type"
       , incremental_level
       , pieces "Pieces"
       , to_char(start_time,      'YYYY/MM/DD HH24:MI:SS') "Start Time"
       , to_char(completion_time, 'YYYY/MM/DD HH24:MI:SS') "Completion Time"
       , round(elapsed_seconds/60, 2) "Elapsed Min"
       , keep
  from   v$backup_set
  order  by completion_time desc nulls last
)
where rownum <= 30
/

prompt
prompt ===== RMAN Backup Pieces (recent 30) =====

select *
from (
  select device_type "Device"
       , status      "Status"
       , deleted     "Deleted"
       , round(bytes/1024/1024/1024, 2) "GB"
       , to_char(completion_time, 'YYYY/MM/DD HH24:MI:SS') "Completion Time"
       , handle      "Handle"
  from   v$backup_piece
  order  by completion_time desc nulls last
)
where rownum <= 30
/

prompt
prompt ===== Datafile Backup Mode Status =====

select a.con_id          "Con"
     , a.tablespace_name "Tablespace Name"
     , a.file_name       "Datafile"
     , b.status          "Backup Mode"
     , to_char(b.time, 'YYYY/MM/DD HH24:MI:SS') "Start Time"
from   cdb_data_files a
     , v$backup b
where  a.file_id = b.file#
order  by a.con_id, a.tablespace_name, a.file_name
/

exit

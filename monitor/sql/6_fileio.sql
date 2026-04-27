set lines 200
set pagesize 60
set feedback off

col tablespace_name format a18
col file_name       format a60
col phyrds          format 999,999,999
col phywrts         format 999,999,999
col "Read(%)"       format 999.9
col "Write(%)"      format 999.9
col "Total_IO(%)"   format 999.9
col "AvgRd(ms)"     format 9999.99
col "AvgWr(ms)"     format 9999.99

select fl.tablespace_name
     , df.name file_name
     , fs.phyrds
     , fs.phywrts
     , round((fs.phyrds /decode(tot.rds,0,1,tot.rds))*100, 1) "Read(%)"
     , round((fs.phywrts/decode(tot.wrts,0,1,tot.wrts))*100, 1) "Write(%)"
     , round((fs.phyrds+fs.phywrts)/decode(tot.rds+tot.wrts,0,1,tot.rds+tot.wrts)*100, 1) "Total_IO(%)"
     , round(fs.readtim *10/decode(fs.phyrds,0,1,fs.phyrds), 2)  "AvgRd(ms)"
     , round(fs.writetim*10/decode(fs.phywrts,0,1,fs.phywrts), 2) "AvgWr(ms)"
from   v$datafile df
     , v$filestat fs
     , dba_data_files fl
     , (select sum(phyrds) rds, sum(phywrts) wrts from v$filestat) tot
where  df.file# = fs.file#
  and  df.file# = fl.file_id
order  by 1,2
/

exit

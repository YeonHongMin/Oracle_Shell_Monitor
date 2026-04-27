set feedback off
set linesize 150
set pagesize 100

col "Con"             format 9999
col "Tablespace Name" format a20
col "Bytes(MB)"       format 999,999,999
col "Used(MB)"        format 999,999,999
col "Percent(%)"      format 9999999.99
col "Free(MB)"        format 999,999,999
col "Free(%)"         format 9999.99
col "MaxBytes(MB)"       format 999,999,999

SELECT ddf.con_id "Con",
       ddf.tablespace_name "Tablespace Name",
       ddf.bytes/1024/1024 "Bytes(MB)",
       (ddf.bytes - dfs.bytes)/1024/1024 "Used(MB)",
       round(((ddf.bytes - dfs.bytes) / ddf.bytes) * 100, 2) "Percent(%)",
       dfs.bytes/1024/1024 "Free(MB)",
       round((1 - ((ddf.bytes - dfs.bytes) / ddf.bytes)) * 100, 2) "Free(%)",
       ROUND(ddf.MAXBYTES / 1024/1024,2) "MaxBytes(MB)"
FROM
 (SELECT con_id, tablespace_name, sum(bytes) bytes, sum(maxbytes) maxbytes
   FROM   cdb_data_files
   GROUP BY con_id, tablespace_name) ddf,
 (SELECT con_id, tablespace_name, sum(bytes) bytes
   FROM   cdb_free_space
   GROUP BY con_id, tablespace_name) dfs
WHERE ddf.tablespace_name = dfs.tablespace_name
  AND ddf.con_id = dfs.con_id
ORDER BY ddf.con_id, ((ddf.bytes-dfs.bytes)/ddf.bytes) DESC
/

exit


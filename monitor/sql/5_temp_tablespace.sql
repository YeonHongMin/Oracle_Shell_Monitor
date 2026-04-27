set linesize 130
set feedback off

col "Con"             format 9999
col "Tablespace Name" format a20
col "Size(MB)"        format 999,9999,999.99
col "MaxSize(MB)"     format 999,9999,999.99

SELECT con_id "Con",
       tablespace_name "Tablespace Name",
       SUM(bytes)/1024/1024 "Size(MB)",
       SUM(maxbytes)/1024/1024 "MaxSize(MB)"
FROM cdb_temp_files
GROUP BY con_id, tablespace_name
ORDER BY 1, 2
/

exit


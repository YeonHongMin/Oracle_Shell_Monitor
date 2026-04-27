set linesize 150
set pagesize 120
set feedback off

col "Con"             format 9999
col "Owner"           format a20
col "Segment Name"    format a30
col "Segment Type"    format a18
col "Tablespace Name" format a20
col "Extents"         format 999,999,999
col "Size(MB)"        format 999,999,999.99

select con_id           "Con"
     , owner            "Owner"
     , segment_name     "Segment Name"
     , segment_type     "Segment Type"
     , tablespace_name  "Tablespace Name"
     , extents          "Extents"
     , round(bytes/1024/1024, 2) "Size(MB)"
from (
   select con_id, owner, segment_name, segment_type, tablespace_name, extents, bytes
   from   cdb_segments
   where  owner not in ('SYS','SYSTEM','SYSAUX','OUTLN','DBSNMP','APPQOSSYS',
                        'AUDSYS','GSMADMIN_INTERNAL','XDB','WMSYS','OJVMSYS',
                        'CTXSYS','MDSYS','OLAPSYS','ORDSYS','ORDDATA','ORDPLUGINS',
                        'LBACSYS','DVSYS','DVF','PUBLIC','REMOTE_SCHEDULER_AGENT')
   order  by bytes desc
)
where rownum <= 50
/

exit

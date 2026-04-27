set feedback off
set linesize 180
set pagesize 100

col "Instance Name"  format a15
col "Database Name"  format a15
col "Status"         format a12
col "Log Mode"       format a13
col "DB Create Time" format a20
col "DB Uptime"      format a15
col "Version"        format a80
col "NLS Character"  format a25

prompt
prompt ===== Instance / Database =====

select i.instance_name "Instance Name"
     , d.name "Database Name"
     , d.open_mode "Status"
     , d.log_mode "Log Mode"
     , to_char(d.created,'YYYY/MM/DD HH24:MI:SS') "DB Create Time"
     , floor(xx)||'d '||floor((xx-floor(xx))*24)||'h '||
       floor( ((xx - floor(xx))*24 - floor((xx-floor(xx))*24) )*60 )||'m' as "DB Uptime"
from v$database d
   , (select instance_name, (sysdate-startup_time) xx from v$instance) i
/

prompt
prompt ===== Version / Character Set =====

select v.banner "Version"
     , c.cc "NLS Character"
from (select banner from v$version where rownum=1) v
   , (select listagg(value, '/') within group (order by parameter) cc
        from nls_database_parameters
        where parameter in ('NLS_CHARACTERSET','NLS_NCHAR_CHARACTERSET')) c
/

exit

set linesize 180
set pagesize 100
set feedback on

col name          format a45
col "Size(MB)"    format 999,999,990.99
col "Value"       format a35

prompt
prompt ===== Memory Target / Usage =====

select name
     , round(value/1024/1024, 2) "Size(MB)"
from   v$parameter
where  name in ('memory_target','memory_max_target',
                'sga_target','sga_max_size',
                'pga_aggregate_target','pga_aggregate_limit')
union all
select 'SGA(Total)'      , round(sum(value)/1024/1024, 2) from v$sga
union all
select 'PGA(Allocated)'  , round(value/1024/1024, 2)
from   v$pgastat where name = 'total PGA allocated'
union all
select 'PGA(Used/Inuse)' , round(value/1024/1024, 2)
from   v$pgastat where name = 'total PGA inuse'
union all
select 'PGA(Max Allocated)' , round(value/1024/1024, 2)
from   v$pgastat where name = 'maximum PGA allocated'
/

prompt
prompt ===== PGA Statistics =====

select name
     , case
         when unit = 'bytes' then to_char(round(value/1024/1024, 2)) || ' MB'
         else to_char(value) || ' ' || unit
       end "Value"
from   v$pgastat
order  by name
/

exit

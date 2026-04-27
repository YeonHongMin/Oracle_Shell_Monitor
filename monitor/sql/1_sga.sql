set linesize 180
set pagesize 100
set feedback on

col name         format a35
col value        format a22
col component    format a35
col resizeable   format a10
col "Size(MB)"   format 999,999,990.99
col "Min(MB)"    format 999,999,990.99
col "Max(MB)"    format 999,999,990.99
col "User(MB)"   format 999,999,990.99
col "Granule(MB)" format 999,999,990.99

prompt
prompt ===== SGA Summary =====

select name
     , round(value/1024/1024, 2) "Size(MB)"
from   v$sga
order  by name
/

prompt
prompt ===== SGA Info =====

select name
     , round(bytes/1024/1024, 2) "Size(MB)"
     , resizeable
from   v$sgainfo
order  by name
/

prompt
prompt ===== Dynamic SGA Components =====

select component
     , round(current_size/1024/1024, 2)       "Size(MB)"
     , round(min_size/1024/1024, 2)           "Min(MB)"
     , round(max_size/1024/1024, 2)           "Max(MB)"
     , round(user_specified_size/1024/1024, 2) "User(MB)"
     , oper_count
     , last_oper_type
     , last_oper_mode
     , round(granule_size/1024/1024, 2)       "Granule(MB)"
from   v$sga_dynamic_components
order  by current_size desc, component
/

prompt
prompt ===== Memory Parameters =====

select name
     , case
         when name = 'db_block_size' then value || ' bytes'
         else round(to_number(value)/1024/1024, 2) || ' MB'
       end value
from   v$parameter
where  name in ('memory_target', 'memory_max_target',
                'sga_target', 'sga_max_size',
                'pga_aggregate_target', 'pga_aggregate_limit',
                'db_block_size')
order  by name
/

exit

set feedback off
set linesize 100
set pagesize 100

col "Parameter Name" format a45
col "Value"          format a45

select name "Parameter Name", value "Value"
from   v$parameter
where  isdefault = 'FALSE'
   or  name in ('optimizer_mode','memory_target','sga_target','pga_aggregate_target',
                'undo_retention','processes','sessions')
order  by name
/

exit

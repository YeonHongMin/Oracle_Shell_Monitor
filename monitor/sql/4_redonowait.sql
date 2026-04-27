set linesize 110
set feedback off

col "Con" format 9999

select  rent.con_id        "Con"
      , rent.value         "Redo entries"
      , nvl(rlsr.value, 0) "Redo space requests"
      , round(100*(1 - nvl(rlsr.value,0)/decode(rent.value,0,1,rent.value)), 2) "Redo NoWait %"
from   (select con_id, value from v$sysstat where name = 'redo entries') rent
left join (select con_id, value from v$sysstat where name = 'redo log space requests') rlsr
  on rent.con_id = rlsr.con_id
order  by rent.con_id
/

exit

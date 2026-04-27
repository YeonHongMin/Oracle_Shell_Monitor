set linesize 100
set feedback off

select  rent "Redo entries"
      , rlsr "Redo space requests"
      , round(100*(1 - rlsr/decode(rent,0,1,rent)), 2) "Redo NoWait %"
from   (select value rlsr from v$sysstat where name = 'redo log space requests')
     , (select value rent from v$sysstat where name = 'redo entries')
/

exit

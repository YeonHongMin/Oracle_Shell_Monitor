set feedback off
set linesize 150
set pagesize 100
col name format a35
col "Gets"           format 999,999,999,999
col "Misses"         format 999,999,999,999
col "Sleeps"         format 999,999,999
col "wait_time(s)"   format 999,999,999,999
col "Nowait Request" format 999,999,999,999

select name
     , gets   "Gets"
     , misses "Misses"
     , decode(gets, 0, -1, round((misses/gets)*100, 2))             "miss(%)"
     , sleeps "Sleeps"
     , decode(misses, 0, -1, round(sleeps/misses*100, 2))           "slps/miss(%)"
     , round(wait_time/1000000, 2)                                  "wait_time(s)"
     , immediate_gets+immediate_misses                              "Nowait Request"
     , decode(immediate_gets+immediate_misses, 0, -1,
              round(immediate_misses/(immediate_gets+immediate_misses)*100, 2))
                                                                    "Nowait Miss(%)"
from   v$latch
where  wait_time != 0
order  by 7 desc
/

exit

set linesize 140
set feedback off

col "Time" format a19
col "Con"  format 9999

select  "Con"
       ,to_char(sysdate,'yyyy/mm/dd hh24:mi:ss') "Time"
       ,"Physical read"
       ,"Logical read"
       ,"Hit"
       ,case when "Hit" > 90              then 'Good'
             when "Hit" between 70 and 90 then 'Average'
             else 'Not Good' end as "Status"
from
(
  select pr.con_id                          "Con"
       , pr.value                           "Physical read"
       , bg1.value + bg2.value              "Logical read"
       , round( (1 - pr.value / decode(bg1.value+bg2.value, 0, 1, bg1.value+bg2.value))
                * 100, 2)                   "Hit"
  from v$sysstat pr, v$sysstat bg1, v$sysstat bg2
  where pr.name   = 'physical reads'
    and bg1.name  = 'db block gets'
    and bg2.name  = 'consistent gets'
    and pr.con_id = bg1.con_id
    and bg1.con_id = bg2.con_id
  order by pr.con_id
)
/

exit

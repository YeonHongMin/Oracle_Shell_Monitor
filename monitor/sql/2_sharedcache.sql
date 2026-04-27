set linesize 140
set feedback off

col "Time" format a19
col "Name" format a25
col "Con"  format 9999

select con_id "Con"
     , to_char(sysdate,'yyyy/mm/dd hh24:mi:ss') as "Time"
     , 'SQL(Library) Cache' as "Name"
     , round(hit, 2) as "Hit(%)"
     , case when hit > 90              then 'Good'
            when hit between 70 and 90 then 'Average'
            else 'Not Good' end as "Status"
from   (select con_id, gethitratio*100 as hit
        from v$librarycache
        where namespace = 'SQL AREA')
union all
select con_id
     , to_char(sysdate,'yyyy/mm/dd hh24:mi:ss')
     , 'Dictionary Cache'
     , round(hit, 2)
     , case when hit > 90              then 'Good'
            when hit between 70 and 90 then 'Average'
            else 'Not Good' end
from   (select con_id
             , round((1 - sum(getmisses)/decode(sum(gets+getmisses),0,1,sum(gets+getmisses)))*100, 2) as hit
        from v$rowcache
        group by con_id)
order by 1, 3
/

col "Used(MB)"        format 999,999
col "Total(MB)"       format 999,999
col "Memory Usage(%)" format 999.99

select sp.con_id "Con"
     , to_char(sysdate,'yyyy/mm/dd hh24:mi:ss') as "Time"
     , 'Shared Pool Free Space'                 as "Name"
     , round((sp.bytes - nvl(free.bytes,0))/1024/1024) as "Used(MB)"
     , round(sp.bytes/1024/1024)                as "Total(MB)"
     , round(((sp.bytes - nvl(free.bytes,0))/sp.bytes)*100, 2) as "Memory Usage(%)"
from   (select con_id, sum(bytes) bytes from v$sgastat where pool = 'shared pool' group by con_id) sp
     , (select con_id, bytes from v$sgastat where pool = 'shared pool' and name = 'free memory') free
where  sp.con_id = free.con_id(+)
order  by sp.con_id
/

select tp.con_id "Con"
     , to_char(sysdate,'yyyy/mm/dd hh24:mi:ss') "Time"
     , round( (1 - hp.value/decode(tp.value,0,1,tp.value)) * 100, 2) "Soft Parse(%)"
from   v$sysstat tp, v$sysstat hp
where  tp.name    = 'parse count (total)'
  and  hp.name    = 'parse count (hard)'
  and  tp.con_id  = hp.con_id
order  by tp.con_id
/

exit

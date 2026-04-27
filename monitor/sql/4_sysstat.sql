set feedback off
set linesize 130
set pagesize 60

col statistic# format 9999
col name       format a55
col class      format 9999
col value      format 99,999,999,999,999

select * from
(
  select statistic#, name, class, value
  from   v$sysstat
  where  value > 0
  order  by value desc
)
where rownum < 40
/

exit

set feedback off
set linesize 130

col "COUNT" format 999,999
col "Con"   format 9999

select sid "SID", count(*) "COUNT", con_id "Con"
from v$open_cursor
group by sid, con_id
order by con_id, sid
/

exit

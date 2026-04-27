set serveroutput on
set feedback off
set linesize 150
set pagesize 100

declare
  v_snap_id number;
begin
  dbms_output.put_line('====== AWR snapshot create. ===========');
  dbms_output.put_line(to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS'));
  v_snap_id := dbms_workload_repository.create_snapshot();
  dbms_output.put_line('Snapshot ID = ' || v_snap_id);
  dbms_output.put_line('=======================================');
exception
  when others then
    dbms_output.put_line('AWR snapshot create failed: ' || sqlerrm);
end;
/

exit

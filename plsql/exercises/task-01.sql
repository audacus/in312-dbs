set serveroutput on

declare
    birthdate date := date '1996-02-18';
begin
    dbms_output.put_line(trunc(sysdate - birthdate));
end;
/
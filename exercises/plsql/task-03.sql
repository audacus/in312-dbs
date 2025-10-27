set serveroutput on

declare
    cursor anlass_cursor is
        select
            a.bezeichner,
            count(t.persid) teilnehmer
        from anlass a
        left join teilnehmer t on a.anlaid = t.anlaid
        group by
            a.anlaid,
            a.bezeichner;

    amount varchar(10);
begin
    for anlass in anlass_cursor loop
        if anlass.teilnehmer = 0 then
            amount := 'Keine';
        else
            amount := anlass.teilnehmer;
        end if;

        dbms_output.put_line(anlass.bezeichner || ': ' || amount || ' Teilnehmer');
    end loop;
end;
/
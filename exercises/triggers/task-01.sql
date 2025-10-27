-- log table
drop table log_spende;
create table log_spende(
    change_date date,
    change_user varchar(30),
    operation varchar(30),
    old_value varchar(1000) null,
    new_value varchar(1000) null
);

-- trigger
drop trigger track_spende;
create or replace trigger track_spende
    after insert or update or delete
    on spende
    referencing new as new_spende old as old_spende
    for each row
    declare
        operation varchar(10);
        old_value varchar(1000) := null;
        new_value varchar(1000) := null;
    begin
        -- operation
        if inserting then
            operation := 'insert';
        end if;
        if updating then
            operation := 'update';
        end if;
        if deleting then
            operation := 'delete';
        end if;

        -- old value
        if updating or deleting then
            old_value :=
                'spenid=' || :old_spende.spenid
                || ';bezeichner=' || :old_spende.bezeichner
                || ';datum=' || :old_spende.datum
                || ';betrag=' || :old_spende.betrag
                || ';sponid=' || :old_spende.sponid
                || ';anlaid=' || :old_spende.anlaid;
        end if;

        -- new value
        if inserting or updating then
            new_value :=
                'spenid=' || :new_spende.spenid
                || ';bezeichner=' || :new_spende.bezeichner
                || ';datum=' || :new_spende.datum
                || ';betrag=' || :new_spende.betrag
                || ';sponid=' || :new_spende.sponid
                || ';anlaid=' || :new_spende.anlaid;
        end if;

        insert into log_spende
        values (sysdate, user, operation, old_value, new_value);
    end;
/

-- fire trigger
insert into spende
    (spenid, bezeichner, datum, betrag, sponid, anlaid)
    values
    (999, 'test', date '2023-01-01', 1234, 1, 1);

update spende set bezeichner='blablabla' where spenid = 999;
delete from spende where spenid = 999;

-- show log
select * from log_spende

-- rollback
rollback;
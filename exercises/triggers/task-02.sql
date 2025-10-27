-- trigger
drop trigger is_person_active;
create or replace trigger is_person_active
    before insert
    on teilnehmer
    referencing new as new_teilnehmer
    for each row
    declare
        participations number;
        active_threshold number := 3;
        active_notes number;
        active_hint varchar(5) := 'aktiv';
    begin
        -- participations
        select count(*) into participations
            from teilnehmer
            where persid = :new_teilnehmer.persid;

        -- search for active hint on person
        select count(*) into active_notes
            from person
            where
                persid = :new_teilnehmer.persid
                and
                bemerkungen like '%' || active_hint || '%';

        -- if has enough participations and is not yet active...
        if
            participations >= active_threshold
            and
            active_notes = 0
        then
            -- add active hint
            update person
                set bemerkungen = bemerkungen || ' ' || active_hint
                where persid = :new_teilnehmer.persid;
        end if;
    end;
/

-- fire trigger
insert into teilnehmer (persid, anlaid) values (7, 1);
insert into teilnehmer (persid, anlaid) values (7, 2);
insert into teilnehmer (persid, anlaid) values (7, 3);
select count(*) participations from teilnehmer where persid = 7;
select bemerkungen from person where persid=7;
insert into teilnehmer (persid, anlaid) values (7, 4);
select count(*) participations from teilnehmer where persid = 7;
select bemerkungen from person where persid=7;
insert into teilnehmer (persid, anlaid) values (7, 5);
select count(*) participations from teilnehmer where persid = 7;
select bemerkungen from person where persid=7;


-- rollback
rollback;
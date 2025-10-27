-- trigger
drop trigger calculate_total_donations;
create or replace trigger calculate_total_donations
    after insert or update of betrag
    on spende
    referencing new as new_donation old as old_donation
    for each row
begin
    -- inserting
    if inserting then
        update sponsor
            set spendentotal = spendentotal + :new_donation.betrag
            where sponid = :new_donation.sponid;
    end if;
    -- updating
    if updating then
        update sponsor
            set spendentotal = spendentotal - :old_donation.betrag + :new_donation.betrag
            where sponid = :new_donation.sponid;
    end if;
end;
/

-- fire trigger
select * from sponsor where sponid = 1;
-- insert
insert into spende (spenid, bezeichner, datum, betrag, sponid) values (1001, 'tetst', sysdate, 100000, 1);
select * from sponsor where sponid = 1;
-- update
update spende set betrag = 200000 where spenid = 1001;
select * from sponsor where sponid = 1;

-- rollback
rollback;
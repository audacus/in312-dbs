-- cleanup
drop sequence eleven;
drop sequence thousand_up;

-- create
create sequence eleven start with 11 increment by 11;
create sequence thousand_up start with 1000 increment by 1;

-- debug
var next_eleven number;
var next_thousand_up number;

exec :next_eleven := eleven.nextval;
exec :next_thousand_up := thousand_up.nextval;

print :next_eleven
print :next_thousand_up

-- use
insert into anlass
    (anlaid, bezeichner, ort, datum, kosten, orgid)
values
    (:next_eleven, 'party hard', 'solothurn', current_date, 1000, 1);

insert into status
    (statid, bezeichner, beitrag)
values
    (:next_thousand_up, 'Premium', 99999);

-- delete
delete from anlass where anlaid = :next_eleven;
delete from status where statid = :next_thousand_up;
-- cleanup
drop sequence eleven_id;

-- create
create sequence eleven_id start with 11 increment by 11;

-- use
var next_eleven number;
exec :next_eleven := eleven_id.nextval;
print :next_eleven

insert into anlass
    (anlaid, bezeichner, ort, datum, kosten, orgid)
values
    (:next_eleven, 'party hard', 'solothurn', current_date, 1000, 1);

-- delete
delete from anlass where anlaid = :next_eleven;
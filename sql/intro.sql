select * from anlass;
select * from person;
select * from teilnehmer;

select
    a.anlaid,
    a.bezeichner,
    a.datum,
    count(*) anzahl_teilnehmer
from anlass a
join teilnehmer t on a.anlaid = t.anlaid
group by a.anlaid, a.bezeichner, a.datum;
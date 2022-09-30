create or replace view anlass_stat as
    select
        a.anlaid,
        a.bezeichner,
        a.datum,
        count(*) anzahl_teilnehmer
    from anlass a
    join teilnehmer t on a.anlaid = t.anlaid
    group by a.anlaid, a.bezeichner, a.datum;

-- drop view anlass_stat;

select * from anlass_stat;

create or replace view anlass_zukunft as
    select *
        from anlass_stat a
        where a.datum < sysdate;
-- 01
-- aufgabe 1
-- a)
create or replace view personen as
    select
        p.name,
        p.vorname,
        p.persid,
        p.ort wohnort,
        p.eintritt,
        p.austritt,
        s.bezeichner
    from person p
    left join status s on p.statid = s.statid
    order by p.persid asc;

select * from personen;

-- b)
create or replace view hauptsponsor as
    select * from (
        select
            sponid,
            name,
            ort
        from sponsor
        order by spendentotal desc
    )
    where rownum <= 1;

select * from hauptsponsor;
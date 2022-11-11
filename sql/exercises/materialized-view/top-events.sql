-- sql system/hftadmin
create materialized view top_events as
    select
        e.teilnehmer,
        a.bezeichner anlass,
        a.anlaid anlass_id,
        o.name organisator,
        o.vorname vorname
    from (
        select
            count(t.persid) teilnehmer,
            t.anlaid
        from vereinuser.teilnehmer t
        group by
            t.anlaid
        order by count(t.persid) desc
    ) e
    left join vereinuser.anlass a on e.anlaid = a.anlaid
    left join vereinuser.person o on a.orgid = o.persid
    where rownum <= 3;

select * from top_events;
--    TEILNEHMER                  ANLASS    ANLASS_ID    ORGANISATOR    VORNAME
-- _____________ _______________________ ____________ ______________ __________
--           107 Whitlocks Auto-Event             378 Lehrer         Sophie
--           100 Realty Solutio-Event             154 Müller         Philipp
--            99 Britches of Ge-Event             362 Scherer        Uta

update vereinuser.teilnehmer t
set t.anlaid = 154
where
    t.persid = 1223
    and
    t.anlaid = 378;

select * from top_events;
--    TEILNEHMER                  ANLASS    ANLASS_ID    ORGANISATOR    VORNAME
-- _____________ _______________________ ____________ ______________ __________
--           107 Whitlocks Auto-Event             378 Lehrer         Sophie
--           100 Realty Solutio-Event             154 Müller         Philipp
--            99 Britches of Ge-Event             362 Scherer        Uta

exec dbms_mview.refresh('top_events');

select * from top_events;
--    TEILNEHMER                  ANLASS    ANLASS_ID    ORGANISATOR    VORNAME
-- _____________ _______________________ ____________ ______________ __________
--           106 Whitlocks Auto-Event             378 Lehrer         Sophie
--           101 Realty Solutio-Event             154 Müller         Philipp
--            99 Britches of Ge-Event             362 Scherer        Uta

update vereinuser.teilnehmer t
set t.anlaid = 378
where
    t.persid = 1223
    and
    t.anlaid = 154;

exec dbms_mview.refresh('top_events');

select * from top_events;
--    TEILNEHMER                  ANLASS    ANLASS_ID    ORGANISATOR    VORNAME
-- _____________ _______________________ ____________ ______________ __________
--           107 Whitlocks Auto-Event             378 Lehrer         Sophie
--           100 Realty Solutio-Event             154 Müller         Philipp
--            99 Britches of Ge-Event             362 Scherer        Uta

drop materialized view top_events;
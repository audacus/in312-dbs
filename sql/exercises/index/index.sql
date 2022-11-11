-- 01

-- update statistics
execute dbms_stats.gather_schema_stats('vereinuser');

-- existing indexes
select
    index_name,
    table_name,
    column_name
from user_ind_columns;

-- relations that are likely to occur:
-- - person.statid = status.statid
-- - person.mentorid = person.persid
-- - spende.sponid = sponsor.sponid
-- - spende.anlaid = anlass.anlaid
-- - anlass.orgid = person.persid
-- - teilnehmer.persid = person.persid
-- - teilnehmer.anlaid = anlass.anlaid

-- filter that are likely to occur:
-- - person.bezahlt = 0 and person.statid != 3
-- - extract(year from spende.datum) = extract(year from to_date('2016-01-01'))
-- - extract(year from spende.datum), sum(spende.betrag) ... group by extract(year from spende.datum)
-- - sum(spende.betrag)

-- show execution plan
set autotrace on

-- queries to test costs
select * from person where statid != 3;

select
    extract(year from datum) jahr,
    sum(betrag) betrag
from spende
group by extract(year from datum);

select
    count(*) mitglieder,
    p.statid,
    s.bezeichner,
    sum(s.beitrag) beitraege
from person p
left join status s on p.statid = s.statid
group by p.statid, s.bezeichner;

select
    count(t.persid) teilnehmer,
    a.datum,
    a.bezeichner,
    p.name organisator_name,
    p.vorname organisator_vorname
from teilnehmer t
left join anlass a on t.anlaid = a.anlaid
left join person p on a.orgid = p.persid
group by
    t.anlaid,
    a.datum,
    a.bezeichner,
    p.name,
    p.vorname
order by count(t.persid) desc;

select
    count(a.anlaid) anlaeasse,
    p.name,
    p.vorname
from anlass a
left join person p on a.orgid = p.persid
group by
    p.name,
    p.vorname
order by count(a.anlaid) desc;

select
    count(d.spenid) spenden,
    s.name sponsor,
    sum(d.betrag) total_betrag,
    s.spendentotal spende_total
from spende d
left join sponsor s on d.sponid = s.sponid
group by
    s.name,
    s.spendentotal
order by sum(d.betrag) desc;

-- 02
-- 02.1

-- person.statid
-- used in joins and filters to get information about the distribution of members and to filter out former members.

-- person.bezahlt
-- used to get all members that have or haven't payed the membership fee.

-- anlass.orgid
-- used to get all information about an event.

-- anlass.bezeichner
-- used to search for events by text.

-- anlass.datum
-- used to search for events by date.

-- spende.sponid
-- used to see which sponsor has made how much donations.

-- spende.datum
-- used to evaluate the donations during a timespan.

-- 02.2
-- create indexes

-- person.statid
create index person_statid on person(statid);

-- person.bezahlt
create index person_bezahlt on person(bezahlt);

-- anlass.orgid
create index anlass_orgid on anlass(orgid);

-- anlass.bezeichner
create index anlass_bezeichner on anlass(bezeichner);

-- anlass.datum
create index anlass_datum on anlass(datum);

-- spende.sponid
create index spende_sponid on spende(sponid);

-- spende.datum
create index spende_datum on spende(datum);

-- 02.3
-- test indexes

-- person.statid
select
    count(p.persid) personen,
    s.bezeichner
from person p
left join status s on p.statid = s.statid
where s.statid != 3
group by s.bezeichner;
-- before:
-- ------------------------------------------------------------------------------
-- | Id  | Operation           | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
-- ------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT    |        |     5 |    70 |    74   (5)| 00:00:01 |
-- |   1 |  HASH GROUP BY      |        |     5 |    70 |    74   (5)| 00:00:01 |
-- |*  2 |   HASH JOIN         |        | 16677 |   228K|    72   (2)| 00:00:01 |
-- |*  3 |    TABLE ACCESS FULL| STATUS |     5 |    55 |     3   (0)| 00:00:01 |
-- |*  4 |    TABLE ACCESS FULL| PERSON | 20012 | 60036 |    69   (2)| 00:00:01 |
-- ------------------------------------------------------------------------------
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
--    2 - access("P"."STATID"="S"."STATID")
--    3 - filter("S"."STATID"<>3)
--    4 - filter("P"."STATID"<>3)
-- Statistics
-- -----------------------------------------------------------
--                3  DB time
--               14  SQL*Net roundtrips to/from client
--              490  bytes received via SQL*Net from client
--            23883  bytes sent via SQL*Net to client
--                2  calls to get snapshot scn: kcmgss
--                8  calls to kcmgcs
--              209  consistent gets
--              209  consistent gets from cache
--              209  consistent gets from cache (fastpath)
--                1  enqueue releases
--                1  enqueue requests
--                2  execute count
--              201  no work - consistent read gets
--               16  non-idle wait count
--                2  opened cursors cumulative
--                1  opened cursors current
--                1  parse count (hard)
--                2  parse count (total)
--                1  recursive calls
--              209  session logical reads
--                1  sorts (memory)
--              628  sorts (rows)
--              201  table scan blocks gotten
--            20018  table scan rows gotten
--                2  table scans (short tables)
--               15  user calls
-- after:
-- ----------------------------------------------------------------------------------------
-- | Id  | Operation              | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT       |               |     5 |    70 |    18  (17)| 00:00:01 |
-- |   1 |  HASH GROUP BY         |               |     5 |    70 |    18  (17)| 00:00:01 |
-- |*  2 |   HASH JOIN            |               | 16677 |   228K|    16   (7)| 00:00:01 |
-- |*  3 |    TABLE ACCESS FULL   | STATUS        |     5 |    55 |     3   (0)| 00:00:01 |
-- |*  4 |    INDEX FAST FULL SCAN| PERSON_STATID | 20012 | 60036 |    12   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------------
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
--    2 - access("P"."STATID"="S"."STATID")
--    3 - filter("S"."STATID"<>3)
--    4 - filter("P"."STATID"<>3)
-- Statistics
-- -----------------------------------------------------------
--                1  CPU used by this session
--                1  CPU used when call started
--                4  DB time
--               14  SQL*Net roundtrips to/from client
--              490  bytes received via SQL*Net from client
--            23892  bytes sent via SQL*Net to client
--                2  calls to get snapshot scn: kcmgss
--                5  calls to kcmgcs
--               51  consistent gets
--               51  consistent gets from cache
--               51  consistent gets from cache (fastpath)
--                1  enqueue releases
--                1  enqueue requests
--                2  execute count
--                1  index fast full scans (full)
--               46  no work - consistent read gets
--               16  non-idle wait count
--                2  opened cursors cumulative
--                1  opened cursors current
--                1  parse count (hard)
--                2  parse count (total)
--                1  parse time elapsed
--                1  recursive calls
--               51  session logical reads
--                1  sorts (memory)
--              628  sorts (rows)
--                5  table scan blocks gotten
--                6  table scan rows gotten
--                1  table scans (short tables)
--               15  user calls

-- anlass.bezeichner
select
    a.bezeichner,
    a.ort,
    a.datum,
    p.name,
    p.vorname
from anlass a
left join person p on a.orgid = p.persid
where a.bezeichner like '%Auto%';
-- before / after -> same / no impact

-- anlass.datum
select
    a.bezeichner,
    a.ort,
    a.datum,
    p.name,
    p.vorname
from anlass a
left join person p on a.orgid = p.persid
where a.datum between date '2015-01-01' and date '2015-12-31';
-- before / after -> same / no impact

-- 03
-- 03.1

-- person.plz & person.ort
-- zip and city are often used together and the combination of the two columns is / should be unique.

-- person.name & person.vorname
-- lastname and firstname are bound together per person and are often used to display information

-- 03.2
-- create index with 2 columns

-- person.persid & person.plz & person.ort
create index person_plz_ort on person(plz, ort);

-- person.name & person.vorname
create index person_persid_name_vorname on person(persid, name, vorname);

-- 03.3
-- test indexes

-- person.plz & person.ort
select count(*) zuercher from person where ort = 'Zürich';
-- before:
-- -----------------------------------------------------------------------------
-- | Id  | Operation          | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
-- -----------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT   |        |     1 |     9 |    69   (2)| 00:00:01 |
-- |   1 |  SORT AGGREGATE    |        |     1 |     9 |            |          |
-- |*  2 |   TABLE ACCESS FULL| PERSON |  2009 | 18081 |    69   (2)| 00:00:01 |
-- -----------------------------------------------------------------------------
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
--    2 - filter("ORT"='Zürich')
-- Statistics
-- -----------------------------------------------------------
--                4  DB time
--               14  SQL*Net roundtrips to/from client
--              397  bytes received via SQL*Net from client
--            23818  bytes sent via SQL*Net to client
--                2  calls to get snapshot scn: kcmgss
--                7  calls to kcmgcs
--              203  consistent gets
--              203  consistent gets from cache
--              203  consistent gets from cache (fastpath)
--                1  enqueue releases
--                1  enqueue requests
--                2  execute count
--              196  no work - consistent read gets
--               16  non-idle wait count
--                2  opened cursors cumulative
--                1  opened cursors current
--                1  parse count (hard)
--                2  parse count (total)
--                1  recursive calls
--              203  session logical reads
--                1  sorts (memory)
--              628  sorts (rows)
--              196  table scan blocks gotten
--            20012  table scan rows gotten
--                1  table scans (short tables)
--               15  user calls
-- after:
-- ----------------------------------------------------------------------------------------
-- | Id  | Operation             | Name           | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT      |                |     1 |     9 |    21   (0)| 00:00:01 |
-- |   1 |  SORT AGGREGATE       |                |     1 |     9 |            |          |
-- |*  2 |   INDEX FAST FULL SCAN| PERSON_PLZ_ORT |  2009 | 18081 |    21   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------------
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
--    2 - filter("ORT"='Zürich')
-- Statistics
-- -----------------------------------------------------------
--                4  DB time
--               14  SQL*Net roundtrips to/from client
--              397  bytes received via SQL*Net from client
--            23823  bytes sent via SQL*Net to client
--                2  calls to get snapshot scn: kcmgss
--                4  calls to kcmgcs
--               75  consistent gets
--               75  consistent gets from cache
--               75  consistent gets from cache (fastpath)
--                1  enqueue releases
--                1  enqueue requests
--                2  execute count
--                1  index fast full scans (full)
--               71  no work - consistent read gets
--               16  non-idle wait count
--                2  opened cursors cumulative
--                1  opened cursors current
--                1  parse count (hard)
--                2  parse count (total)
--                1  parse time elapsed
--                1  recursive calls
--               75  session logical reads
--                1  sorts (memory)
--              628  sorts (rows)
--               15  user calls

-- person.persid & person.plz & person.ort
-- + anlass.orgid
select
    a.bezeichner,
    a.ort,
    a.datum,
    p.name,
    p.vorname
from anlass a
left join person p on a.orgid = p.persid
where a.bezeichner like '%Auto%';
-- before (none):
-- no performance impact
-- ------------------------------------------------------------------------------------------
-- | Id  | Operation                    | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-- ------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT             |           |    20 |  1200 |    23   (0)| 00:00:01 |
-- |   1 |  NESTED LOOPS OUTER          |           |    20 |  1200 |    23   (0)| 00:00:01 |
-- |*  2 |   TABLE ACCESS FULL          | ANLASS    |    20 |   800 |     3   (0)| 00:00:01 |
-- |   3 |   TABLE ACCESS BY INDEX ROWID| PERSON    |     1 |    20 |     1   (0)| 00:00:01 |
-- |*  4 |    INDEX UNIQUE SCAN         | PERSON_PK |     1 |       |     0   (0)| 00:00:01 |
-- ------------------------------------------------------------------------------------------
-- after (anlass.orgid):
-- no performance impact
-- ------------------------------------------------------------------------------------------
-- | Id  | Operation                    | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-- ------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT             |           |    20 |  1200 |    23   (0)| 00:00:01 |
-- |   1 |  NESTED LOOPS OUTER          |           |    20 |  1200 |    23   (0)| 00:00:01 |
-- |*  2 |   TABLE ACCESS FULL          | ANLASS    |    20 |   800 |     3   (0)| 00:00:01 |
-- |   3 |   TABLE ACCESS BY INDEX ROWID| PERSON    |     1 |    20 |     1   (0)| 00:00:01 |
-- |*  4 |    INDEX UNIQUE SCAN         | PERSON_PK |     1 |       |     0   (0)| 00:00:01 |
-- ------------------------------------------------------------------------------------------
-- after (anlass.orgid + person.persid & person.plz & person.ort):
-- no performance impact
-- -------------------------------------------------------------------------------------------------
-- | Id  | Operation          | Name                       | Rows  | Bytes | Cost (%CPU)| Time     |
-- -------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT   |                            |    20 |  1200 |    23   (0)| 00:00:01 |
-- |   1 |  NESTED LOOPS OUTER|                            |    20 |  1200 |    23   (0)| 00:00:01 |
-- |*  2 |   TABLE ACCESS FULL| ANLASS                     |    20 |   800 |     3   (0)| 00:00:01 |
-- |*  3 |   INDEX RANGE SCAN | PERSON_PERSID_NAME_VORNAME |     1 |    20 |     1   (0)| 00:00:01 |
-- -------------------------------------------------------------------------------------------------

-- **********
-- revert all
-- **********

-- indexes
drop index person_statid;
drop index person_bezahlt;
drop index anlass_orgid;
drop index anlass_bezeichner;
drop index anlass_datum;
drop index spende_sponid;
drop index spende_datum;
drop index person_plz_ort;
drop index person_persid_name_vorname;
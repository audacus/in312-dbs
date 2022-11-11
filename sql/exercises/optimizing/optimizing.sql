select
    p.name,
    p.vorname,
    sum(nvl(s.spendentotal, 0)) spendentotal
from sponsorenkontakt sk
left join sponsor s on sk.sponid = s.sponid
left join person p on sk.persid = p.persid
group by
    p.name,
    p.vorname
order by sum(nvl(s.spendentotal, 0)) desc;
-- ------------------------------------------------------------------------------------------------
-- | Id  | Operation                | Name                | Rows  | Bytes | Cost (%CPU)| Time     |
-- ------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |                     |   505 | 17675 |    79   (6)| 00:00:01 |
-- |   1 |  SORT ORDER BY           |                     |   505 | 17675 |    79   (6)| 00:00:01 |
-- |   2 |   HASH GROUP BY          |                     |   505 | 17675 |    79   (6)| 00:00:01 |
-- |*  3 |    HASH JOIN OUTER       |                     |   505 | 17675 |    77   (3)| 00:00:01 |
-- |*  4 |     HASH JOIN OUTER      |                     |   505 |  7575 |     8  (13)| 00:00:01 |
-- |   5 |      INDEX FAST FULL SCAN| SPONSORENKONTAKT_PK |   505 |  4040 |     2   (0)| 00:00:01 |
-- |   6 |      TABLE ACCESS FULL   | SPONSOR             |  1003 |  7021 |     5   (0)| 00:00:01 |
-- |   7 |     TABLE ACCESS FULL    | PERSON              | 20012 |   390K|    68   (0)| 00:00:01 |
-- ------------------------------------------------------------------------------------------------

-- Predicate Information (identified by operation id):
-- ---------------------------------------------------

--    3 - access("SK"."PERSID"="P"."PERSID"(+))
--    4 - access("SK"."SPONID"="S"."SPONID"(+))
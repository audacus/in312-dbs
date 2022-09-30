create table anlass_2 as
    select *
        from anlass a;

select * from anlass_2;

update anlass_2 set bezeichner='NEU' where anlaid > 3;

drop table anlass_2;

--

create materialized view anlass_stat_snapshot as
    select * from anlass_stat;

exec dbms_mview.refresh('anlass_stat_snapshot');
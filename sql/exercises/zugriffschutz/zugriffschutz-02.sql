-- 02
-- aufgabe 1
select * from vereinuser.person;

-- aufgabe 2
-- sql vereinuser/vereinuser
spool datadict-vereinuser.csv
set sqlformat csv
select * from dict;
spool off

-- sql system/hftadmin
spool datadict-system.csv
set sqlformat csv
select * from dict;
spool off

-- aufgabe 3
-- a)
select * from user_catalog;

-- b)
select view_name from user_views;

-- c)
select count(*) from all_users;

-- d)
select username, created from user_users;

-- e)
--desc sponsor;
select
    column_name,
    data_type,
    data_length,
    data_scale,
    nullable
from all_tab_columns where table_name = 'SPONSOR';

-- f)
select * from user_constraints where table_name = 'PERSON';

-- g)
-- tabellen kommentare
select
    table_name,
    table_type attribute,
    comments
from user_tab_comments
where
    table_type = 'TABLE'
    and
    comments is not null
union
-- spalten kommentare
select
    table_name,
    column_name attribute,
    comments
from user_col_comments
where comments is not null;

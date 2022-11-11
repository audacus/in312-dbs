-- sql scott/tiger
-- bad
create or replace view e7369 as
    select * from emp
    where empno = 7369;

-- good
-- add username to emp table
alter table emp
    add eaccount char(30);

update emp
    set eaccount = substr(ename, 1, 3) || '01';
commit;

-- create dynamic view
create or replace view my_data as
    select * from emp
    where eaccount = USER;

-- sql system/hftadmin
-- add additional db user ada01/ada01 and grant privileges
create user ada01 identified by ada01;
grant connect to ada01;
grant select on scott.my_data to ada01;

-- sql ada01/ada01
select * from scott.my_data;
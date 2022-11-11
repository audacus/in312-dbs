-- sql system/hftadmin

-- 1.
-- create user and allow login
create user tester identified by test;
grant connect to tester;

-- 2.
-- sql tester/test
-- check objects
select table_name from all_tables;

-- 3.
-- create role with privileges
create role test;
grant select on vereinuser.person to test;
-- change password
alter user tester identified by tester;
-- add role to user
grant test to tester;

-- 4.
-- sql tester/tester
-- check objects
select * from vereinuser.person;

-- 5.
-- sql system/hftadmin
-- add synonym
create public synonym person for vereinuser.person;

-- 6.
-- remove stuff
drop user tester;
drop role test;
drop public synonym person;
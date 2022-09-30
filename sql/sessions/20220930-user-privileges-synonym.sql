-- sql system/hftadmin

-- user
create user user01 identified by user01;
--drop user user01;
select * from all_users;

-- role
create role my_role;
--drop role my_role;
select * from dba_roles;

-- privileges
grant create session to user01; -- system privilege
grant create synonym to user01; -- allows `create synonym`
grant connect to user01; -- role with underlying privilege
grant connect to user01 with admin option; -- can pass role `connect` to other users

revoke create session from user01; -- revokes system privileg that also affects privileges of roles
revoke connect from user01; -- revokes role from user, not affecting given privileges

grant my_role to user01;
grant select on vereinuser.person to my_role;

-- public -> for all users
create public synonym person for vereinuser.person; -- allows `select * from person;` instead of `vereinuser.person`
--drop public synonym person;
-- sql system/hftadmin

-- **********
-- revert all
-- **********

-- alter own data
alter table vereinuser.person drop column benutzername;
drop view vereinuser.myperson;
drop role member;
drop user mta;
drop user klu;
drop user bfr;
drop user fhu;
drop user sba;

-- users
drop user anybody;
drop user lca;
drop user dme;
drop user bbr;
drop user rgr;
drop user pme;

-- roles
drop role world;
drop role head;
drop role secretary;
drop role finances;

-- views
drop materialized view vorstand;
drop materialized view sponsoren;
drop materialized view anlaesse;
drop materialized view kontaktpersonen;

-- **********
-- create all
-- **********

-- materialized views
-- vorstand
create materialized view vorstand as
    select
        f.bezeichner,
        p.name,
        p.vorname
    from vereinuser.funktionsbesetzung fb
    left join vereinuser.funktion f on fb.funkid = f.funkid
    left join vereinuser.person p on fb.persid = p.persid
    where
        fb.ruecktritt is null
        or
        fb.ruecktritt > current_date;

-- sponsoren
create materialized view sponsoren as
    select
        s.name,
        s.ort
    from vereinuser.sponsor s;

-- anlaesse
create materialized view anlaesse as
    select
        e.bezeichner,
        e.ort,
        e.datum
    from vereinuser.anlass e;

-- kontaktpersonen
create materialized view kontaktpersonen as
    select p.*
    from vereinuser.person p
    where p.persid in (
        select sc.persid
        from vereinuser.sponsorenkontakt sc
    );

-- roles
-- world
create role world; -- öffentlichkeit
grant connect to world;
grant select on vorstand to world;
grant select on sponsoren to world;
grant select on anlaesse to world;

-- head
create role head; -- vorstand
grant world to head;
grant select on vereinuser.anlass to head;
grant select on vereinuser.funktion to head;
grant select on vereinuser.funktionsbesetzung to head;
grant select on vereinuser.person to head;
grant select on vereinuser.spende to head;
grant select on vereinuser.sponsor to head;
grant select on vereinuser.sponsorenkontakt to head;
grant select on vereinuser.status to head;
grant select on vereinuser.teilnehmer to head;

-- secretary
create role secretary; -- sekretariat
grant world to secretary;
grant select, insert, update, delete on vereinuser.anlass to secretary;
grant select, insert, update, delete on vereinuser.funktion to secretary;
grant select, insert, update, delete on vereinuser.funktionsbesetzung to secretary;
grant select, insert, update, delete on vereinuser.person to secretary;
grant select, insert, update, delete on vereinuser.status to secretary;
grant select, insert, update, delete on vereinuser.teilnehmer to secretary;

-- finances
create role finances; -- finanzen
grant world to finances;
grant head to finances;
grant select, insert, update, delete on vereinuser.spende to finances;
grant select, insert, update, delete on vereinuser.sponsor to finances;
grant select, insert, update, delete on vereinuser.sponsorenkontakt to finances;
grant select on kontaktpersonen to finances;
grant select, update (bemerkungen) on vereinuser.person to finances;

-- users
-- anybody / öffentlichkeit
create user anybody identified by password;
grant world to anybody;

-- lca / leo cadola
create user lca identified by password;
grant secretary to lca;

-- dme / dominik meyer
create user dme identified by password;
grant head, finances to dme;

-- bbr / beni bregger
create user bbr identified by password;
grant head, finances to bbr;

-- rgr / romy gruber
create user rgr identified by password;
grant head to rgr;

-- pme / petra meyer
create user pme identified by password;
grant head to pme;

-- alter own data
-- add additional column with username
alter table vereinuser.person
    add benutzername char(30);

-- add username for all person
update vereinuser.person
    set benutzername = upper(substr(vorname, 1, 1) || substr(name, 1, 2));

-- create dynamic view
create view vereinuser.myperson as
    select
        p.*,
        s.bezeichner status
    from vereinuser.person p
    left join vereinuser.status s on p.statid = s.statid
    where p.benutzername = user;

-- create role
create role member; -- vereinsmitglied
grant world to member;
grant select on vereinuser.myperson to member;

/*
TODO: why error?!

create view myperson as
    select
        p.*,
        s.bezeichner status
    from vereinuser.person p
    left join vereinuser.status s on p.statid = s.statid
    where p.benutzername = user;

-- create role
create role member; -- vereinsmitglied
grant world to member;
grant select on myperson to member;

Error starting at line : 1 in command -
grant select on myperson to member
Error report -
ORA-01720: grant option does not exist for 'VEREINUSER.STATUS'
01720. 00000 -  "grant option does not exist for '%s.%s'"
*Cause:    A grant was being performed on a view or a view was being replaced
           and the grant option was not present for an underlying object.
*Action:   Obtain the grant option on all underlying objects of the view or
           revoke existing grants on the view.
*/

-- create users
-- mta / mario tamburino
create user mta identified by password;
grant member to mta;

-- klu / kevin luder
create user klu identified by password;
grant member to klu;

-- bfr / barbara frei
create user bfr identified by password;
grant member to bfr;

-- fhu / felix huber
create user fhu identified by password;
grant member to fhu;

-- sba / sabine bart
create user sba identified by password;
grant member to sba;

-- add all users to member
grant member to lca;
grant member to dme;
grant member to bbr;
grant member to rgr;
grant member to pme;
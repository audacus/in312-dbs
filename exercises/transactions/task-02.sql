-- a) eintreten
-- zugriffsmodus: read write
-- isolationsebene: read committed
create or replace procedure entering(

)

-- b) funktion uebernehmen
-- zugriffsmodus: read write
-- isolationsebene: read committed serializable
create or replace precedure takeOverFunction(

)

-- c) austreten
-- zugriffsmodus: read write
-- isolationsebene: read committed
create or replace procedure leave(

)
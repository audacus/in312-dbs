SET serveroutput ON
DECLARE
    land_plz_ort    VARCHAR2(40) := 'CH-2540 Grenchen';
    land            CHAR(2);
    plz             VARCHAR(5);
    ort             VARCHAR2(34);

    regex           VARCHAR2(50) := '([A-Z]+)-([0-9]+)\s(.+)';
BEGIN
    land := regexp_replace(land_plz_ort, regex, '\1');
    plz  := regexp_replace(land_plz_ort, regex, '\2');
    ort  := regexp_replace(land_plz_ort, regex, '\3');

    DBMS_OUTPUT.put_line('Land: ' || land);
    DBMS_OUTPUT.put_line('PLZ: '  || plz);
    DBMS_OUTPUT.put_line('Ort: '  || ort);
END;
/
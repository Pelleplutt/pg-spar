CREATE OR REPLACE FUNCTION Save_SPAR_PersonSokning(
        SPARdata SPARPersonData,
        SPARAdress SPARPersonAdress[],
        SPARPerson SPARPersonDetaljer[]
) RETURNS VOID AS $BODY$
DECLARE
    _i integer;
    _spa SPARPersonAdress;
    _spd SPARPersonDetaljer;

BEGIN

UPDATE SPARPersonData SET
    FysiskPersonId = SPARdata.FysiskPersonId,
    Sekretessmarkering = SPARdata.Sekretessmarkering,
    SekretessAndringsdatum = SPARdata.SekretessAndringsdatum,
    SenasteAndringFolkbokforing = SPARdata.SenasteAndringFolkbokforing
WHERE 
    FysiskPersonId=SPARdata.FysiskPersonId;

IF NOT FOUND THEN
    INSERT INTO SPARPersonData VALUES(SPARdata.*);
ELSE
    DELETE FROM SPARPersonAdress WHERE FysiskPersonId=SPARdata.FysiskPersonId;
    DELETE FROM SPARPersonDetaljer WHERE FysiskPersonId=SPARdata.FysiskPersonId;
END IF;

FOR _i IN array_lower(SPARAdress, 1) .. array_upper(SPARAdress, 1) LOOP
    _spa := SPARAdress[_i];
    SELECT
        NEXTVAL('seqSPARPersonAdress')
    INTO
        _spa.SPARPersonAdressID;

    INSERT INTO SPARPersonAdress VALUES (_spa.*);
END LOOP;

FOR _i IN array_lower(SPARPerson, 1) .. array_upper(SPARPerson, 1) LOOP
    _spd := SPARPerson[_i];
    SELECT
        NEXTVAL('seqSPARPersonDetaljer')
    INTO
        _spd.SPARPersonDetaljerID;

    INSERT INTO SPARPersonDetaljer VALUES(_spd.*);
END LOOP;


END;
$BODY$ LANGUAGE plpgsql;

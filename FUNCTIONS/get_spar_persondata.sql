CREATE OR REPLACE FUNCTION Get_SPAR_PersonData(
        _PersonId   text,

        OUT SPARData SPARPersonData,
        OUT SPARAdress SPARPersonAdress[],
        OUT SPARPerson SPARPersonDetaljer[]
) RETURNS RECORD AS $BODY$
BEGIN

SELECT * INTO STRICT SPARData FROM SPARPersonData WHERE FysiskPersonId = _PersonId;
IF FOUND THEN
    SELECT array_agg(spa) FROM (SELECT * FROM SPARPersonAdress WHERE FysiskPersonId = _PersonId ORDER BY DatumFrom, DatumTom DESC) AS spa INTO SPARAdress;
    SELECT array_agg(spd) FROM (SELECT * FROM SPARPersonDetaljer WHERE FysiskPersonId = _PersonId ORDER BY DatumFrom, DatumTom DESC) AS spd INTO SPARPerson;
END IF;

END;
$BODY$ LANGUAGE plpgsql;

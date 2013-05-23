CREATE OR REPLACE FUNCTION Save_SPAR_PersonSokning(
        SPARdata SPARPersonData,
        SPARAdress SPARPersonAdress[],
        SPARPerson SPARPersonDetaljer[]
) RETURNS VOID AS $BODY$
DECLARE
    _i integer;
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

    INSERT INTO SPARPersonAdress VALUES (
                default,
                SPARAdress[_i].FysiskPersonId,
                SPARAdress[_i].AdressTyp,
                SPARAdress[_i].CareOf,
                SPARAdress[_i].DatumFrom,
                SPARAdress[_i].DatumTom,
                SPARAdress[_i].Utdelningsadress1,
                SPARAdress[_i].Utdelningsadress2,
                SPARAdress[_i].Utdelningsadress3,
                SPARAdress[_i].PostNr,
                SPARAdress[_i].Postort,
                SPARAdress[_i].Land,
                SPARAdress[_i].FolkbokfordLanKod,
                SPARAdress[_i].FolkbokfordKommunKod,
                SPARAdress[_i].FolkbokfordForsamlingKod,
                SPARAdress[_i].Folkbokforingsdatum
                );
END LOOP;

FOR _i IN array_lower(SPARPerson, 1) .. array_upper(SPARPerson, 1) LOOP

    INSERT INTO SPARPersonDetaljer VALUES(
                default,
                SPARPerson[_i].FysiskPersonId,
                SPARPerson[_i].DatumFrom,
                SPARPerson[_i].DatumTom,
                SPARPerson[_i].Aviseringsnamn,
                SPARPerson[_i].Fornamn,
                SPARPerson[_i].Tilltalsnamn,
                SPARPerson[_i].Mellannamn,
                SPARPerson[_i].Efternamn,
                SPARPerson[_i].HanvisningspersonNrByttTill,
                SPARPerson[_i].HanvisningspersonNrByttFran,
                SPARPerson[_i].Avregistreringsdatum,
                SPARPerson[_i].AvregistreringsorsakKod,
                SPARPerson[_i].Fodelsetid,
                SPARPerson[_i].Kon
                );
END LOOP;


END;
$BODY$ LANGUAGE plpgsql;

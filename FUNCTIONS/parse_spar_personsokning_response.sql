CREATE OR REPLACE FUNCTION Parse_SPAR_PersonSokning_Response(
        _XML xml,
        OUT SPARdata SPARPersonData,
        OUT SPARAdress SPARPersonAdress[],
        OUT SPARPerson SPARPersonDetaljer[]
) RETURNS SETOF RECORD AS $BODY$
DECLARE
        _NSArray text[];
        _DateTmp text;

        _pdar SPARPersonData;
        _pdl SPARPersonDetaljer[];
        _pdr SPARPersonDetaljer;
        _adl SPARPersonAdress[];
        _adr SPARPersonAdress;

        _pda xml;
        _ad xml;
        _pd xml;
        _fba xml;
        _spa xml;
        _ua xml;
BEGIN

_NSArray := ARRAY[
        ['soapenv', 'http://schemas.xmlsoap.org/soap/envelope/'],
        ['xsd','http://www.w3.org/2001/XMLSchema'],
        ['xsi','http://www.w3.org/2001/XMLSchema-instance'],
        ['spako','http://skatteverket.se/spar/komponent/1.0'],
        ['spain','http://skatteverket.se/spar/instans/1.0']
    ];

FOR _pda IN SELECT unnest(xpath('/soapenv:Envelope/soapenv:Body/spain:SPARPersonsokningSvar/spako:PersonsokningSvarsPost', _XML, _NSArray)) LOOP

    SPARdata.FysiskPersonId                   := (xpath('/spako:PersonsokningSvarsPost/spako:PersonId/spako:FysiskPersonId/text()', _pda, _NSArray))[1];
    SPARdata.Sekretessmarkering               := (xpath('/spako:PersonsokningSvarsPost/spako:Sekretessmarkering/text()', _pda, _NSArray))[1];
    SPARdata.SekretessAndringsdatum           := (xpath('/spako:PersonsokningSvarsPost/spako:SekretessAndringsdatum/text()', _pda, _NSArray))[1];
    SPARdata.SenasteAndringFolkbokforing      := (xpath('/spako:PersonsokningSvarsPost/spako:SenasteAndringFolkbokforing/text()', _pda, _NSArray))[1];

    FOR _pd IN SELECT unnest(xpath('/spako:PersonsokningSvarsPost/spako:Persondetaljer', _pda, _NSArray)) LOOP
        RAISE WARNING E'FOO %s', _pd;

        _pdr.DatumFrom                       := (xpath('/spako:Persondetaljer/spako:DatumFrom/text()', _pd, _NSArray))[1];
        _DateTmp := (xpath('/spako:Persondetaljer/spako:DatumTom/text()', _pd, _NSArray))[1]; 
        IF _DateTmp IS NOT NULL AND _DateTmp <> '9999-12-31' THEN
            _pdr.DatumTom                        := _DateTmp;
        END IF;
        _pdr.Aviseringsnamn                  := (xpath('/spako:Persondetaljer/spako:Aviseringsnamn/text()', _pd, _NSArray))[1];
        _pdr.Fornamn                         := (xpath('/spako:Persondetaljer/spako:Fornamn/text()', _pd, _NSArray))[1];
        _pdr.Tilltalsnamn                    := (xpath('/spako:Persondetaljer/spako:Tilltalsnamn/text()', _pd, _NSArray))[1];
        _pdr.Mellannamn                      := (xpath('/spako:Persondetaljer/spako:Mellannamn/text()', _pd, _NSArray))[1];
        _pdr.Efternamn                       := (xpath('/spako:Persondetaljer/spako:Efternamn/text()', _pd, _NSArray))[1];
        _pdr.HanvisningspersonNrByttTill     := (xpath('/spako:Persondetaljer/spako:HanvisningsPersonNrByttTill/text()', _pd, _NSArray))[1];
        _pdr.HanvisningspersonNrByttFran     := (xpath('/spako:Persondetaljer/spako:HanvisningsPersonNrByttFran/text()', _pd, _NSArray))[1];
        _pdr.Avregistreringsdatum            := (xpath('/spako:Persondetaljer/spako:Avregistreringsdatum/text()', _pd, _NSArray))[1];
        _pdr.AvregistreringsorsakKod         := (xpath('/spako:Persondetaljer/spako:AvregistreringsorsakKod/text()', _pd, _NSArray))[1];
        _pdr.Fodelsetid                      := (xpath('/spako:Persondetaljer/spako:Fodelsetid/text()', _pd, _NSArray))[1];
        _pdr.Kon                             := (xpath('/spako:Persondetaljer/spako:Kon/text()', _pd, _NSArray))[1];
        SPARPerson := array_append(SPARPerson, _pdr);
    END LOOP;

    FOR _ad IN SELECT unnest(xpath('/spako:PersonsokningSvarsPost/spako:Adress', _pda, _NSArray)) LOOP

        _adr.DatumFrom                       := (xpath('/spako:DatumFrom/text()', _ad, _NSArray))[1];

        _DateTmp := (xpath('/spako:DatumTom/text()', _ad, _NSArray))[1]; 
        IF _DateTmp IS NOT NULL AND _DateTmp <> '9999-12-31' THEN
            _adr.DatumTom                        := _DateTmp;
        END IF;

        FOR _fba IN SELECT unnest(xpath('/spako:Folkbokforingsadress', _ad, _NSArray)) LOOP
            _adr.AdressTyp                       := 'F';

            _adr.CareOf                          := (xpath('/spako:CareOf/text()', _fba, _NSArray))[1];
            _adr.Utdelningsadress1               := (xpath('/spako:Utdelningsadress1/text()', _fba, _NSArray))[1];
            _adr.Utdelningsadress2               := (xpath('/spako:Utdelningsadress2/text()', _fba, _NSArray))[1];
            _adr.PostNr                          := (xpath('/spako:PostNr/text()', _fba, _NSArray))[1];
            _adr.Postort                         := (xpath('/spako:Postort/text()', _fba, _NSArray))[1];
            _adr.Land                            := 'Sverige';
            _adr.FolkbokfordLanKod               := (xpath('/spako:FolkbokfordLanKod/text()', _fba, _NSArray))[1];
            _adr.FolkbokfordKommunKod            := (xpath('/spako:FolkbokfordKommunKod/text()', _fba, _NSArray))[1];
            _adr.FolkbokfordForsamlingKod        := (xpath('/spako:FolkbokfordForsamlingKod/text()', _fba, _NSArray))[1];
            _adr.Folkbokforingsdatum             := (xpath('/spako:Folkbokforingsdatum/text()', _fba, _NSArray))[1];
        END LOOP;

        FOR _spa IN SELECT unnest(xpath('/spako:SarskildPostadress', _ad, _NSArray)) LOOP
            _adr.CareOf                          := (xpath('/spako:CareOf/text()', _spa, _NSArray))[1];
            _adr.Utdelningsadress1               := (xpath('/spako:Utdelningsadress1/text()', _spa, _NSArray))[1];
            _adr.Utdelningsadress2               := (xpath('/spako:Utdelningsadress2/text()', _spa, _NSArray))[1];
            _adr.PostNr                          := (xpath('/spako:PostNr/text()', _spa, _NSArray))[1];
            _adr.Postort                         := (xpath('/spako:Postort/text()', _spa, _NSArray))[1];
            _adr.Land                            := 'Sverige';
        END LOOP;

        FOR _ua IN SELECT unnest(xpath('/spako:Utlandsadress', _ad, _NSArray)) LOOP
            _adr.Utdelningsadress1               := (xpath('/spako:Utdelningsadress1/text()', _ua, _NSArray))[1];
            _adr.Utdelningsadress2               := (xpath('/spako:Utdelningsadress2/text()', _ua, _NSArray))[1];
            _adr.Utdelningsadress3               := (xpath('/spako:Utdelningsadress3/text()', _ua, _NSArray))[1];
            _adr.Land                            := (xpath('/spako:Land/text()', _ua, _NSArray))[1];
        END LOOP;

        SPARAdress := array_append(SPARAdress, _adr);
    END LOOP;

    RETURN NEXT;
END LOOP;

END;
$BODY$ LANGUAGE plpgsql;

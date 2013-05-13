CREATE OR REPLACE FUNCTION Parse_SPAR_PersonSokning_Response(
        _XML xml,
        OUT SPARdata SPARPersonData,
        OUT SPARAdress SPARPersonAdress[],
        OUT SPARPerson SPARPersonDetaljer[]
) RETURNS SETOF RECORD AS $BODY$
DECLARE
        _NSArray text[];
        _DateTmp text;

        _ xml;
        __ SPARPersonDetaljer;
        ___ SPARPersonAdress;
        ____ SPARPersonAdress;

        _dummy1 xml;
        _cnt1 integer;
        _xpathbase1 text;

        _dummy2 xml;
        _cnt2 integer;
        _xpathbase2 text;
BEGIN

_NSArray := ARRAY[
        ['soapenv', 'http://schemas.xmlsoap.org/soap/envelope/'],
        ['xsd','http://www.w3.org/2001/XMLSchema'],
        ['xsi','http://www.w3.org/2001/XMLSchema-instance'],
        ['spako','http://skatteverket.se/spar/komponent/1.0'],
        ['spain','http://skatteverket.se/spar/instans/1.0']
    ];

FOR _ IN SELECT unnest(xpath('/soapenv:Envelope/soapenv:Body/spain:SPARPersonsokningSvar/spako:PersonsokningSvarsPost', _XML, _NSArray)) LOOP

    SPARdata.FysiskPersonId                   := (xpath('/spako:PersonsokningSvarsPost/spako:PersonId/spako:FysiskPersonId/text()', _, _NSArray))[1];
    SPARdata.Sekretessmarkering               := (xpath('/spako:PersonsokningSvarsPost/spako:Sekretessmarkering/text()', _, _NSArray))[1];
    SPARdata.SekretessAndringsdatum           := (xpath('/spako:PersonsokningSvarsPost/spako:SekretessAndringsdatum/text()', _, _NSArray))[1];
    SPARdata.SenasteAndringFolkbokforing      := (xpath('/spako:PersonsokningSvarsPost/spako:SenasteAndringFolkbokforing/text()', _, _NSArray))[1];


        -- This is really poor code and I wish I could find another way of
        -- doing this. I ideally would like to loop over the xpath return as one would
        -- expect. But doing to causes a returned XML root element without namespace
        -- definition and the sub-elements are in the "spako" namespace, it seems
        -- impossible to convince xpath to give me the contents of those elements without
        -- croaking. 
    _cnt1 := 0;
    FOR _dummy1 IN SELECT unnest(xpath('/spako:PersonsokningSvarsPost/spako:Persondetaljer', _, _NSArray)) LOOP
        _cnt1 := _cnt1 + 1;
        _xpathbase1 := '/spako:PersonsokningSvarsPost/spako:Persondetaljer[' || _cnt1 || ']';

        __.DatumFrom                       := (xpath(_xpathbase1 || '/spako:DatumFrom/text()', _, _NSArray))[1];
        _DateTmp := (xpath(_xpathbase1 || '/spako:DatumTom/text()', _, _NSArray))[1]; 
        IF _DateTmp IS NOT NULL AND _DateTmp <> '9999-12-31' THEN
            __.DatumTom                        := _DateTmp;
        END IF;
        __.FysiskPersonId                  := SPARdata.FysiskPersonId;
        __.Aviseringsnamn                  := (xpath(_xpathbase1 || '/spako:Aviseringsnamn/text()', _, _NSArray))[1];
        __.Fornamn                         := (xpath(_xpathbase1 || '/spako:Fornamn/text()', _, _NSArray))[1];
        __.Tilltalsnamn                    := (xpath(_xpathbase1 || '/spako:Tilltalsnamn/text()', _, _NSArray))[1];
        __.Mellannamn                      := (xpath(_xpathbase1 || '/spako:Mellannamn/text()', _, _NSArray))[1];
        __.Efternamn                       := (xpath(_xpathbase1 || '/spako:Efternamn/text()', _, _NSArray))[1];
        __.HanvisningspersonNrByttTill     := (xpath(_xpathbase1 || '/spako:HanvisningsPersonNrByttTill/text()', _, _NSArray))[1];
        __.HanvisningspersonNrByttFran     := (xpath(_xpathbase1 || '/spako:HanvisningsPersonNrByttFran/text()', _, _NSArray))[1];
        __.Avregistreringsdatum            := (xpath(_xpathbase1 || '/spako:Avregistreringsdatum/text()', _, _NSArray))[1];
        __.AvregistreringsorsakKod         := (xpath(_xpathbase1 || '/spako:AvregistreringsorsakKod/text()', _, _NSArray))[1];
        __.Fodelsetid                      := (xpath(_xpathbase1 || '/spako:Fodelsetid/text()', _, _NSArray))[1];
        __.Kon                             := (xpath(_xpathbase1 || '/spako:Kon/text()', _, _NSArray))[1];

        SPARPerson := array_append(SPARPerson, __);
        __ := NULL;
    END LOOP;

    _cnt1 := 0;
    FOR _dummy1 IN SELECT unnest(xpath('/spako:PersonsokningSvarsPost/spako:Adress', _, _NSArray)) LOOP
        _cnt1 := _cnt1 + 1;
        _xpathbase1 := '/spako:PersonsokningSvarsPost/spako:Adress[' || _cnt1 || ']';

        ___.DatumFrom                       := (xpath(_xpathbase1 || '/spako:DatumFrom/text()', _, _NSArray))[1];

        _DateTmp := (xpath(_xpathbase1 || '/spako:DatumTom/text()', _, _NSArray))[1]; 
        IF _DateTmp IS NOT NULL AND _DateTmp <> '9999-12-31' THEN
            ___.DatumTom                        := _DateTmp;
        END IF;

        _cnt2 := 0;
        FOR _dummy2 IN SELECT unnest(xpath(_xpathbase1 || '/spako:Folkbokforingsadress', _, _NSArray)) LOOP
            _cnt2 := _cnt2 + 1;
            _xpathbase2 := _xpathbase1 || '/spako:Folkbokforingsadress[' || _cnt2 || ']';

            ____ := ___;
            ____.AdressTyp                       := 'F';

            ____.FysiskPersonId                  := SPARdata.FysiskPersonId;
            ____.CareOf                          := (xpath(_xpathbase2 || '/spako:CareOf/text()', _, _NSArray))[1];
            ____.Utdelningsadress1               := (xpath(_xpathbase2 || '/spako:Utdelningsadress1/text()', _, _NSArray))[1];
            ____.Utdelningsadress2               := (xpath(_xpathbase2 || '/spako:Utdelningsadress2/text()', _, _NSArray))[1];
            ____.PostNr                          := (xpath(_xpathbase2 || '/spako:PostNr/text()', _, _NSArray))[1];
            ____.Postort                         := (xpath(_xpathbase2 || '/spako:Postort/text()', _, _NSArray))[1];
            ____.Land                            := 'Sverige';
            ____.FolkbokfordLanKod               := (xpath(_xpathbase2 || '/spako:FolkbokfordLanKod/text()', _, _NSArray))[1];
            ____.FolkbokfordKommunKod            := (xpath(_xpathbase2 || '/spako:FolkbokfordKommunKod/text()', _, _NSArray))[1];
            ____.FolkbokfordForsamlingKod        := (xpath(_xpathbase2 || '/spako:FolkbokfordForsamlingKod/text()', _, _NSArray))[1];
            ____.Folkbokforingsdatum             := (xpath(_xpathbase2 || '/spako:Folkbokforingsdatum/text()', _, _NSArray))[1];

            SPARAdress := array_append(SPARAdress, ____);
        END LOOP;

        _cnt2 := 0;
        FOR _dummy2 IN SELECT unnest(xpath(_xpathbase1 || '/spako:SarskildPostadress', _, _NSArray)) LOOP
            _cnt2 := _cnt2 + 1;
            _xpathbase2 := _xpathbase1 || '/spako:SarskildPostadress[' || _cnt2 || ']';

            ____ := ___;
            ____.AdressTyp                       := 'S';

            ____.FysiskPersonId                  := SPARdata.FysiskPersonId;
            ____.CareOf                          := (xpath(_xpathbase2 || '/spako:CareOf/text()', _, _NSArray))[1];
            ____.Utdelningsadress1               := (xpath(_xpathbase2 || '/spako:Utdelningsadress1/text()', _, _NSArray))[1];
            ____.Utdelningsadress2               := (xpath(_xpathbase2 || '/spako:Utdelningsadress2/text()', _, _NSArray))[1];
            ____.PostNr                          := (xpath(_xpathbase2 || '/spako:PostNr/text()', _, _NSArray))[1];
            ____.Postort                         := (xpath(_xpathbase2 || '/spako:Postort/text()', _, _NSArray))[1];
            ____.Land                            := 'Sverige';

            SPARAdress := array_append(SPARAdress, ____);
        END LOOP;

        _cnt2 := 0;
        FOR _dummy2 IN SELECT unnest(xpath(_xpathbase1 || '/spako:Utlandsadress', _, _NSArray)) LOOP
            _cnt2 := _cnt2 + 1;
            _xpathbase2 := _xpathbase1 || '/spako:Utlandsadress[' || _cnt2 || ']';

            ____ := ___;
            ____.AdressTyp                       := 'U';

            ____.FysiskPersonId                  := SPARdata.FysiskPersonId;
            ____.Utdelningsadress1               := (xpath(_xpathbase2 || '/spako:Utdelningsadress1/text()', _, _NSArray))[1];
            ____.Utdelningsadress2               := (xpath(_xpathbase2 || '/spako:Utdelningsadress2/text()', _, _NSArray))[1];
            ____.Utdelningsadress3               := (xpath(_xpathbase2 || '/spako:Utdelningsadress3/text()', _, _NSArray))[1];
            ____.Land                            := (xpath(_xpathbase2 || '/spako:Land/text()', _, _NSArray))[1];

            SPARAdress := array_append(SPARAdress, ____);
        END LOOP;
    END LOOP;

    RETURN NEXT;
END LOOP;

END;
$BODY$ LANGUAGE plpgsql;

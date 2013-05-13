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

        _dummy xml;
        _cnt integer;
        _xpathbase text;
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
    _cnt := 0;
    FOR _dummy IN SELECT unnest(xpath('/spako:PersonsokningSvarsPost/spako:Persondetaljer', _, _NSArray)) LOOP
        _cnt := _cnt + 1;
        _xpathbase := '/spako:PersonsokningSvarsPost/spako:Persondetaljer[' || _cnt || ']';

        __.DatumFrom                       := (xpath(_xpathbase || '/spako:DatumFrom/text()', _, _NSArray))[1];
        _DateTmp := (xpath(_xpathbase || '/spako:DatumTom/text()', _, _NSArray))[1]; 
        IF _DateTmp IS NOT NULL AND _DateTmp <> '9999-12-31' THEN
            __.DatumTom                        := _DateTmp;
        END IF;
        __.Aviseringsnamn                  := (xpath(_xpathbase || '/spako:Aviseringsnamn/text()', _, _NSArray))[1];
        __.Fornamn                         := (xpath(_xpathbase || '/spako:Fornamn/text()', _, _NSArray))[1];
        __.Tilltalsnamn                    := (xpath(_xpathbase || '/spako:Tilltalsnamn/text()', _, _NSArray))[1];
        __.Mellannamn                      := (xpath(_xpathbase || '/spako:Mellannamn/text()', _, _NSArray))[1];
        __.Efternamn                       := (xpath(_xpathbase || '/spako:Efternamn/text()', _, _NSArray))[1];
        __.HanvisningspersonNrByttTill     := (xpath(_xpathbase || '/spako:HanvisningsPersonNrByttTill/text()', _, _NSArray))[1];
        __.HanvisningspersonNrByttFran     := (xpath(_xpathbase || '/spako:HanvisningsPersonNrByttFran/text()', _, _NSArray))[1];
        __.Avregistreringsdatum            := (xpath(_xpathbase || '/spako:Avregistreringsdatum/text()', _, _NSArray))[1];
        __.AvregistreringsorsakKod         := (xpath(_xpathbase || '/spako:AvregistreringsorsakKod/text()', _, _NSArray))[1];
        __.Fodelsetid                      := (xpath(_xpathbase || '/spako:Fodelsetid/text()', _, _NSArray))[1];
        __.Kon                             := (xpath(_xpathbase || '/spako:Kon/text()', _, _NSArray))[1];
        SPARPerson := array_append(SPARPerson, __);
    END LOOP;

    _cnt := 0;
    FOR _dummy IN SELECT unnest(xpath('/spako:PersonsokningSvarsPost/spako:Adress', _, _NSArray)) LOOP
        _cnt := _cnt + 1;
        _xpathbase := '/spako:PersonsokningSvarsPost/spako:Adress[' || _cnt || ']';

        ___.DatumFrom                       := (xpath(_xpathbase || '/spako:DatumFrom/text()', _, _NSArray))[1];

        _DateTmp := (xpath(_xpathbase || '/spako:DatumTom/text()', _, _NSArray))[1]; 
        IF _DateTmp IS NOT NULL AND _DateTmp <> '9999-12-31' THEN
            ___.DatumTom                        := _DateTmp;
        END IF;

        IF xpath_exists(_xpathbase || '/spako:Folkbokforingsadress', _, _NSArray) THEN
            ___.AdressTyp                       := 'F';

            ___.CareOf                          := (xpath(_xpathbase || '/spako:Folkbokforingsadress/spako:CareOf/text()', _, _NSArray))[1];
            ___.Utdelningsadress1               := (xpath(_xpathbase || '/spako:Folkbokforingsadress/spako:Utdelningsadress1/text()', _, _NSArray))[1];
            ___.Utdelningsadress2               := (xpath(_xpathbase || '/spako:Folkbokforingsadress/spako:Utdelningsadress2/text()', _, _NSArray))[1];
            ___.PostNr                          := (xpath(_xpathbase || '/spako:Folkbokforingsadress/spako:PostNr/text()', _, _NSArray))[1];
            ___.Postort                         := (xpath(_xpathbase || '/spako:Folkbokforingsadress/spako:Postort/text()', _, _NSArray))[1];
            ___.Land                            := 'Sverige';
            ___.FolkbokfordLanKod               := (xpath(_xpathbase || '/spako:Folkbokforingsadress/spako:FolkbokfordLanKod/text()', _, _NSArray))[1];
            ___.FolkbokfordKommunKod            := (xpath(_xpathbase || '/spako:Folkbokforingsadress/spako:FolkbokfordKommunKod/text()', _, _NSArray))[1];
            ___.FolkbokfordForsamlingKod        := (xpath(_xpathbase || '/spako:Folkbokforingsadress/spako:FolkbokfordForsamlingKod/text()', _, _NSArray))[1];
            ___.Folkbokforingsdatum             := (xpath(_xpathbase || '/spako:Folkbokforingsadress/spako:Folkbokforingsdatum/text()', _, _NSArray))[1];

        ELSIF xpath_exists(_xpathbase || '/spako:SarskildPostadress', _, _NSArray) THEN
            ___.AdressTyp                       := 'S';

            ___.CareOf                          := (xpath(_xpathbase || '/spako:SarskildPostadress/spako:CareOf/text()', _, _NSArray))[1];
            ___.Utdelningsadress1               := (xpath(_xpathbase || '/spako:SarskildPostadress/spako:Utdelningsadress1/text()', _, _NSArray))[1];
            ___.Utdelningsadress2               := (xpath(_xpathbase || '/spako:SarskildPostadress/spako:Utdelningsadress2/text()', _, _NSArray))[1];
            ___.PostNr                          := (xpath(_xpathbase || '/spako:SarskildPostadress/spako:PostNr/text()', _, _NSArray))[1];
            ___.Postort                         := (xpath(_xpathbase || '/spako:SarskildPostadress/spako:Postort/text()', _, _NSArray))[1];
            ___.Land                            := 'Sverige';

        ELSIF xpath_exists(_xpathbase || '/spako:Utlandsadress', _, _NSArray) THEN
            ___.AdressTyp                       := 'U';

            ___.Utdelningsadress1               := (xpath(_xpathbase2 || '/spako:Utlandsadress/spako:Utdelningsadress1/text()', _, _NSArray))[1];
            ___.Utdelningsadress2               := (xpath(_xpathbase2 || '/spako:Utlandsadress/spako:Utdelningsadress2/text()', _, _NSArray))[1];
            ___.Utdelningsadress3               := (xpath(_xpathbase2 || '/spako:Utlandsadress/spako:Utdelningsadress3/text()', _, _NSArray))[1];
            ___.Land                            := (xpath(_xpathbase2 || '/spako:Utlandsadress/spako:Land/text()', _, _NSArray))[1];
        END IF;

        SPARAdress := array_append(SPARAdress, ___);
    END LOOP;

    RETURN NEXT;
END LOOP;

END;
$BODY$ LANGUAGE plpgsql;

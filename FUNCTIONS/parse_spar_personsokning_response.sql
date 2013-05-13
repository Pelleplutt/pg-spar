CREATE OR REPLACE FUNCTION Parse_SPAR_PersonSokning_Response(
        _XML xml,
        OUT SPARdata SPARPersonData,
        OUT SPARAdress SPARPersonAdress[],
        OUT SPARPerson SPARPersonDetaljer[]
) RETURNS SETOF RECORD AS $BODY$
DECLARE
        _NSArray text[];
        _DateTmp text;

        _pdr SPARPersonDetaljer;
        _adr SPARPersonAdress;

        _pda xml;

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

FOR _pda IN SELECT unnest(xpath('/soapenv:Envelope/soapenv:Body/spain:SPARPersonsokningSvar/spako:PersonsokningSvarsPost', _XML, _NSArray)) LOOP

    SPARdata.FysiskPersonId                   := (xpath('/spako:PersonsokningSvarsPost/spako:PersonId/spako:FysiskPersonId/text()', _pda, _NSArray))[1];
    SPARdata.Sekretessmarkering               := (xpath('/spako:PersonsokningSvarsPost/spako:Sekretessmarkering/text()', _pda, _NSArray))[1];
    SPARdata.SekretessAndringsdatum           := (xpath('/spako:PersonsokningSvarsPost/spako:SekretessAndringsdatum/text()', _pda, _NSArray))[1];
    SPARdata.SenasteAndringFolkbokforing      := (xpath('/spako:PersonsokningSvarsPost/spako:SenasteAndringFolkbokforing/text()', _pda, _NSArray))[1];


        -- This is really poor code and I wish I could find another way of
        -- doing this. I ideally would like to loop over the xpath return as one would
        -- expect. But doing to causes a returned XML root element without namespace
        -- definition and the sub-elements are in the "spako" namespace, it seems
        -- impossible to convince xpath to give me the contents of those elements without
        -- croaking. 
    _cnt := 0;
    FOR _dummy IN SELECT unnest(xpath('/spako:PersonsokningSvarsPost/spako:Persondetaljer', _pda, _NSArray)) LOOP
        _cnt := _cnt + 1;
        _xpathbase := '/spako:PersonsokningSvarsPost/spako:Persondetaljer[' || _cnt || ']';

        _pdr.DatumFrom                       := (xpath(_xpathbase || '/spako:DatumFrom/text()', _pda, _NSArray))[1];
        _DateTmp := (xpath(_xpathbase || '/spako:DatumTom/text()', _pda, _NSArray))[1]; 
        IF _DateTmp IS NOT NULL AND _DateTmp <> '9999-12-31' THEN
            _pdr.DatumTom                        := _DateTmp;
        END IF;
        _pdr.Aviseringsnamn                  := (xpath(_xpathbase || '/spako:Aviseringsnamn/text()', _pda, _NSArray))[1];
        _pdr.Fornamn                         := (xpath(_xpathbase || '/spako:Fornamn/text()', _pda, _NSArray))[1];
        _pdr.Tilltalsnamn                    := (xpath(_xpathbase || '/spako:Tilltalsnamn/text()', _pda, _NSArray))[1];
        _pdr.Mellannamn                      := (xpath(_xpathbase || '/spako:Mellannamn/text()', _pda, _NSArray))[1];
        _pdr.Efternamn                       := (xpath(_xpathbase || '/spako:Efternamn/text()', _pda, _NSArray))[1];
        _pdr.HanvisningspersonNrByttTill     := (xpath(_xpathbase || '/spako:HanvisningsPersonNrByttTill/text()', _pda, _NSArray))[1];
        _pdr.HanvisningspersonNrByttFran     := (xpath(_xpathbase || '/spako:HanvisningsPersonNrByttFran/text()', _pda, _NSArray))[1];
        _pdr.Avregistreringsdatum            := (xpath(_xpathbase || '/spako:Avregistreringsdatum/text()', _pda, _NSArray))[1];
        _pdr.AvregistreringsorsakKod         := (xpath(_xpathbase || '/spako:AvregistreringsorsakKod/text()', _pda, _NSArray))[1];
        _pdr.Fodelsetid                      := (xpath(_xpathbase || '/spako:Fodelsetid/text()', _pda, _NSArray))[1];
        _pdr.Kon                             := (xpath(_xpathbase || '/spako:Kon/text()', _pda, _NSArray))[1];
        SPARPerson := array_append(SPARPerson, _pdr);
    END LOOP;

    _cnt := 0;
    FOR _dummy IN SELECT unnest(xpath('/spako:PersonsokningSvarsPost/spako:Adress', _pda, _NSArray)) LOOP
        _cnt := _cnt + 1;
        _xpathbase := '/spako:PersonsokningSvarsPost/spako:Adress[' || _cnt || ']';

        _adr.DatumFrom                       := (xpath(_xpathbase || '/spako:DatumFrom/text()', _pda, _NSArray))[1];

        _DateTmp := (xpath(_xpathbase || '/spako:DatumTom/text()', _pda, _NSArray))[1]; 
        IF _DateTmp IS NOT NULL AND _DateTmp <> '9999-12-31' THEN
            _adr.DatumTom                        := _DateTmp;
        END IF;

        IF xpath_exists(_xpathbase || '/spako:Folkbokforingsadress', _pda, _NSArray) THEN
            _adr.AdressTyp                       := 'F';

            _adr.CareOf                          := (xpath(_xpathbase || '/spako:Folkbokforingsadress/spako:CareOf/text()', _pda, _NSArray))[1];
            _adr.Utdelningsadress1               := (xpath(_xpathbase || '/spako:Folkbokforingsadress/spako:Utdelningsadress1/text()', _pda, _NSArray))[1];
            _adr.Utdelningsadress2               := (xpath(_xpathbase || '/spako:Folkbokforingsadress/spako:Utdelningsadress2/text()', _pda, _NSArray))[1];
            _adr.PostNr                          := (xpath(_xpathbase || '/spako:Folkbokforingsadress/spako:PostNr/text()', _pda, _NSArray))[1];
            _adr.Postort                         := (xpath(_xpathbase || '/spako:Folkbokforingsadress/spako:Postort/text()', _pda, _NSArray))[1];
            _adr.Land                            := 'Sverige';
            _adr.FolkbokfordLanKod               := (xpath(_xpathbase || '/spako:Folkbokforingsadress/spako:FolkbokfordLanKod/text()', _pda, _NSArray))[1];
            _adr.FolkbokfordKommunKod            := (xpath(_xpathbase || '/spako:Folkbokforingsadress/spako:FolkbokfordKommunKod/text()', _pda, _NSArray))[1];
            _adr.FolkbokfordForsamlingKod        := (xpath(_xpathbase || '/spako:Folkbokforingsadress/spako:FolkbokfordForsamlingKod/text()', _pda, _NSArray))[1];
            _adr.Folkbokforingsdatum             := (xpath(_xpathbase || '/spako:Folkbokforingsadress/spako:Folkbokforingsdatum/text()', _pda, _NSArray))[1];

        ELSIF xpath_exists(_xpathbase || '/spako:SarskildPostadress', _pda, _NSArray) THEN
            _adr.AdressTyp                       := 'S';

            _adr.CareOf                          := (xpath(_xpathbase || '/spako:SarskildPostadress/spako:CareOf/text()', _pda, _NSArray))[1];
            _adr.Utdelningsadress1               := (xpath(_xpathbase || '/spako:SarskildPostadress/spako:Utdelningsadress1/text()', _pda, _NSArray))[1];
            _adr.Utdelningsadress2               := (xpath(_xpathbase || '/spako:SarskildPostadress/spako:Utdelningsadress2/text()', _pda, _NSArray))[1];
            _adr.PostNr                          := (xpath(_xpathbase || '/spako:SarskildPostadress/spako:PostNr/text()', _pda, _NSArray))[1];
            _adr.Postort                         := (xpath(_xpathbase || '/spako:SarskildPostadress/spako:Postort/text()', _pda, _NSArray))[1];
            _adr.Land                            := 'Sverige';

        ELSIF xpath_exists(_xpathbase || '/spako:Utlandsadress', _pda, _NSArray) THEN
            _adr.AdressTyp                       := 'U';

            _adr.Utdelningsadress1               := (xpath(_xpathbase2 || '/spako:Utlandsadress/spako:Utdelningsadress1/text()', _pda, _NSArray))[1];
            _adr.Utdelningsadress2               := (xpath(_xpathbase2 || '/spako:Utlandsadress/spako:Utdelningsadress2/text()', _pda, _NSArray))[1];
            _adr.Utdelningsadress3               := (xpath(_xpathbase2 || '/spako:Utlandsadress/spako:Utdelningsadress3/text()', _pda, _NSArray))[1];
            _adr.Land                            := (xpath(_xpathbase2 || '/spako:Utlandsadress/spako:Land/text()', _pda, _NSArray))[1];
        END IF;

        SPARAdress := array_append(SPARAdress, _adr);
    END LOOP;

    RETURN NEXT;
END LOOP;

END;
$BODY$ LANGUAGE plpgsql;

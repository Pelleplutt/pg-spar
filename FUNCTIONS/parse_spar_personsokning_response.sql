CREATE OR REPLACE FUNCTION Parse_SPAR_PersonSokning_Response(
    OUT FysiskPersonId text,
    _XML xml
) RETURNS SETOF TEXT
LANGUAGE plpgsql VOLATILE
AS $BODY$

DECLARE
    _NSArray text[];
    _NSNames text[];
    _DateTmp text;

    _xml1 xml;
    _xml2 xml;
    _xml3 xml;

    __ SPARPersonDetaljer;
    ___ SPARPersonAdress;
    ____ SPARPersonAdress;

    _spardata SPARPersonData;
    _sparadresser SPARPersonAdress[];
    _sparpersoner SPARPersonDetaljer[];
BEGIN

_NSArray := ARRAY[
    ['soapenv', 'http://schemas.xmlsoap.org/soap/envelope/'],
    ['xsd','http://www.w3.org/2001/XMLSchema'],
    ['xsi','http://www.w3.org/2001/XMLSchema-instance'],
    ['spako','http://skatteverket.se/spar/komponent/1.0'],
    ['spain','http://skatteverket.se/spar/instans/1.0']
];

_NSNames := ARRAY[
    'spako',
    'ns1'
];

FOR _xml1 IN SELECT unnest(xpath('/soapenv:Envelope/soapenv:Body/spain:SPARPersonsokningSvar/spako:PersonsokningSvarsPost', _XML, _NSArray)) LOOP

    _spardata.FysiskPersonId                   := (xpath('/spako:PersonsokningSvarsPost/spako:PersonId/spako:FysiskPersonId/text()', _xml1, _NSArray))[1];
    _spardata.Sekretessmarkering               := (xpath('/spako:PersonsokningSvarsPost/spako:Sekretessmarkering/text()', _xml1, _NSArray))[1];
    _spardata.SekretessAndringsdatum           := (xpath('/spako:PersonsokningSvarsPost/spako:SekretessAndringsdatum/text()', _xml1, _NSArray))[1];
    _spardata.SenasteAndringFolkbokforing      := (xpath('/spako:PersonsokningSvarsPost/spako:SenasteAndringFolkbokforing/text()', _xml1, _NSArray))[1];

    FOR _xml2 IN SELECT unnest(xpath('/spako:PersonsokningSvarsPost/spako:Persondetaljer', _xml1, _NSArray)) LOOP

        __.DatumFrom                       := (xpath_fragment('/spako:Persondetaljer/spako:DatumFrom/text()', _xml2, _NSNames))[1];
        _DateTmp := (xpath_fragment('/spako:Persondetaljer/spako:DatumTom/text()', _xml2, _NSNames))[1];
        IF _DateTmp IS NOT NULL AND _DateTmp <> '9999-12-31' THEN
            __.DatumTom                        := _DateTmp;
        END IF;
        __.FysiskPersonId                  := _spardata.FysiskPersonId;
        __.Aviseringsnamn                  := (xpath_fragment('/spako:Persondetaljer/spako:Aviseringsnamn/text()', _xml2, _NSNames))[1];
        __.Fornamn                         := (xpath_fragment('/spako:Persondetaljer/spako:Fornamn/text()', _xml2, _NSNames))[1];
        __.Tilltalsnamn                    := (xpath_fragment('/spako:Persondetaljer/spako:Tilltalsnamn/text()', _xml2, _NSNames))[1];
        __.Mellannamn                      := (xpath_fragment('/spako:Persondetaljer/spako:Mellannamn/text()', _xml2, _NSNames))[1];
        __.Efternamn                       := (xpath_fragment('/spako:Persondetaljer/spako:Efternamn/text()', _xml2, _NSNames))[1];
        __.HanvisningspersonNrByttTill     := (xpath_fragment('/spako:Persondetaljer/spako:HanvisningsPersonNrByttTill/text()', _xml2, _NSNames))[1];
        __.HanvisningspersonNrByttFran     := (xpath_fragment('/spako:Persondetaljer/spako:HanvisningsPersonNrByttFran/text()', _xml2, _NSNames))[1];
        __.Avregistreringsdatum            := (xpath_fragment('/spako:Persondetaljer/spako:Avregistreringsdatum/text()', _xml2, _NSNames))[1];
        __.AvregistreringsorsakKod         := (xpath_fragment('/spako:Persondetaljer/spako:AvregistreringsorsakKod/text()', _xml2, _NSNames))[1];
        __.Fodelsetid                      := (xpath_fragment('/spako:Persondetaljer/spako:Fodelsetid/text()', _xml2, _NSNames))[1];
        __.Kon                             := (xpath_fragment('/spako:Persondetaljer/spako:Kon/text()', _xml2, _NSNames))[1];

        _sparpersoner := array_append(_sparpersoner, __);
        __ := NULL;
    END LOOP;

    FOR _xml2 IN SELECT unnest(xpath('/spako:PersonsokningSvarsPost/spako:Adress', _xml1, _NSArray)) LOOP

        ___.DatumFrom                       := (xpath_fragment('/spako:Adress/spako:DatumFrom/text()', _xml2, _NSNames))[1];
        ___.FysiskPersonId                  := _spardata.FysiskPersonId;

        _DateTmp := (xpath_fragment('/spako:Adress/spako:DatumTom/text()', _xml2, _NSNames))[1];
        IF _DateTmp IS NOT NULL AND _DateTmp <> '9999-12-31' THEN
            ___.DatumTom                        := _DateTmp;
        END IF;

        FOR _xml3 IN SELECT unnest(xpath_fragment('/spako:Adress/spako:Folkbokforingsadress', _xml2, _NSNames)) LOOP

            ____ := ___;
            ____.AdressTyp                       := 'F';

            ____.CareOf                          := (xpath_fragment('/spako:Folkbokforingsadress/spako:CareOf/text()', _xml3, _NSNames))[1];
            ____.Utdelningsadress1               := (xpath_fragment('/spako:Folkbokforingsadress/spako:Utdelningsadress1/text()', _xml3, _NSNames))[1];
            ____.Utdelningsadress2               := (xpath_fragment('/spako:Folkbokforingsadress/spako:Utdelningsadress2/text()', _xml3, _NSNames))[1];
            ____.PostNr                          := (xpath_fragment('/spako:Folkbokforingsadress/spako:PostNr/text()', _xml3, _NSNames))[1];
            ____.Postort                         := (xpath_fragment('/spako:Folkbokforingsadress/spako:Postort/text()', _xml3, _NSNames))[1];
            ____.Land                            := 'Sverige';
            ____.FolkbokfordLanKod               := (xpath_fragment('/spako:Folkbokforingsadress/spako:FolkbokfordLanKod/text()', _xml3, _NSNames))[1];
            ____.FolkbokfordKommunKod            := (xpath_fragment('/spako:Folkbokforingsadress/spako:FolkbokfordKommunKod/text()', _xml3, _NSNames))[1];
            ____.FolkbokfordForsamlingKod        := (xpath_fragment('/spako:Folkbokforingsadress/spako:FolkbokfordForsamlingKod/text()', _xml3, _NSNames))[1];
            ____.Folkbokforingsdatum             := (xpath_fragment('/spako:Folkbokforingsadress/spako:Folkbokforingsdatum/text()', _xml3, _NSNames))[1];

            IF ____.Utdelningsadress2 ~* '\s+(LGH|LÄG)\s+\d+$' THEN
                ____.Lagenhet = regexp_replace(____.Utdelningsadress2, '.*\s+(LGH|LÄG)\s+(\d+)$', '\2');
                ____.Utdelningsadress2 = regexp_replace(____.Utdelningsadress2, '\s+(LGH|LÄG)\s+[0-9]+$', '');
            END IF;

            _sparadresser := array_append(_sparadresser, ____);
        END LOOP;

        FOR _xml3 IN SELECT unnest(xpath_fragment('/spako:Adress/spako:SarskildPostadress', _xml2, _NSNames)) LOOP

            ____ := ___;
            ____.AdressTyp                       := 'S';

            ____.CareOf                          := (xpath_fragment('/spako:SarskildPostadress/spako:CareOf/text()', _xml3, _NSNames))[1];
            ____.Utdelningsadress1               := (xpath_fragment('/spako:SarskildPostadress/spako:Utdelningsadress1/text()', _xml3, _NSNames))[1];
            ____.Utdelningsadress2               := (xpath_fragment('/spako:SarskildPostadress/spako:Utdelningsadress2/text()', _xml3, _NSNames))[1];
            ____.PostNr                          := (xpath_fragment('/spako:SarskildPostadress/spako:PostNr/text()', _xml3, _NSNames))[1];
            ____.Postort                         := (xpath_fragment('/spako:SarskildPostadress/spako:Postort/text()', _xml3, _NSNames))[1];
            ____.Land                            := 'Sverige';

            IF ____.Utdelningsadress2 ~* '\s+(LGH|LÄG)\s+\d+$' THEN
                ____.Lagenhet = regexp_replace(____.Utdelningsadress2, '.*\s+(LGH|LÄG)\s+(\d+)$', '\2');
                ____.Utdelningsadress2 = regexp_replace(____.Utdelningsadress2, '\s+(LGH|LÄG)\s+[0-9]+$', '');
            END IF;

            _sparadresser := array_append(_sparadresser, ____);
        END LOOP;

        FOR _xml3 IN SELECT unnest(xpath_fragment('/spako:Adress/spako:Utlandsadress', _xml2, _NSNames)) LOOP

            ____ := ___;
            ____.AdressTyp                       := 'U';

            ____.Utdelningsadress1               := (xpath_fragment('/spako:Utlandsadress/spako:Utdelningsadress1/text()', _xml3, _NSNames))[1];
            ____.Utdelningsadress2               := (xpath_fragment('/spako:Utlandsadress/spako:Utdelningsadress2/text()', _xml3, _NSNames))[1];
            ____.Utdelningsadress3               := (xpath_fragment('/spako:Utlandsadress/spako:Utdelningsadress3/text()', _xml3, _NSNames))[1];
            ____.Land                            := (xpath_fragment('/spako:Utlandsadress/spako:Land/text()', _xml3, _NSNames))[1];

            _sparadresser := array_append(_sparadresser, ____);
        END LOOP;

            -- Handle no adress given
        IF NOT (xpath_exists_fragment('/spako:Adress/spako:Utlandsadress', _xml2, _NSNames) OR
                xpath_exists_fragment('/spako:Adress/spako:SarskildPostadress', _xml2, _NSNames) OR
                xpath_exists_fragment('/spako:Adress/spako:Folkbokforingsadress', _xml2, _NSNames)) THEN

            _sparadresser := array_append(_sparadresser, ___);
        END IF;
        ___ := NULL;
    END LOOP;

    IF _sparpersoner IS NOT NULL THEN
        PERFORM Save_SPAR_PersonSokning(_spardata, _sparadresser, _sparpersoner);
        FysiskPersonId := _spardata.FysiskPersonId;
        RETURN NEXT;
    END IF;

    _spardata := NULL;
    _sparadresser := NULL;
    _sparpersoner := NULL;
END LOOP;

RETURN;

END;
$BODY$;

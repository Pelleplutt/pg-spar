CREATE OR REPLACE FUNCTION Format_SPAR_Adress_Query(
    _KundNr text,
    _OrgNr text,
    _SlutAnvandarId text,
    _SlutAnvandarBehorighet text,
    _SlutAnvandarSekretessRatt text,
    _FonetiskSokning boolean,
    _Namn text,
    _Fornamn text,
    _MellanEfternamn text,
    _Utdelningsadress text,
    _PostOrt text,
    _PostNr text,
    _PostNrFran text,
    _PostNrTill text,
    _Fodelsetid date,
    _FodelsetidFran date,
    _FodelsetidTill date,
    _Kon text,
    _LanKod text,
    _KommunKod text,
    _ForsamlingKod text
) RETURNS xml
LANGUAGE plpgsql STABLE
AS $BODY$

DECLARE
_Identity xml;
_SOAPBody xml;
_SOAPEnvelope xml;

_FonetiskSokningSok xml;
_NamnSok xml;
_FornamnSok xml;
_MellanEfternamnSok xml;

_UtdelningsadressSok xml;
_PostOrtSok xml;

_PostNrSok xml;
_PostNrTillSok xml;
_PostNrFranSok xml;

_FodelsetidSok xml;
_FodelsetidFranSok xml;
_FodelsetidTillSok xml;

_KonSok xml;
_LanKodSok xml;
_KommunKodSok xml;
_ForsamlingKodSok xml;

BEGIN

_Identity := Format_SPAR_Identity(_KundNr, _OrgNr, _SlutAnvandarId, _SlutAnvandarBehorighet, _SlutAnvandarSekretessRatt);

IF _FonetiskSokning = TRUE THEN
    _FonetiskSokningSok := xmlelement(
        name "spako:FonetiskSokning",
        'J'
    );
ELSE
    _FonetiskSokningSok := xmlelement(
        name "spako:FonetiskSokning",
        'N'
    );
END IF;

IF _Namn IS NOT NULL THEN
    _NamnSok := xmlelement(
        name "spako:NamnSokArgument",
        _Namn
    );
ELSE
    IF _Fornamn IS NOT NULL THEN
        _FornamnSok := xmlelement(
            name "spako:FornamnSokArgument",
            _ForNamn
        );
    END IF;
    IF _MellanEfternamn IS NOT NULL THEN
        _MellanEfternamnSok := xmlelement(
            name "spako:MellanEfternamnSokArgument",
            _MellanEfternamn
        );
    END IF;
END IF;

IF _Utdelningsadress IS NOT NULL THEN
    _UtdelningsadressSok := xmlelement(
        name "spako:UtdelningsadressSokArgument",
        _Utdelningsadress
    );
END IF;

IF _PostOrt IS NOT NULL THEN
    _PostOrtSok := xmlelement(
        name "spako:PostortSokArgument",
        _PostOrt
    );
END IF;

IF _PostNr IS NOT NULL THEN
    _PostNrSok := xmlelement(
        name "spako:PostNr",
        _PostNr
    );
ELSIF _PostNrFran IS NOT NULL AND _PostNrTill IS NOT NULL THEN
    _PostNrFranSok := xmlelement(
        name "spako:PostNrFran",
        _PostNrFran
    );
    _PostNrTillSok := xmlelement(
        name "spako:PostNrTill",
        _PostNrTill
    );
END IF;

IF _Fodelsetid IS NOT NULL THEN
    _FodelsetidSok := xmlelement(
        name "spako:Fodelsetid",
        _Fodelsetid
    );
ELSIF _FodelsetidFran IS NOT NULL AND _FodelsetidTill IS NOT NULL THEN
    _FodelsetidFranSok := xmlelement(
        name "spako:FodelsetidFran",
        _FodelsetidFran
    );
    _FodelsetidTillSok := xmlelement(
        name "spako:FodelsetidTill",
        _FodelsetidTill
    );
END IF;

IF _Kon IS NOT NULL THEN
    _KonSok := xmlelement(
        name "spako:Kon",
        _Kon
    );
END IF;

IF _LanKod IS NOT NULL THEN
    _LanKodSok := xmlelement(
        name "spako:LanKod",
        _LanKod
    );
END IF;

IF _KommunKod IS NOT NULL THEN
    _KommunKodSok := xmlelement(
        name "spako:KommunKod",
        _KommunKod
    );
END IF;

IF _ForsamlingKod IS NOT NULL THEN
    _ForsamlingKodSok := xmlelement(
        name "spako:ForsamlingKod",
        _ForsamlingKod
    );
END IF;

_SOAPBody := xmlelement(
            name "spain:SPARPersonsokningFraga",
            xmlattributes(
                'http://skatteverket.se/spar/komponent/1.0' AS "xmlns:spako",
                'http://skatteverket.se/spar/instans/1.0' AS "xmlns:spain"
            ),
            _Identity,
            xmlelement(
                name "spako:PersonsokningFraga",

                _FonetiskSokningSok,
                _NamnSok,
                _FornamnSok,
                _MellanEfternamnSok,

                _UtdelningsadressSok,
                _PostOrtSok,

                _PostNrSok,
                _PostNrFranSok,
                _PostNrTillSok,

                _FodelsetidSok,
                _FodelsetidFranSok,
                _FodelsetidTillSok,

                _KonSok,
                _LanKodSok,
                _KommunKodSok,
                _ForsamlingKodSok
            )
        );

_SOAPEnvelope := Format_SPAR_SOAP_Envelope(_SOAPBody);

RETURN _SOAPEnvelope;

END;
$BODY$;

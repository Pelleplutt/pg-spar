CREATE OR REPLACE FUNCTION Format_SPAR_Adress_Query(
    _KundNr text,
    _OrgNr text,
    _SlutAnvandarId text,
    _SlutAnvandarBehorighet text,
    _SlutAnvandarSekretessRatt text,
    _Namn text,
    _Utdelningsadress text,
    _PostNr text
) RETURNS xml AS $BODY$
DECLARE
_Identity xml;
_SOAPBody xml;
_SOAPEnvelope xml;
BEGIN

SELECT
    *
INTO
    _Identity
FROM
    Format_SPAR_Identity(_KundNr, _OrgNr, _SlutAnvandarId, _SlutAnvandarBehorighet, _SlutAnvandarSekretessRatt);


_SOAPBody := xmlelement(
            name "spain:SPARPersonsokningFraga",
            xmlattributes(
                'http://skatteverket.se/spar/komponent/1.0' AS "xmlns:spako",
                'http://skatteverket.se/spar/instans/1.0' AS "xmlns:spain"
            ),
            _Identity,
            xmlelement(
                name "spako:PersonsokningFraga",
                xmlelement(
                    name "spako:NamnSokArgument",
                    _Namn
                ),
                xmlelement(
                    name "spako:UtdelningsadressSokArgument", 
                    _Utdelningsadress
                ),
                xmlelement(
                    name "spako:PostNr", 
                    _PostNr
                )
            )
        );

SELECT
    *
INTO
    _SOAPEnvelope
FROM
    Format_SPAR_SOAP_Envelope(_SOAPBody);

RETURN _SOAPEnvelope;

END;
$BODY$ LANGUAGE plpgsql STABLE;

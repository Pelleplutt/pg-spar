CREATE OR REPLACE FUNCTION Format_SPAR_Identity(
    _KundNr text,
    _OrgNr text,
    _SlutAnvandarId text,
    _SlutAnvandarBehorighet text,
    _SlutAnvandarSekretessRatt text
) RETURNS xml AS $BODY$
DECLARE
BEGIN

RETURN xmlelement(
    name "spako:IdentifieringsInformation",
    xmlattributes(
        'http://skatteverket.se/spar/komponent/1.0' AS "xmlns:spako"
    ),
    xmlelement(
        name "spako:KundNrLeveransMottagare", 
        _KundNr
    ),
    xmlelement(
        name "spako:KundNrSlutkund", 
        _KundNr
    ),
    xmlelement(
        name "spako:OrgNrSlutkund", 
        _OrgNr
    ),
    xmlelement(
        name "spako:SlutAnvandarId", 
        _SlutAnvandarId
    ),
    xmlelement(
        name "spako:SlutAnvandarBehorighet", 
        _SlutAnvandarBehorighet
    ),
    xmlelement(
        name "spako:SlutAnvandarSekretessRatt", 
        _SlutAnvandarSekretessRatt
    ),
    xmlelement(
        name "spako:Tidsstampel", 
        to_char(CURRENT_TIMESTAMP, 'YYYY-MM-DD"T"HH24:MI:SS.MS')
    )
);
END;
$BODY$ LANGUAGE plpgsql STABLE;

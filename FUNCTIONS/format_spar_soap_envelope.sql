CREATE OR REPLACE FUNCTION Format_SPAR_SOAP_Envelope(
    _SOAPBody xml
) RETURNS xml
LANGUAGE plpgsql IMMUTABLE
AS $BODY$

BEGIN

RETURN xmlelement(
    name "SOAP-ENV:Envelope",
    xmlattributes(
        'http://schemas.xmlsoap.org/soap/envelope/' AS "xmlns:SOAP-ENV",
        'http://www.w3.org/2001/XMLSchema-instance' AS "xmlns:xsi",
        'http://schemas.xmlsoap.org/soap/encoding/' AS "SOAP-ENV:encodingStyle"
    ),
    xmlelement(
        name "SOAP-ENV:Body",
        _SOAPBody
    )
);
END;
$BODY$;

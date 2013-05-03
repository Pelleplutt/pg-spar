CREATE OR REPLACE FUNCTION Format_SPAR_SOAP_Envelope(
		soap_body xml
	) RETURNS xml AS $BODY$
DECLARE
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
		soap_body
	)
);
END;
$BODY$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION Parse_SPAR_Response(
		_XML xml
	) RETURNS XML[] AS $BODY$
DECLARE
BEGIN

RETURN xpath(
	'/soapenv:Envelope/soapenv:Body/spako:PersonsokningSvarsPost/*',
	_XML,
	ARRAY[
		['soapenv', 'http://schemas.xmlsoap.org/soap/envelope/'],
		['xsd','http://www.w3.org/2001/XMLSchema'],
		['xsi','http://www.w3.org/2001/XMLSchema-instance'],
		['spako','http://skatteverket.se/spar/komponent/1.0'],
		['spain','http://skatteverket.se/spar/instans/1.0']
	]
);

END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Format_SPAR_Adress_Query(
	_KundNr text,
	_OrgNr text,
	_SlutAnvandarId text,
	_SlutAnvandarBehorighet text,
	_SlutAnvandarSekretessRatt text,
	_UtdelningsadressSokArgument text,
	_PostNr text
	) RETURNS xml AS $BODY$
DECLARE
	identity xml;
	soap_body xml;
	soap_envelope xml;

BEGIN

SELECT
	*
INTO
	identity
FROM
	Format_SPAR_Identity(_KundNr, _OrgNr, _SlutAnvandarId, _SlutAnvandarBehorighet, _SlutAnvandarSekretessRatt);


soap_body :=	xmlelement(
			name "spain:SPARPersonsokningFraga",
			xmlattributes(
				'http://skatteverket.se/spar/komponent/1.0' AS "xmlns:spako",
				'http://skatteverket.se/spar/instans/1.0' AS "xmlns:spain"
			),
			identity,
			xmlelement(
				name "spako:PersonsokningFraga",
				xmlelement(
					name "spako:UtdelningsadressSokArgument", 
					_UtdelningsadressSokArgument
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
	soap_envelope
FROM
	Format_SPAR_SOAP_Envelope(soap_body);

RETURN soap_envelope;

END;
$BODY$ LANGUAGE plpgsql;


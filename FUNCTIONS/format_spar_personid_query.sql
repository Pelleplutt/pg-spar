CREATE OR REPLACE FUNCTION Format_SPAR_PersonID_Request(
	_KundNr text,
	_OrgNr text,
	_UppdragsId text,
	_PersonID text
	) RETURNS xml AS $BODY$
DECLARE
BEGIN

RETURN xmlelement(
	name "soap:Envelope",
	xmlattributes(
		'http://www.w3.org/2001/12/soap-envelope' AS "xmlns:soap",
		'http://www.w3.org/2001/XMLSchema' AS "xmlns:xsd",
		'http://www.w3.org/2001/XMLSchema-instance' AS "xmlns:xsi",
		'http://www.w3.org/2001/12/soap-encoding' AS "soap:encodingStyle"
	),
	xmlelement(
		name "soap:Body",
		xmlelement(
			name "spain:SPARPersonsokningFraga",
			xmlattributes(
				'http://skatteverket.se/spar/komponent/1.0' AS "xmlns:spako",
				'http://skatteverket.se/spar/instans/1.0' AS "xmlns:spain"
			),
			xmlelement(
				name "IdentifieringsInformation",
				xmlattributes(
					'spako:IdentifieringsInformationTYPE' AS "xsi:type"
				),
				xmlelement(
					name "KundNrLeveransMottagare", 
					xmlattributes(
						'spako:KundNrTYPE' AS "xsi:type"
					),
					_KundNr
				),
				xmlelement(
					name "KundNrSlutkund", 
					xmlattributes(
						'spako:KundNrTYPE' AS "xsi:type"
					),
					_KundNr
				),
				xmlelement(
					name "OrgNrSlutkund", 
					xmlattributes(
						'spako:OrgNrTYPE' AS "xsi:type"
					),
					_OrgNr
				),
				xmlelement(
					name "UppdragsId", 
					xmlattributes(
						'spako:UppdragsIdTYPE' AS "xsi:type"
					),
					_UppdragsId
				),
				/*
				xmlelement(
					name "SlutAnvandarId", #FIXME (ej obl)
					xmlattributes(
						'spako:UppdragsIdTYPE' AS 'xsi:type',
					)
				),
				xmlelement(name "SlutAnvandarId", #FIXME _SlutAnvandarId),
				xmlelement(name "SlutAnvandarBehorighet", #FIXME _SlutAnvandarBehorighet),
				xmlelement(name "SlutAnvandarSekretessRatt", #FIXME _SlutAnvandarSekretessRatt),
				*/
				xmlelement(
					name "Tidsstampel", 
					xmlattributes(
						'spako:TidsstampelTYPE' AS "xsi:type"
					),
					to_char(CURRENT_TIMESTAMP, 'YYYY-MM-DD"T"HH24:MI:SS.MS')
				)
			),
			xmlelement(
				name "PersonsokningFraga",
				xmlattributes(
					'spako:PersonsokningFragaTYPE' AS "xsi:type"
				),
				xmlelement(name "PersonId", _PersonId)
			)
		)
	)
);
END;
$BODY$ LANGUAGE plpgsql;

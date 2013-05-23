CREATE OR REPLACE FUNCTION xpath_exists_fragment(_XPath text, _XML xml, _NSNames text[]) RETURNS BOOLEAN AS $BODY$
DECLARE
_ text;
_WrappedXML xml;
_NSArray text[][] := ARRAY[]::text[][];
BEGIN

SELECT ('<xml ' || array_to_string(array_agg('xmlns:' || unnest || '=" "'),' ') || '>' || _XML::text || '</xml>')::text INTO _WrappedXML FROM unnest(_NSNames);

FOR _ IN SELECT unnest(_NSNames)
LOOP
    _NSArray := _NSArray || ARRAY[[_, ' ']];
END LOOP;

RETURN xpath_exists('/xml' || _XPath, _WrappedXML, _NSArray);
END;
$BODY$ LANGUAGE plpgsql IMMUTABLE;

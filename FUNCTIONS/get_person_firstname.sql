CREATE OR REPLACE FUNCTION Get_Person_Firstname(
    _Fornamn text,
    _Tilltalsnamn text
) RETURNS text
LANGUAGE plpgsql IMMUTABLE
AS $BODY$
DECLARE
_Return text;
_Names text[];
_ text;

BEGIN

_Names := regexp_split_to_array(_Fornamn, ' ');

FOR _ IN SELECT unnest(regexp_split_to_array(_Tilltalsnamn, '')) LOOP
    IF _ = '0' THEN
        RETURN _Return;
    END IF;
    IF _::integer <= array_upper(_Names, 1) THEN
        IF _Return IS NOT NULL THEN
            _Return := _Return || '-' || _Names[_::integer];
        ELSE
            _Return := _Names[_::integer];
        END IF;
    ELSE
        RAISE WARNING 'Attempting to build first name from % %, but index % is out of bounds', _Fornamn, _Tilltalsnamn, _;
    END IF;
END LOOP;

IF _Return IS NULL THEN
    _Return := _Fornamn;
END IF;

RETURN _Return;

END;
$BODY$;

\set AUTOCOMMIT on

DROP DATABASE spartest;
CREATE DATABASE spartest;

\c spartest

CREATE LANGUAGE plperlu;

\i SEQUENCES/seqsparpersondetaljer.sql
\i SEQUENCES/seqsparpersonadress.sql
\i TABLES/sparconfig.sql
\i TABLES/sparpersondata.sql
\i TABLES/sparpersonadress.sql
\i TABLES/sparpersondetaljer.sql
\i FUNCTIONS/get_spar_config.sql
\i FUNCTIONS/http_post_xml.sql
\i FUNCTIONS/format_spar_soap_envelope.sql
\i FUNCTIONS/format_spar_identity.sql
\i FUNCTIONS/format_spar_adress_query.sql
\i FUNCTIONS/format_spar_personid_query.sql
\i FUNCTIONS/parse_spar_personsokning_response.sql
\i FUNCTIONS/save_spar_personsokning.sql
\i FUNCTIONS/xpath_exists_fragment.sql
\i FUNCTIONS/xpath_fragment.sql
\i populate.sql

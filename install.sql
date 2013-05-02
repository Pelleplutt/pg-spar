DROP DATABASE spartest;
CREATE DATABASE spartest;

\c spartest

\i TABLES/sparconfig.sql
\i FUNCTIONS/http_post_xml.sql
\i FUNCTIONS/format_spar_personid_query.sql
\i FUNCTIONS/parse_spar_personid_response.sql
\i populate.sql

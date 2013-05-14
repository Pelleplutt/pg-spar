pg-spar
=======

PostgreSQL SPAR integration

This is an impltmentation of interacting with the SPAR API ( http://www.statenspersonadressregister.se/ ). This is a service provided by the Swedish goverment for access to data about Swedish Citizens. The implementation is written to be fully run and utlized from within PostgreSQL using plpgsql and plperlu function calls.

Access to the API and services can be applied for using instructions on the SPAR website.

Quick installation
==================

First and foremost, get access to the API from SPAR. Before going anywhere make sure you have your SSL certificate and other accound information that is needed to access the test servers. 

Requirements
------------
Everything is run under PostgreSQL (developed using v9.1.9). Support for plpgsql and plperlu is required. You also need a working perl installation and `WWW::Curl::Easy`.
For the testsuite to run you need perl and `DBIx::Pg::CallFunction` (https://github.com/joelonsql/dbix-pg-callfunction). 

Convert your certificate to a PEM format
----------------------------------------

Convert the certificate from Steria to a format usable for us:

    $ openssl pkcs12 -in INPUT.p12 -clcerts -nodes -out OUTPUT.crt

Create populate.sql and fill it with information about your configuration
-------------------------------------------------------------------------

    $ vim populate.sql

This file is used by `install.sql` below. This step can be skipped but you will get an error when running the `install.sql` (the error can be ignored), you will need to enter valid data into the SPARConfig table before running the test suite..

Run install.sql
---------------

    $ psql -f install.sql

This will create an empty database called spartest (and drop it if it exists).

Run tests
---------

    $ perl t/00-test.pl

This will run the tests defined in the documentation for querying a single personid in different ways.


Using the functions
===================

There are a number of helper functions (that will not be covered here) along with a few main functions to call for processing data. On a high level there are functions for formatting the query to submit, a function for submitting it to SPAR, one for parsing the response and one for saving the data into tables in the database.


The following functions are used to build up the query to submit:

- `Format_SPAR_Adress_Query`
- `Format_SPAR_PersonID_Query`

Then use this function to submit the query to SPAR:

- `HTTP_POST_XML`

Then parse the given result using:

- `Parse_SPAR_PersonSokning_Response`

... And if you wish save it to the database with:

- `Save_SPAR_PersonSokning`

- `Get_SPAR_Config`

Simple example:

    $ psql spartest
    spartest=# SELECT * FROM Parse_SPAR_PersonSokning_Response(HTTP_POST_XML('https://....', Format_SPAR_PersonID_Query('34908', '3458973489', 'Exempelforetag-458923', 'KATx', 'N', '934873459878'), 'spar.crt'));
    -[ RECORD 1 ]----------------------------------------------------------------------------------------------------------------------------------------------
    spardata   | (934873459878,N,2010-02-02,2010-02-02)
    sparadress | {"(,934873459878,F,,2010-02-02,,,\"Gatan142 8\",,11146,STOCKHOLM,Sverige,01,80,04,2003-01-01)"}
    sparperson | {"(,934873459878,2010-02-02,,\"Efternamn3542, Fornamn1 Fornamn2\",\"Fornamn1 Fornamn2\",20,\"Fornamn 3\",Efternamn3542,,,,,1993-01-30,K)"}


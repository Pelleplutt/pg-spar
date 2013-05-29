CREATE TABLE SPARPersonData (
    FysiskPersonId                      text NOT NULL,
    Sekretessmarkering                  char(1),
    SekretessAndringsdatum              date,
    SenasteAndringFolkbokforing         date,
    datestamp                           timestamptz NOT NULL DEFAULT current_timestamp,
    PRIMARY KEY(FysiskPersonId)
);



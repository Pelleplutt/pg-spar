CREATE TABLE SPARPersonData (
    FysiskPersonId                      text NOT NULL,
    Sekretessmarkering                  char(1),
    SekretessAndringsdatum              date,
    SenasteAndringFolkbokforing         date,
    PRIMARY KEY(FysiskPersonId)
);



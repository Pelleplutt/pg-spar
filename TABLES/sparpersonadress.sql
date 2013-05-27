CREATE TABLE SPARPersonAdress (
    SPARPersonAdressID                  integer not null default nextval('seqSPARPersonAdress'),
    FysiskPersonId                      text not null,
    AdressTyp                           char(1),
    CareOf                              text,
    DatumFrom                           date not null,
    DatumTom                            date,
    Utdelningsadress1                   text,
    Utdelningsadress2                   text,
    Utdelningsadress3                   text,
    Lagenhet                            text,
    PostNr                              char(5),
    Postort                             text,
    Land                                text,
    FolkbokfordLanKod                   char(2),
    FolkbokfordKommunKod                char(2),
    FolkbokfordForsamlingKod            char(2),
    Folkbokforingsdatum                 date,
    PRIMARY KEY (SPARPersonAdressID),
    FOREIGN KEY (FysiskPersonId) REFERENCES SPARPersonData(FysiskPersonId)
);



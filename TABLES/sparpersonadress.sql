CREATE TABLE SPARPersonAdress (
    FysiskPersonId                      text REFERENCES SPARPersonData(FysiskPersonId),
    AdressTyp                           character(1),
    CareOf                              text,
    DatumFrom                           date not null,
    DatumTom                            date,
    Utdelningsadress1                   text,
    Utdelningsadress2                   text,
    Utdelningsadress3                   text,
    PostNr                              character(5),
    Postort                             text,
    Land                                text,
    FolkbokfordLanKod                   character(2),
    FolkbokfordKommunKod                character(2),
    FolkbokfordForsamlingKod            character(2),
    Folkbokforingsdatum                 date
);



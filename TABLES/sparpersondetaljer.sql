CREATE TABLE SPARPersonDetaljer (
    SPARPersonDetaljerID                integer not null default nextval('seqSPARPersonDetaljer'),
    FysiskPersonId                      text not null,
    DatumFrom                           date not null,
    DatumTom                            date,
    Aviseringsnamn                      text,
    Fornamn                             text,
    Tilltalsnamn                        text,
    Mellannamn                          text,
    Efternamn                           text,
    HanvisningspersonNrByttTill         text,
    HanvisningspersonNrByttFran         text,
    Avregistreringsdatum                text,
    AvregistreringsorsakKod             char(1),
    Fodelsetid                          date,
    Kon                                 char(1),
    PRIMARY KEY (SPARPersonDetaljerID),
    FOREIGN KEY (FysiskPersonId) REFERENCES SPARPersonData(FysiskPersonId)
);


CREATE TABLE SPARPersonDetaljer (
    FysiskPersonId                      text REFERENCES SPARPersonData(FysiskPersonId),
    DatumFrom                           date NOT NULL,
    DatumTom                            date,
    Aviseringsnamn                      text,
    Fornamn                             text,
    Tilltalsnamn                        text,
    Mellannamn                          text,
    Efternamn                           text,
    HanvisningspersonNrByttTill         text,
    HanvisningspersonNrByttFran         text,
    Avregistreringsdatum                text,
    AvregistreringsorsakKod             character(1),
    Fodelsetid                          date,
    Kon                                 character(1)
);


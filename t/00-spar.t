#!/usr/bin/perl
use strict;
use warnings;

use DBI;
use DBIx::Pg::CallFunction;
use Cwd;

use Test::Deep;
use Test::Exception;
use Data::Dumper;
use Test::More;
use utf8;
use Encode;

my $builder = Test::More->builder;
binmode $builder->output,         ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output,    ":utf8";

my @person_tests = (
    {
        'personid' => 'SE193701308888',
        'desc' => '193701308888: 3.1. Förnamn, mellannamn, efternamn, aviseringsnamn, tilltalsnamn',
        'result' => [ 'SE193701308888' ],
        'result_entries' => [
            {
                'sparadress' => qr#{"\(\d+,SE193701308888,F,,2010-02-02,,,\\"Gatan142 8\\",,,11146,STOCKHOLM,Sverige,01,80,04,2003-01-01\)"}#,
                'sparperson' => qr#{"\(\d+,SE193701308888,2010-02-02,,\\"Efternamn3542, Christina Birgitta\\",\\"Christina Birgitta Ulrika\\",20,Thomeaus,Efternamn3542,,,,,1937-01-30,K\)"}#,
                'spardata' => qr#\(SE193701308888,N,2010-02-02,2010-02-02,[\d: .+"-]+\)#,
            },
        ],
    },
    {
        'personid' => 'SE192907304766',
        'desc' => '192907304766: 3.2. Folkbokföringsadress',
        'result' => [ 'SE192907304766' ],
        'result_entries' => [
            {
                'sparadress' => qr#{"\(\d+,SE192907304766,F,CO-NAMN,2010-02-02,,\\"HÖGER HUS\\",\\"Gatan218 3, ANDRA HUSET PÅ\\",,,11140,STOCKHOLM,Sverige,01,80,01,2000-11-01\)"}#,
                'sparperson' => qr#{"\(\d+,SE192907304766,2010-02-02,,,\\"Helga Viktoria\\",,,Efternamn2609,,,,,1929-07-30,K\)"}#,
                'spardata' => qr#\(SE192907304766,N,2010-02-02,2010-02-02,[\d: .+"-]+\)#,
            },
        ],
    },
    {
        'personid' => 'SE196805029268',
        'desc' => '196805029268:3.3. Särskild postadress',
        'result' => [ 'SE196805029268' ],
        'result_entries' => [
            {
                'sparadress' => qr#{"\(\d+,SE196805029268,F,,2010-02-02,,,\\"Gatan140 11\\",,,98131,KIRUNA,Sverige,25,84,01,1986-10-01\)","\(\d+,SE196805029268,S,CO-NAMN,2010-02-02,,\\"HÖGER HUS\\",\\"Gatan170 2 25 TR\\",,16,11138,STOCKHOLM,Sverige,,,,\)"}#,
                'sparperson' => qr#{"\(\d+,SE196805029268,2010-02-02,,,Petra,,,Efternamn2401,,,,,1968-05-02,K\)"}#,
                'spardata' => qr#\(SE196805029268,N,2010-02-02,2010-02-02,[\d: .+"-]+\)#,
            },
        ],
    },
    {
        'personid' => 'SE194812161596',
        'desc' => '194812161596:3.4. Utlandsadress',
        'result' => [ 'SE194812161596' ],
        'result_entries' => [
            {
                'sparadress' => qr#{"\(\d+,SE194812161596,F,,2010-02-02,,,\\"Gatan267 2\\",,,96191,BODEN,Sverige,25,82,01,1948-12-16\)","\(\d+,SE194812161596,U,,2010-02-02,,\\"UTLANDSGATAN 111\\",UTLANDOMRÅDE,STADEN,,,,NORGE,,,,\)"}#,
                'sparperson' => qr#{"\(\d+,SE194812161596,2010-02-02,,,\\"Nils Uno\\",,,Efternamn1433,,,,,1948-12-16,M\)"}#,
                'spardata' => qr#\(SE194812161596,N,2010-02-02,2010-02-02,[\d: .+"-]+\)#,
            },
        ],
    },
    {
        'personid' => 'SE197904182396',
        'desc' => '197904182396: 3.5. Historik',
        'result' => [ 'SE197904182396' ],
        'result_entries' => [
            {
                'sparadress' => qr#{"\(\d+,SE197904182396,F,,2010-02-02,2010-02-15,,\\"Gatan401 2\\",,,13131,NACKA,Sverige,01,82,01,2007-07-04\)","\(\d+,SE197904182396,F,,2010-02-15,,,\\"Gatan225 13\\",,,13131,NACKA,Sverige,01,82,01,2011-02-04\)"}#,
                'sparperson' => qr#{"\(\d+,SE197904182396,2010-02-02,2010-02-15,,Kuno,10,,Efternamn1083,,,,,1979-04-18,M\)","\(\d+,SE197904182396,2010-02-15,,,Kuno,10,,Efternamn2993,,,,,1979-04-18,M\)"}#,
                'spardata' => qr#\(SE197904182396,N,2010-02-02,2010-02-15,[\d: .+"-]+\)#,
            },
        ],
    },
    {
        'personid' => 'SE199111029196',
        'desc' => '199111029196: 3.6. Hänvisningspersonnummer, bytt från',
        'result' => [ 'SE199111029196' ],
        'result_entries' => [
            {
                'sparadress' => qr#{"\(\d+,SE199111029196,F,,2011-05-06,,,\\"Gatan330 3\\",,,98134,KIRUNA,Sverige,25,84,02,1991-11-02\)"}#,
                'sparperson' => qr#{"\(\d+,SE199111029196,2011-05-06,,,\\"Martin Oskar\\",,,Efternamn3227,,SE199111022399,,,1991-11-02,M\)"}#,
                'spardata' => qr#\(SE199111029196,N,2011-05-06,2011-05-06,[\d: .+"-]+\)#,
            },
        ],
    },
    {
        'personid' => 'SE199111022399',
        'desc' => '199111022399: 3.7. Hänvisningspersonnummer, bytt till',
        'result' => [ 'SE199111022399' ],
        'result_entries' => [
            {
                'sparadress' => qr#{"\(\d+,SE199111022399,F,,2010-02-02,2011-05-02,,\\"Gatan330 3\\",,,98134,KIRUNA,Sverige,25,84,02,1991-11-02\)","\(\d+,SE199111022399,,,2011-05-02,,,,,,,,,,,,\)"}#,
                'sparperson' => qr#{"\(\d+,SE199111022399,2010-02-02,2011-05-02,,\\"Martin Oskar\\",,,Efternamn3227,,,,,1991-11-02,M\)","\(\d+,SE199111022399,2011-05-02,,,,,,,SE199111029196,,,G,1991-11-02,M\)"}#,
                'spardata' => qr#\(SE199111022399,N,2010-02-02,2011-05-02,[\d: .+"-]+\)#,
            },
        ],
    },
    {
        'personid' => 'SE193604139208',
        'desc' => '193604139208: 3.8. Avregistrerad',
        'result' => [ 'SE193604139208' ],
        'result_entries' => [
            {
                'sparadress' => qr#{"\(\d+,SE193604139208,F,CO-NAMN,2010-02-02,,,\\"Gatan177 2\\",,,17890,EKERÖ,Sverige,01,25,04,2002-09-01\)"}#,
                'sparperson' => qr#{"\(\d+,SE193604139208,2010-02-02,2011-03-15,,Carina,,,Efternamn1301,,,,,1936-04-13,K\)","\(\d+,SE193604139208,2011-03-15,,,Carina,,,Efternamn1301,,,2011-02-02,A,1936-04-13,K\)"}#,
                'spardata' => qr#\(SE193604139208,N,2010-02-02,2011-03-15,[\d: .+"-]+\)#,
            },
        ],
    },
    {
        'personid' => 'SE193103249078',
        'desc' => '193103249078: 3.9. Ingen träff',
        'result' => undef,
        'result_entries' => undef,
                    # This seems to be an error in the documentation from
                    # SPAKO, they claim this test should result in no hits, in
                    # fact it seems to result in a single hit, but with
                    # SekretessMarkering:
                    #
                    # <?xml version="1.0"?>
                    # <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
                    #   <env:Header/>
                    #   <env:Body>
                    #     <n1:SPARPersonsokningSvar xmlns:n1="http://skatteverket.se/spar/instans/1.0">
                    #       <spako:PersonsokningFraga xmlns:spako="http://skatteverket.se/spar/komponent/1.0">
                    #         <spako:PersonId>
                    #           <spako:FysiskPersonId>193103249078</spako:FysiskPersonId>
                    #         </spako:PersonId>
                    #       </spako:PersonsokningFraga>
                    #       <spako:PersonsokningSvarsPost xmlns:spako="http://skatteverket.se/spar/komponent/1.0">
                    #         <spako:PersonId>
                    #           <spako:FysiskPersonId>193103249078</spako:FysiskPersonId>
                    #         </spako:PersonId>
                    #         <spako:Sekretessmarkering>J</spako:Sekretessmarkering>
                    #         <spako:SekretessAndringsdatum>2010-02-02</spako:SekretessAndringsdatum>
                    #       </spako:PersonsokningSvarsPost>
                    #     </n1:SPARPersonsokningSvar>
                    #   </env:Body>
                    # </env:Envelope>
    },
    {
        'personid' => 'SE193604139207',
        'desc' => '193604139207: 3.10. Felaktigt personnummer \(felaktig kontrollsiffra\)',
        'result' => undef,
        'result_entries' => undef,
    },
    {
        'personid' => 'SE19360413920',
        'desc' => '19360413920: 3.11. Felaktigt personnummer \(fel antal tecken\)',
        'result' => undef,
        'result_entries' => undef,
        'invalid' => 1,
    },
    {
        'personid' => 'SE197806082397',
        'desc' => '197806082397: 3.12. Lägenhetsnummer',
        'result' => [ 'SE197806082397' ],
        'result_entries' => [
            {
                'sparadress' => qr#{"\(\d+,SE197806082397,F,,2010-02-02,,,\\"Gatan366 45\\",,1104,13241,SALTSJÖ-BOO,Sverige,24,80,04,1979-05-01\)"}#,
                'sparperson' => qr#{"\(\d+,SE197806082397,2010-02-02,,,Jan,,,Efternamn2584,,,,,1978-06-08,M\)"}#,
                'spardata' => qr#\(SE197806082397,N,2010-02-02,2010-02-02,[\d: .+"-]+\)#,
            },
        ],
    },
    {
        'personid' => 'SE199211629192',
        'desc' => '199211629192: 3.13. Samordningsnummer',
        'result' => [ 'SE199211629192' ],
        'result_entries' => [
            {
                'sparadress' => qr#{"\(\d+,SE199211629192,F,,2011-05-06,,,\\"Gatan330 8\\",,,98134,KIRUNA,Sverige,25,84,02,1992-11-02\)"}#,
                'sparperson' => qr#{"\(\d+,SE199211629192,2011-05-06,,,Holger,,,Efternamn2849,,,,,1992-11-02,M\)"}#,
                'spardata' => qr#\(SE199211629192,N,2011-05-06,2011-05-06,[\d: .+"-]+\)#,
            },
        ],
    },
);


my $valid = grep { !$$_{'invalid'} } @person_tests;
my $invalid = grep { $$_{'invalid'} } @person_tests;
plan tests => 4 + $valid * 9 + $invalid * 1;

my $dbh = DBI->connect("dbi:Pg:dbname=spartest", '', '', {pg_enable_utf8 => 1, PrintError => 0});
ok(defined $dbh, 'DB Connect');

my $pg = DBIx::Pg::CallFunction->new($dbh);

ok(defined $pg, 'DB Pg::CallFunction');
#can_ok($pg, qw(get_spar_config format_spar_personid_query parse_spar_personsokning_response));

my $spar_config = $pg->get_spar_config();
ok(defined $spar_config, 'Configuration read');
ok(
    (defined $$spar_config{'url'} and
    defined $$spar_config{'kundnr'} and
    defined $$spar_config{'orgnr'} and
    defined $$spar_config{'slutanvandarid'} and
    defined $$spar_config{'slutanvandarbehorighet'} and
    defined $$spar_config{'slutanvandarsekretessratt'}),
    'Configuration values');


foreach my $qdata ( @person_tests ) {

    my $spar_query;
    my $spar_query_data = {
        _kundnr                    => $$spar_config{kundnr},
        _orgnr                     => $$spar_config{orgnr},
        _slutanvandarid            => $$spar_config{slutanvandarid},
        _slutanvandarbehorighet    => $$spar_config{slutanvandarbehorighet},
        _slutanvandarsekretessratt => $$spar_config{slutanvandarsekretessratt},
        _personid                  => $$qdata{'personid'},
    };

    if($$qdata{'invalid'}) {
        throws_ok { $spar_query = $pg->format_spar_personid_query($spar_query_data) } qr/ERROR_WTF Invalid PersonId/, 'Catch invalid PersonId';
        next;
    } else {
        $spar_query = $pg->format_spar_personid_query($spar_query_data);
    }

    my $spar_response = $pg->http_post_xml({
            _url      => $$spar_config{url},
            _xml      => $spar_query,
            _certfile => $$spar_config{cert},
        });

    ok(defined $spar_response, "Query OK $$qdata{'desc'}");
    like($spar_response, qr#http://schemas.xmlsoap.org/soap/envelope/#, "Query is SOAP $$qdata{'desc'}");

#    warn "spar_response";
#    warn Dumper $spar_response;

    my $res = $pg->parse_spar_personsokning_response({
        _xml => $spar_response
    });

    if(defined $$qdata{'result'}) {
        is(ref $res, 'ARRAY', "Parse result OK $$qdata{'desc'}");
        is($#$res, $#{$$qdata{'result'}}, "Parse result person count $$qdata{'desc'}");

        my @results = @{$$qdata{'result_entries'}};

        foreach my $i ( 0 .. $#{$$qdata{'result_entries'}}) {
                is($$res[$i], $$qdata{'result'}[$i], "Returned person $i");

            my $rp = $pg->get_spar_persondata({
                    _personid => $$res[$i],
            });
            is(ref $rp, 'HASH', "Fetch person $$res[$i] $$qdata{'desc'}");


            my $expected = shift @results;
            foreach my $field ( qw(spardata sparperson sparadress) ) {
                $$rp{$field} = Encode::decode('UTF-8', $$rp{$field});
                like($$rp{$field}, $$expected{$field}, "Query response $field $$qdata{'desc'}");
            }
        }
    } else {
        is($res, undef, "Parse result OK $$qdata{'desc'}");
        is('', '', "Parse result person count $$qdata{'desc'}");
        is('', '', "Returned person");
        is('', '', "Fetch person $$qdata{'desc'}");

        foreach my $field ( qw(spardata sparperson sparadress) ) {
            is('', '', "Query response $field $$qdata{'desc'}");
        }
    }

#    warn "res:";
#    warn Dumper $res;
}


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
        'sokdata' => {
            _fonetisksokning            => undef, 
            _namn                       => undef,
            _fornamn                    => undef,
            _mellanefternamn            => 'Efternamn2052',
            _utdelningsadress           => undef,
            _postort                    => undef,
            _postnr                     => undef,
            _postnrfran                 => undef,
            _postnrtill                 => undef,
            _fodelsetid                 => undef,
            _fodelsetidfran             => undef,
            _fodelsetidtill             => undef,
            _kon                        => undef,
            _lankod                     => undef,
            _kommunkod                  => undef,
            _forsamlingkod              => undef,
        },
        'desc' => '4.1. Endast efternamn',
        'result' => [ 'SE192203207960' ],
        'result_entries' => [
            {
                'sparadress' => qr#{"\(\d+,SE192203207960,F,,2010-02-02,,,\\"Gatan390 2\\",,,11859,STOCKHOLM,Sverige,01,80,11,\)"}#,
                'sparperson' => qr#{"\(\d+,SE192203207960,2010-02-02,,,Susan,,,Efternamn2052,,,,,1922-03-20,K\)"}#,
                'spardata' => qr#\(SE192203207960,N,2010-02-02,2010-02-02,[\d: .+"-]+\)#,
            },
        ],
    },
    {
        'sokdata' => {
            _fonetisksokning            => undef, 
            _namn                       => 'Efternamn2052',
            _fornamn                    => undef,
            _mellanefternamn            => undef,
            _utdelningsadress           => undef,
            _postort                    => undef,
            _postnr                     => undef,
            _postnrfran                 => undef,
            _postnrtill                 => undef,
            _fodelsetid                 => undef,
            _fodelsetidfran             => undef,
            _fodelsetidtill             => undef,
            _kon                        => undef,
            _lankod                     => undef,
            _kommunkod                  => undef,
            _forsamlingkod              => undef,
        },
        'desc' => '4.2. Endast namn, efternamn',
        'result' => [ 'SE192203207960' ],
        'result_entries' => [
            {
                'sparadress' => qr#{"\(\d+,SE192203207960,F,,2010-02-02,,,\\"Gatan390 2\\",,,11859,STOCKHOLM,Sverige,01,80,11,\)"}#,
                'sparperson' => qr#{"\(\d+,SE192203207960,2010-02-02,,,Susan,,,Efternamn2052,,,,,1922-03-20,K\)"}#,
                'spardata' => qr#\(SE192203207960,N,2010-02-02,2010-02-02,[\d: .+"-]+\)#,
            },
        ],
    },
    {
        'sokdata' => {
            _fonetisksokning            => undef, 
            _namn                       => undef,
            _fornamn                    => 'Susan',
            _mellanefternamn            => 'Efternamn2052',
            _utdelningsadress           => undef,
            _postort                    => undef,
            _postnr                     => undef,
            _postnrfran                 => undef,
            _postnrtill                 => undef,
            _fodelsetid                 => undef,
            _fodelsetidfran             => undef,
            _fodelsetidtill             => undef,
            _kon                        => undef,
            _lankod                     => undef,
            _kommunkod                  => undef,
            _forsamlingkod              => undef,
        },
        'desc' => '4.3. Kombination , förnamn och efternamn',
        'result' => [ 'SE192203207960' ],
        'result_entries' => [
            {
                'sparadress' => qr#{"\(\d+,SE192203207960,F,,2010-02-02,,,\\"Gatan390 2\\",,,11859,STOCKHOLM,Sverige,01,80,11,\)"}#,
                'sparperson' => qr#{"\(\d+,SE192203207960,2010-02-02,,,Susan,,,Efternamn2052,,,,,1922-03-20,K\)"}#,
                'spardata' => qr#\(SE192203207960,N,2010-02-02,2010-02-02,[\d: .+"-]+\)#,
            },
        ],
    },
    {
            # This test case seems bonkers, the documentation and name of the
            # test case does not make sense in combination with the result
            # data. I read documentation as search for first name only, but
            # name of test case seems to indicate otherwise and searching for
            # the name only gives the wrong result?! (two persons, not one)
        'sokdata' => {
            _fonetisksokning            => undef, 
            _namn                       => 'Susan',
            _fornamn                    => undef,
            _mellanefternamn            => 'Efternamn2052',
            _utdelningsadress           => undef,
            _postort                    => undef,
            _postnr                     => undef,
            _postnrfran                 => undef,
            _postnrtill                 => undef,
            _fodelsetid                 => undef,
            _fodelsetidfran             => undef,
            _fodelsetidtill             => undef,
            _kon                        => undef,
            _lankod                     => undef,
            _kommunkod                  => undef,
            _forsamlingkod              => undef,
        },
        'desc' => '4.4. Endast namn, efternamn',
        'result' => [ 'SE198206082383', 'SE192203207960' ],
        'result_entries' => [
            {
                'sparadress' => qr#{"\(\d+,SE198206082383,F,,2010-02-02,,,\\"Gatan125 11\\",,,13336,SALTSJÖBADEN,Sverige,01,82,01,2008-12-01\)"}#,
                'sparperson' => qr#{"\(\d+,SE198206082383,2010-02-02,,,\\"Susan Ann\\",10,,Efternamn3303,,,,,1982-06-08,K\)"}#,
                'spardata' => qr#\(SE198206082383,N,2010-02-02,2010-02-02,[\d: .+"-]+\)#,
            },
            {
                'sparadress' => qr#{"\(\d+,SE192203207960,F,,2010-02-02,,,\\"Gatan390 2\\",,,11859,STOCKHOLM,Sverige,01,80,11,\)"}#,
                'sparperson' => qr#{"\(\d+,SE192203207960,2010-02-02,,,Susan,,,Efternamn2052,,,,,1922-03-20,K\)"}#,
                'spardata' => qr#\(SE192203207960,N,2010-02-02,2010-02-02,[\d: .+"-]+\)#,
            },
        ],
    },
    {
        'sokdata' => {
            _fonetisksokning            => undef, 
            _namn                       => undef,
            _fornamn                    => undef,
            _mellanefternamn            => 'Efternamn1369',
            _utdelningsadress           => undef,
            _postort                    => undef,
            _postnr                     => undef,
            _postnrfran                 => undef,
            _postnrtill                 => undef,
            _fodelsetid                 => undef,
            _fodelsetidfran             => undef,
            _fodelsetidtill             => undef,
            _kon                        => 'K',
            _lankod                     => undef,
            _kommunkod                  => undef,
            _forsamlingkod              => undef,
        },
        'desc' => '4.5. Efternamn och kön',
        'result' => [
            'SE198406122385',
            'SE196807099228',
            'SE199201242386',
            'SE198711282387',
            'SE197607262388',
            'SE195401225205',
            'SE198605222382',
            'SE198707262385',
            'SE197705242381',
            'SE198208082381',
            'SE198406222383',
            'SE197108109286',
            'SE194001079120',
            'SE196210053143',
            'SE194509287068'
        ],
        'result_entries' => [ ],
    },
    {
        'sokdata' => {
            _fonetisksokning            => undef, 
            _namn                       => undef,
            _fornamn                    => undef,
            _mellanefternamn            => 'Efternamn1369',
            _utdelningsadress           => undef,
            _postort                    => undef,
            _postnr                     => undef,
            _postnrfran                 => undef,
            _postnrtill                 => undef,
            _fodelsetid                 => '1976-07-26',
            _fodelsetidfran             => undef,
            _fodelsetidtill             => undef,
            _kon                        => 'K',
            _lankod                     => undef,
            _kommunkod                  => undef,
            _forsamlingkod              => undef,
        },
        'desc' => '4.6. Efternamn, kön och födelsetid',
        'result' => [ 'SE197607262388' ],
        'result_entries' => [
            {
                'sparadress' => qr#{"\(\d+,SE197607262388,F,,2010-02-02,,,\\"Gatan170 2\\",,,11138,STOCKHOLM,Sverige,01,80,09,2007-07-01\)"}#,
                'sparperson' => qr#{"\(\d+,SE197607262388,2010-02-02,,,Dilla,10,,Efternamn1369,,,,,1976-07-26,K\)"}#,
                'spardata' => qr#\(SE197607262388,N,2010-02-02,2010-02-02,[\d: .+"-]+\)#,
            },
         ],
    },
    {
        'sokdata' => {
            _fonetisksokning            => undef, 
            _namn                       => undef,
            _fornamn                    => undef,
            _mellanefternamn            => 'Efternamn1369',
            _utdelningsadress           => undef,
            _postort                    => undef,
            _postnr                     => undef,
            _postnrfran                 => undef,
            _postnrtill                 => undef,
            _fodelsetid                 => undef,
            _fodelsetidfran             => '1970-01-01',
            _fodelsetidtill             => '1980-01-01',
            _kon                        => undef,
            _lankod                     => undef,
            _kommunkod                  => undef,
            _forsamlingkod              => undef,
        },
        'desc' => '4.7. Efternamn, födelsetidinterval',
        'result' => [ 
            'SE197609179275',
            'SE197702252391',
            'SE197607262388',
            'SE197705019359',
            'SE197705242381',
            'SE197711159314',
            'SE197108109286',
            'SE197710262390'
        ],
        'result_entries' => [
         ],
    },
    {
        'sokdata' => {
            _fonetisksokning            => undef, 
            _namn                       => undef,
            _fornamn                    => undef,
            _mellanefternamn            => 'Efternamn2406',
            _utdelningsadress           => 'Gatan160 2',
            _postort                    => undef,
            _postnr                     => undef,
            _postnrfran                 => undef,
            _postnrtill                 => undef,
            _fodelsetid                 => undef,
            _fodelsetidfran             => '1901-01-01',
            _fodelsetidtill             => '2010-01-01',
            _kon                        => undef,
            _lankod                     => undef,
            _kommunkod                  => undef,
            _forsamlingkod              => undef,
        },
        'desc' => '4.8. Efternamn, utdelningsadress',
        'result' => [ 'SE192104198383', 'SE192106049279' ],
        'result_entries' => [
            {
                'sparadress' => qr#{"\(\d+,SE192104198383,F,,2010-02-02,,,\\"Gatan160 2\\",,,11853,STOCKHOLM,Sverige,01,80,04,1981-10-01\)"}#,
                'sparperson' => qr#{"\(\d+,SE192104198383,2010-02-02,,,\\"Alice Gun Linnea\\",,,Efternamn2406,,,,,1921-04-19,K\)"}#,
                'spardata' => qr#\(SE192104198383,N,2010-02-02,2010-02-02,[\d: .+"-]+\)#,
            },
            {
                'sparadress' => qr#{"\(\d+,SE192106049279,F,,2010-02-02,,,\\"Gatan160 2\\",,,11853,STOCKHOLM,Sverige,01,80,04,1981-10-01\)"}#,
                'sparperson' => qr#{"\(\d+,SE192106049279,2010-02-02,,,Hans,,,Efternamn2406,,,,,1921-06-04,M\)"}#,
                'spardata' => qr#\(SE192106049279,N,2010-02-02,2010-02-02,[\d: .+"-]+\)#,
            },
         ],
    },
    {
        'sokdata' => {
            _fonetisksokning            => undef, 
            _namn                       => undef,
            _fornamn                    => undef,
            _mellanefternamn            => 'Efternamn1369',
            _utdelningsadress           => undef,
            _postort                    => 'Solna',
            _postnr                     => undef,
            _postnrfran                 => undef,
            _postnrtill                 => undef,
            _fodelsetid                 => undef,
            _fodelsetidfran             => undef,
            _fodelsetidtill             => undef,
            _kon                        => undef,
            _lankod                     => undef,
            _kommunkod                  => undef,
            _forsamlingkod              => undef,
        },
        'desc' => '4.9 Efternamn, postort',
        'result' => [
            'SE197108109286',
            'SE193703149132',
        ],
        'result_entries' => [
        ],
    },
    {
        'sokdata' => {
            _fonetisksokning            => undef, 
            _namn                       => undef,
            _fornamn                    => undef,
            _mellanefternamn            => 'Efternamn1369',
            _utdelningsadress           => undef,
            _postort                    => 'Solna',
            _postnr                     => '17138',
            _postnrfran                 => undef,
            _postnrtill                 => undef,
            _fodelsetid                 => undef,
            _fodelsetidfran             => undef,
            _fodelsetidtill             => undef,
            _kon                        => undef,
            _lankod                     => undef,
            _kommunkod                  => undef,
            _forsamlingkod              => undef,
        },
        'desc' => '4.10. Efternamn, postort, postnummer',
        'result' => [
            'SE197108109286',
            'SE193703149132',
        ],
        'result_entries' => [
        ],
    },
    {
        'sokdata' => {
            _fonetisksokning            => undef, 
            _namn                       => undef,
            _fornamn                    => undef,
            _mellanefternamn            => 'Efternamn1369',
            _utdelningsadress           => undef,
            _postort                    => 'Solna',
            _postnr                     => undef,
            _postnrfran                 => '17136',
            _postnrtill                 => '17300',
            _fodelsetid                 => undef,
            _fodelsetidfran             => undef,
            _fodelsetidtill             => undef,
            _kon                        => undef,
            _lankod                     => undef,
            _kommunkod                  => undef,
            _forsamlingkod              => undef,
        },
        'desc' => '4.11. Efternamn, postort, postnummer intervall',
        'result' => [
            'SE197108109286',
            'SE193703149132',
        ],
        'result_entries' => [
        ],
    },
    {
            # Actual test case is broken, SPAR will not accept a single char
            # wildcard in name search arguments. I altered this one slightly to
            # get any useful data
        'sokdata' => {
            _fonetisksokning            => undef, 
            _namn                       => undef,
            _fornamn                    => undef,
            _mellanefternamn            => 'me*',
            _utdelningsadress           => undef,
            _postort                    => undef,
            _postnr                     => undef,
            _postnrfran                 => undef,
            _postnrtill                 => undef,
            _fodelsetid                 => undef,
            _fodelsetidfran             => undef,
            _fodelsetidtill             => undef,
            _kon                        => undef,
            _lankod                     => '01',
            _kommunkod                  => '25',
            _forsamlingkod              => '01',
        },
        'desc' => 'Efternamn (wildcard), län, kommun, församling',
        'result' => [
            'SE193302288414',
            'SE198102092395'
        ],
        'result_entries' => [
        ],
    },
    {
            # This cannot really be modeled in the current implementation. The
            # return from the search is:

            # <?xml version="1.0"?>
            # <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
            #   <env:Header/>
            #   <env:Body>
            #     <n1:SPARPersonsokningSvar xmlns:n1="http://skatteverket.se/spar/instans/1.0">
            #       <spako:PersonsokningFraga xmlns:spako="http://skatteverket.se/spar/komponent/1.0">
            #         <spako:FonetiskSokning>N</spako:FonetiskSokning>
            #         <spako:MellanEfternamnSokArgument>Efternamn10*</spako:MellanEfternamnSokArgument>
            #         <spako:KommunKod>10</spako:KommunKod>
            #       </spako:PersonsokningFraga>
            #       <spako:OverstigerMaxAntalSvarsposter xmlns:spako="http://skatteverket.se/spar/komponent/1.0">
            #         <spako:AntalPoster>224</spako:AntalPoster>
            #         <spako:MaxAntalSvarsPoster>100</spako:MaxAntalSvarsPoster>
            #       </spako:OverstigerMaxAntalSvarsposter>
            #     </n1:SPARPersonsokningSvar>
            #   </env:Body>
            # </env:Envelope>
        'sokdata' => {
            _fonetisksokning            => undef, 
            _namn                       => undef,
            _fornamn                    => undef,
            _mellanefternamn            => 'Efternamn10*',
            _utdelningsadress           => undef,
            _postort                    => undef,
            _postnr                     => undef,
            _postnrfran                 => undef,
            _postnrtill                 => undef,
            _fodelsetid                 => undef,
            _fodelsetidfran             => undef,
            _fodelsetidtill             => undef,
            _kon                        => undef,
            _lankod                     => undef,
            _kommunkod                  => '10',
            _forsamlingkod              => undef,
        },
        'desc' => '4.13. Efternamn (wildcard), län, många träffar',
        'result' => undef,
        'result_entries' => undef,
    },
    {
        'sokdata' => {
            _fonetisksokning            => 1, 
            _namn                       => 'Karl',
            _fornamn                    => undef,
            _mellanefternamn            => undef,
            _utdelningsadress           => undef,
            _postort                    => undef,
            _postnr                     => undef,
            _postnrfran                 => undef,
            _postnrtill                 => undef,
            _fodelsetid                 => undef,
            _fodelsetidfran             => '1970-01-01',
            _fodelsetidtill             => '2010-01-01',
            _kon                        => undef,
            _lankod                     => '01',
            _kommunkod                  => '25',
            _forsamlingkod              => undef,
        },
        'desc' => '4.14. Namn ( fonetisk sökning)',
        'result' => [
            'SE200102212396',
            'SE200906082391',
            'SE197703102397',
            'SE198208012396',
        ],
        'result_entries' => [
        ],
    },
    {
        'sokdata' => {
            _fonetisksokning            => undef,
            _namn                       => 'Clas',
            _fornamn                    => undef,
            _mellanefternamn            => undef,
            _utdelningsadress           => undef,
            _postort                    => undef,
            _postnr                     => undef,
            _postnrfran                 => undef,
            _postnrtill                 => undef,
            _fodelsetid                 => undef,
            _fodelsetidfran             => undef,
            _fodelsetidtill             => undef,
            _kon                        => undef,
            _lankod                     => undef,
            _kommunkod                  => undef,
            _forsamlingkod              => undef,
        },
        'desc' => '4.15. Namn, ingen träff',
        'result' => undef,
        'result_entries' => undef,
    },
);
my $results = 0;
map { $results += @{$$_{'result'}} } grep { defined $$_{'result'} } @person_tests;

my $result_entries = 0;
map { $result_entries += @{$$_{'result_entries'}} } grep { defined $$_{'result_entries'} } @person_tests;
plan tests => 4 + $results + $result_entries * 5 + @person_tests * 4;

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
        %{$$qdata{'sokdata'}},
    };

    if($$qdata{'invalid'}) {
        throws_ok { $spar_query = $pg->format_spar_adress_query($spar_query_data) } qr/ERROR_WTF Invalid PersonId/, 'Catch invalid PersonId';
        next;
    } else {
        $spar_query = $pg->format_spar_adress_query($spar_query_data);
    }
#    warn "spar_query";
#    warn Dumper $spar_query;

    my $spar_response = $pg->http_post_xml({
            _url      => $$spar_config{url},
            _xml      => $spar_query,
            _cert     => $$spar_config{cert},
        });

    ok(defined $spar_response, "Query OK $$qdata{'desc'}");
    like($spar_response, qr#http://schemas.xmlsoap.org/soap/envelope/#, "Query is SOAP $$qdata{'desc'}");
#    warn "spar_response";
#    warn Dumper $spar_response;

    my $res = $pg->parse_spar_personsokning_response({
        _xml => $spar_response
    });
#    warn "parsed_personids";
#    warn Dumper($res);

    if(defined $$qdata{'result'}) {
        is(ref $res, 'ARRAY', "Parse result OK $$qdata{'desc'}");
        is($#$res, $#{$$qdata{'result'}}, "Parse result person count $$qdata{'desc'}");
        foreach my $i ( 0 .. $#{$$qdata{'result'}}) {
            is($$res[$i], $$qdata{'result'}[$i], "Result personid $i $$qdata{'desc'}");
        }

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
    }

#    warn "res:";
#    warn Dumper $res;
}


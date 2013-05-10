#!/usr/bin/perl
use strict;
use warnings;

use DBI;
use DBIx::Pg::CallFunction;
use Test::More;
use Test::Deep;
use Data::Dumper;
use Cwd;

# plan tests => 1;

my $dbh = DBI->connect("dbi:Pg:dbname=spartest", '', '', {pg_enable_utf8 => 1, PrintError => 0});
my $pg = DBIx::Pg::CallFunction->new($dbh);

my $spar_config = $pg->get_spar_config();

my $personid = '193701308888';

my $spar_query = $pg->format_spar_personid_query({
    _kundnr                    => $spar_config->{kundnr},
    _orgnr                     => $spar_config->{orgnr},
    _slutanvandarid            => $spar_config->{slutanvandarid},
    _slutanvandarbehorighet    => $spar_config->{slutanvandarbehorighet},
    _slutanvandarsekretessratt => $spar_config->{slutanvandarsekretessratt},
    _personid                  => $personid
});

warn "spar_query:";
warn Dumper $spar_query;

my $spar_response = $pg->http_post_xml({
    _url      => $spar_config->{url},
    _xml      => $spar_query,
    _certfile =>  getcwd() . '/spar.crt'
});

warn "spar_response";
warn Dumper $spar_response;

my $res = $pg->parse_spar_response({
    _xml => $spar_response
});

warn "res:";
warn Dumper $res;

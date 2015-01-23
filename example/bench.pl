#!/usr/bin/env perl

use strict;
use warnings;

use Benchmark 'cmpthese';
use Net::Statsd;
use Net::StatsD::XS;

print "inc\n\n";

cmpthese -1, {
    'Net::Statsd'     => sub { Net::Statsd::inc('foo') },
    'Net::StatsD::XS' => sub { Net::StatsD::XS::inc('foo') },
};

print "\ndec\n\n";

cmpthese -1, {
    'Net::Statsd'     => sub { Net::Statsd::dec('foo') },
    'Net::StatsD::XS' => sub { Net::StatsD::XS::dec('foo') },
};

print "\ncount/update_stats\n\n";

cmpthese -1, {
    'Net::Statsd'     => sub { Net::Statsd::update_stats( foo => 123 ) },
    'Net::StatsD::XS' => sub { Net::StatsD::XS::count( foo => 123 ) },
};

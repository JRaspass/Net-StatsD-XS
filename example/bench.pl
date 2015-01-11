#!/usr/bin/env perl

use strict;
use warnings;

use Benchmark 'cmpthese';
use Net::Statsd;
use WebService::StatsD;

print "inc\n\n";

cmpthese -1, {
    'Net::Statsd'        => sub { Net::Statsd::inc('foo') },
    'WebService::StatsD' => sub { WebService::StatsD::inc('foo') },
};

print "\ndec\n\n";

cmpthese -1, {
    'Net::Statsd'        => sub { Net::Statsd::dec('foo') },
    'WebService::StatsD' => sub { WebService::StatsD::dec('foo') },
};

print "\ncount/update_stats\n\n";

cmpthese -1, {
    'Net::Statsd'        => sub { Net::Statsd::update_stats( foo => 123 ) },
    'WebService::StatsD' => sub { WebService::StatsD::count( foo => 123 ) },
};

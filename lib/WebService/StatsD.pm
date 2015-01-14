package WebService::StatsD 0.001;

use strict;
use warnings;

use Carp ();
use XSLoader;

XSLoader::load();

our ( $host, $port, $sock ) = ( localhost => 8125 );

sub set_host   {
    $host = $_[0];

    undef $sock;
}

sub set_port {
    $port = $_[0];

    undef $sock;
}

sub set_socket {
    ( $host, $port ) = @_;

    undef $sock;
}

sub import {
    my $class  = shift;
    my $caller = caller . '::';

    no strict 'refs';

    *{ $caller . $_ } = $class->can($_) // Carp::croak qq/Unknown export "$_"/
        for @_;
}

1;

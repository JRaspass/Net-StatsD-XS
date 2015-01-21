package WebService::StatsD 0.001;

use strict;
use warnings;

use Carp ();
use XSLoader;

XSLoader::load();

my ( $host, $port, $sock ) = ( localhost => 8125 );

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

sub dec {
    unshift @_, ( shift // return ) . ':-1c';

    goto &_send;
}

sub count {
    unshift @_, ( shift // return ) . ':' . ( shift // 1 ) . 'c';

    goto &_send;
}

sub inc {
    unshift @_, ( shift // return ) . ':1c';

    goto &_send;
}

sub _send {
    my ( $stat, $rate ) = @_;

    return if defined $rate && rand > $rate;

    unless ($sock) {
        socket $sock, 2, 2, 0 or return;

        my $host = gethostbyname $host or return;

        connect $sock, pack 'Sna4x8', 2, $port, $host or return;
    }

    send $sock, $stat, 0;

    return;
}

1;

package Net::StatsD::XS 0.001;

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

sub count {
    unshift @_, ( shift // return ) . ':' . ( shift // 1 ) . '|c';

    goto &_send;
}

sub dec {
    unshift @_, ( shift // return ) . ':-1|c';

    goto &_send;
}

sub inc {
    unshift @_, ( shift // return ) . ':1|c';

    goto &_send;
}

sub import {
    my $class  = shift;
    my $caller = caller . '::';

    no strict 'refs';

    *{ $caller . $_ } = $class->can($_) // Carp::croak qq/Unknown export "$_"/
        for @_;
}

sub _send {
    my ( $stat, $rate ) = @_;

    if ( defined $rate && $rate < 1 ) {
        return if rand > $rate;

        $stat .= '|@' . $rate;
    }

    return if defined $rate && rand > $rate;

    unless ($sock) {
        socket $sock, 2, 2, 0 or return;

        my $host = gethostbyname $host or return;

        connect $sock, pack 'Sna4x8', 2, $port, $host or return;
    }

    send $sock, $stat, 0;

    return;
}

package Net::StatsD::XS::Timer;

use Time::HiRes ();

sub send {
    $_ = int( Time::HiRes::time * 1_000 ) - ${ +shift };

    unshift @_, ( shift // return ) . ":$_|ms";

    goto &Net::StatsD::XS::_send;
}

1;

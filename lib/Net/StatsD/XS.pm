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
    _send( ( shift // return ) . ':' . ( shift // 1 )  . '|c', @_ );
}

sub dec {
    _send( ( shift // return ) . ':-1|c', @_ );
}

sub inc {
    _send( ( shift // return ) . ':1|c', @_ );
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

    unless ($sock) {
        socket $sock, 2, 2, 0 or return;

        my $host = gethostbyname $host or return;

        connect $sock, pack 'Sna4x8', 2, $port, $host or return;
    }

    send $sock, $stat, 0;

    return;
}

package Net::StatsD::XS::Timer;

sub send {
    Net::StatsD::XS::_send(
        ( $_[1] // return ) . ':' . ( _time() - ${ $_[0] } ) . '|ms', $_[2] );
}

1;

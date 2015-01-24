use lib 't';
use t   '4';

my $timer = timer;

is ref $timer, 'Net::StatsD::XS::Timer',
    'timer returns a Net::StatsD::XS::Timer';

ok $timer->can('send'), 'timer can send';

$timer->send('foo');

like t::read, qr/^foo:\d+\|ms$/;

for (0..9) {
    $timer->send( bar => .999 );

    next unless $_ = t::read;

    like $_, qr/^bar:\d+\|ms\|\@0\.999$/, 'sampled message is correct';

    last;
}

use lib 't';
use t   '3';

my $timer = timer;

is ref $timer, 'Net::StatsD::XS::Timer',
    'timer returns a Net::StatsD::XS::Timer';

ok $timer->can('send'), 'timer can send';

$timer->send('foo');

like t::read, qr/foo:\d+\|ms/;

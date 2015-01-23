use lib 't';
use t   '3';

my $timer = timer;

is ref $timer, 'WebService::StatsD::Timer',
    'timer returns a WebService::StatsD::Timer';

ok $timer->can('send'), 'timer can send';

$timer->send('foo');

like t::read, qr/foo:\d+\|ms/;

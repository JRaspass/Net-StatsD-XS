use strict;
use warnings;

use Test::Fatal;
use Test::More;

require Net::StatsD::XS;

package default { Net::StatsD::XS->import }

is_deeply [ sort keys %default:: ], [], 'use Net::StatsD::XS';

package dec { Net::StatsD::XS->import('dec') }

is_deeply [ sort keys %dec:: ], ['dec'], "use Net::StatsD::XS 'dec'";

package inc { Net::StatsD::XS->import('inc') }

is_deeply [ sort keys %inc:: ], ['inc'], "use Net::StatsD::XS 'inc'";

package dec_inc { Net::StatsD::XS->import(qw/dec inc/) }

is_deeply [ sort keys %dec_inc:: ], [qw/dec inc/],
    'use Net::StatsD::XS qw/dec inc/';

is exception { Net::StatsD::XS->import('foo') },
    'Unknown export "foo" at ' . __FILE__ . ' line ' . (__LINE__ - 1) . ".\n",
    "use Net::StatsD::XS 'foo'";

done_testing;

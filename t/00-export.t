use strict;
use warnings;

use Test::Fatal;
use Test::More;

require WebService::StatsD;

package default { WebService::StatsD->import }

is_deeply [ sort keys %default:: ], [], 'use WebService::StatsD';

package dec { WebService::StatsD->import('dec') }

is_deeply [ sort keys %dec:: ], ['dec'], "use WebService::StatsD 'dec'";

package inc { WebService::StatsD->import('inc') }

is_deeply [ sort keys %inc:: ], ['inc'], "use WebService::StatsD 'inc'";

package dec_inc { WebService::StatsD->import(qw/dec inc/) }

is_deeply [ sort keys %dec_inc:: ], [qw/dec inc/],
    'use WebService::StatsD qw/dec inc/';

is exception { WebService::StatsD->import('foo') },
    'Unknown export "foo" at ' . __FILE__ . ' line ' . (__LINE__ - 1) . ".\n",
    "use WebService::StatsD 'foo'";

done_testing;

package t;

use strict;
use warnings;

socket my $sock, 2, 2, 0;

# Non-blocking.
fcntl $sock, 4, 2048;

# TODO use literal hex value here.
bind $sock, pack 'SxxNx8', 2, 2_130_706_433;

require WebService::StatsD;

WebService::StatsD::set_port( unpack 'xxn', getsockname $sock );

sub import {
    strict->import;
    warnings->import;

    eval qq/
        package ${\scalar caller};

        use Test::More tests => $_[1];
        use WebService::StatsD qw(count dec inc timer);
    /;
}

sub read {
    recv $sock, my $data, 1024, 0;

    $data;
}

1;

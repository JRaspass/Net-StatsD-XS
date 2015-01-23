use lib 't';
use t   '12';

subtest $_->[0] => sub {
    is eval $_->[0], undef, 'returns nothing';

    is t::read, $_->[1], 'sends correct UDP message';
} for (
    [ 'dec()'                                        => '' ],
    [ 'dec("foo")'                                   => 'foo:-1|c' ],
    [ 'dec("bar", 0)'                                => '' ],
    [ 'dec("baz", 0.0)'                              => '' ],
    [ 'dec("qux", 1)'                                => 'qux:-1|c' ],
    [ 'dec("quux", 1.0)'                             => 'quux:-1|c' ],
    [ 'dec("corge", 1, "redundant")'                 => 'corge:-1|c' ],
    [ 'dec("grault", 1, "redundant", "superfluous")' => 'grault:-1|c' ],
    [ 'dec(undef)'                                   => '' ],
    [ 'dec("garply", undef)'                         => 'garply:-1|c' ],
    [ 'dec("waldo", 3.14159)'                        => 'waldo:-1|c' ],
);

for (0..9) {
    dec 'fred', .999;

    next unless $_ = t::read;

    is $_, 'fred:-1|c|@0.999', 'sampled message is correct';

    last;
}

use lib 't';
use t   '12';

subtest $_->[0] => sub {
    is eval $_->[0], undef, 'returns nothing';

    is t::read, $_->[1], 'sends correct UDP message';
} for (
    [ 'inc()'                                        => '' ],
    [ 'inc("foo")'                                   => 'foo:1|c' ],
    [ 'inc("bar", 0)'                                => '' ],
    [ 'inc("baz", 0.0)'                              => '' ],
    [ 'inc("qux", 1)'                                => 'qux:1|c' ],
    [ 'inc("quux", 1.0)'                             => 'quux:1|c' ],
    [ 'inc("corge", 1, "redundant")'                 => 'corge:1|c' ],
    [ 'inc("grault", 1, "redundant", "superfluous")' => 'grault:1|c' ],
    [ 'inc(undef)'                                   => '' ],
    [ 'inc("garply", undef)'                         => 'garply:1|c' ],
    [ 'inc("waldo", 3.14159)'                        => 'waldo:1|c' ],
);

for (0..9) {
    inc 'fred', .999;

    next unless $_ = t::read;

    is $_, 'fred:1|c|@0.999', 'sampled message is correct';

    last;
}

use lib 't';
use t   '10';

subtest $_->[0] => sub {
    is eval $_->[0], undef, 'returns nothing';

    is t::read, $_->[1], 'sends correct UDP message';
} for (
    [ 'inc()'                                        => '' ],
    [ 'inc("foo")'                                   => 'foo:1c' ],
    [ 'inc("bar", 0)'                                => '' ],
    [ 'inc("baz", 0.0)'                              => '' ],
    [ 'inc("qux", 1)'                                => 'qux:1c' ],
    [ 'inc("quux", 1.0)'                             => 'quux:1c' ],
    [ 'inc("corge", 1, "redundant")'                 => 'corge:1c' ],
    [ 'inc("grault", 1, "redundant", "superfluous")' => 'grault:1c' ],
    [ 'inc(undef)'                                   => '' ],
    [ 'inc("garply", undef)'                         => 'garply:1c' ],
);

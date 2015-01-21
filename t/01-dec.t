use lib 't';
use t   '10';

subtest $_->[0] => sub {
    is eval $_->[0], undef, 'returns nothing';

    is t::read, $_->[1], 'sends correct UDP message';
} for (
    [ 'dec()'                                        => '' ],
    [ 'dec("foo")'                                   => 'foo:-1c' ],
    [ 'dec("bar", 0)'                                => '' ],
    [ 'dec("baz", 0.0)'                              => '' ],
    [ 'dec("qux", 1)'                                => 'qux:-1c' ],
    [ 'dec("quux", 1.0)'                             => 'quux:-1c' ],
    [ 'dec("corge", 1, "redundant")'                 => 'corge:-1c' ],
    [ 'dec("grault", 1, "redundant", "superfluous")' => 'grault:-1c' ],
    [ 'dec(undef)'                                   => '' ],
    [ 'dec("garply", undef)'                         => 'garply:-1c' ],
);

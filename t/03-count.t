use lib 't';
use t   '5';

count;
is t::read, '', 'count';

count 'foo';
is t::read, 'foo:1|c', "count 'foo'";

count bar => 0;
is t::read, 'bar:0|c', "count 'bar'";

count baz => 3;
is t::read, 'baz:3|c', 'count baz => 3';

count qux => 3, 0;
is t::read, '', 'count qux => 3, 0';

use lib 't';
use t   '3';

inc;
is t::read, '', 'inc';

inc 'foo';
is t::read, 'foo:1c', "inc 'foo'";

inc 'bar', 0;
is t::read, '', "inc 'bar', 0";

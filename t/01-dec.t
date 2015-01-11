use lib 't';
use t   '3';

dec;
is t::read, '', 'dec';

dec 'foo';
is t::read, 'foo:-1c', "dec 'foo'";

dec 'bar', 0;
is t::read, '', "dec 'bar', 0";

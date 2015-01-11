#define PERL_NO_GET_CONTEXT
#include <EXTERN.h>
#include <perl.h>

#ifndef newXS_deffile
#   define newXS_deffile(a, b) Perl_newXS(aTHX_ a, b, __FILE__)
#endif

static void dec(pTHX_ CV *cv __attribute__((unused))) {
    const unsigned int items
        = PL_stack_sp - (PL_stack_base + *PL_markstack_ptr--);

    if(items == 0)
        return;

    // Get a pointer one below our arguments and set PL_stack_sp back so we
    // return nothing. Therefore $_[0] == sp[1].
    SV **sp = PL_stack_sp -= items;

    if (items > 1) {
        if (!PL_srand_called) {
            seedDrand01((Rand_seed_t)seed());
            PL_srand_called = TRUE;
        }

        if (Drand01() > SvNVx(sp[2]))
            return;
    }

    STRLEN len;
    char *stat = SvPV(sp[1], len);

    char *msg = (char *)alloca(len + 4);

    strcpy(msg, stat);
    strcpy(msg + len, ":-1c");

    int sock;

    struct sockaddr_in address;

    if ((sock = socket(AF_INET, SOCK_DGRAM, 0)) < 0)
        return;

    char *ip = "127.0.0.1";

    inet_aton(ip, &address.sin_addr);

    SV *port = get_sv("WebService::StatsD::port", 0);
    address.sin_port = htons(SvIV(port));

    sendto(sock, msg, len + 4, 0, (struct sockaddr *)&address, sizeof(address));
}

void boot_WebService__StatsD(pTHX_ CV *cv __attribute__((unused))) {
    newXS_deffile("WebService::StatsD::dec", dec);
}

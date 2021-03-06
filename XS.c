#define PERL_NO_GET_CONTEXT
#include <EXTERN.h>
#include <perl.h>

#ifndef __has_builtin
#   define __has_builtin(x) 0
#endif

#ifndef NOT_REACHED
#   if __has_builtin(__builtin_unreachable) || (__GNUC__ == 4 && __GNUC_MINOR__ >= 5 || __GNUC__ > 4)
#       define NOT_REACHED __builtin_unreachable()
#   elif defined(_MSC_VER)
#       define NOT_REACHED __assume(0)
#   elif defined(__ARMCC_VERSION)
#       define NOT_REACHED __promise(0)
#   else
#       define NOT_REACHED assert(0)
#   endif
#endif

#ifndef newXS_deffile
#   define newXS_deffile(a, b) Perl_newXS(aTHX_ a, b, __FILE__)
#endif

/*int sock = -1;

struct sockaddr_in address;

static void _send(pTHX_ CV *cv) {
    const unsigned int items
        = PL_stack_sp - (PL_stack_base + *PL_markstack_ptr--);

    if(items == 0)
        return;

    // Get a pointer one below our arguments and set PL_stack_sp back so we
    // return nothing. Therefore $_[0] == sp[1].
    SV **sp = PL_stack_sp -= items;

    SV *delta = &PL_sv_no;
    const I32 ix = CvXSUBANY(cv).any_i32;

    if (ix == 2) {
        if (items == 1) {
            delta = &PL_sv_yes;
        }
        else if ( items == 2 ) {
            delta = sp[2];
        }
        else {
            delta = sp[2];

            if (!PL_srand_called) {
                seedDrand01((Rand_seed_t)seed());
                PL_srand_called = TRUE;
            }

            if (Drand01() > SvNVx(sp[3]))
                return;
        }
    }
    else {
        if (items > 1) {
            if (!PL_srand_called) {
                seedDrand01((Rand_seed_t)seed());
                PL_srand_called = TRUE;
            }

            if (Drand01() > SvNVx(sp[2]))
                return;
        }
    }

    STRLEN len;
    char *stat = SvPV(sp[1], len);

    char *msg;

    switch (ix) {
        case 0: {
            msg = (char *)alloca(len + 4);

            STRLEN i;
            for (i = 0; i != len; i++)
                msg[i] = stat[i];

            msg[len++] = ':';
            msg[len++] = '-';
            msg[len++] = '1';
            msg[len++] = 'c';

            break;
        }
        case 1: {
            msg = (char *)alloca(len + 3);

            STRLEN i;
            for (i = 0; i != len; i++)
                msg[i] = stat[i];

            msg[len++] = ':';
            msg[len++] = '1';
            msg[len++] = 'c';

            break;
        }
        case 2: {
            msg = (char *)alloca(len + 5);

            STRLEN i;
            for (i = 0; i != len; i++)
                msg[i] = stat[i];

            msg[len++] = ':';

            STRLEN delta_len;
            char *delta_p = SvPV(delta, delta_len);

            for(i = 0; i != delta_len; i++)
                msg[len++] = delta_p[i];

            msg[len++] = 'c';

            break;
        }
        default:
            NOT_REACHED;
    }

    if (sock == -1) {
        if ((sock = socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
            warn("Failed to create socket, error: %d\n", errno);

            return;
        }

        address.sin_family = AF_INET;

        char *ip = "127.0.0.1";

        inet_aton(ip, &address.sin_addr);

        SV *port = get_sv("Net::StatsD::XS::port", 0);
        address.sin_port = htons(SvIV(port));
    }

    ssize_t bytes_sent
        = sendto(sock, msg, len, 0, (struct sockaddr *)&address, sizeof(address));

    if (bytes_sent == -1)
        warn("Failed to send UDP packet, error: %d\n", errno);
}*/

static HV *timer_stash;

static OP *timer(pTHX) {
    struct timeval tv;

    gettimeofday(&tv, NULL);

    SV *sv = newSViv( tv.tv_sec * 1000 + tv.tv_usec / 1000 );

    sv_upgrade(sv, SVt_PVMG);

    SvFLAGS(sv) = SVf_IOK | SVp_IOK | SVs_OBJECT | SVt_PVMG;

    SvREFCNT(timer_stash)++;
    SvSTASH_set(sv, timer_stash);

    // Create a new IV, and make it the return value.
    SV *rv = *( PL_stack_sp = PL_stack_base + *PL_markstack_ptr-- + 1 )
           = newSV_type(SVt_IV);

    SvROK_on(rv);
    SvRV_set(rv, sv);

    return NORMAL;
}

static void empty(pTHX_ CV *cv __attribute__((unused))) {}

static OP *call_checker(pTHX_ OP *entersubop, GV *namegv __attribute__((unused)), SV *ckobj __attribute__((unused))) {
    op_free(entersubop);

    OP *op = newOP(OP_CUSTOM, 0);

    op->op_ppaddr = timer;

    return op;
}

// Used by Net::StatsD::XS::Timer::send.
static void _time(pTHX_ CV *cv __attribute__((unused))) {
    struct timeval tv;

    gettimeofday(&tv, NULL);

    *( PL_stack_sp = PL_stack_base + *PL_markstack_ptr-- + 1 )
        = newSViv( tv.tv_sec * 1000 + tv.tv_usec / 1000 );
}

void boot_Net__StatsD__XS(pTHX_ CV *cv __attribute__((unused))) {
    /*CvXSUBANY(newXS_deffile("Net::StatsD::XS::dec", _send)).any_i32 = 0;

    CvXSUBANY(newXS_deffile("Net::StatsD::XS::inc", _send)).any_i32 = 1;

    CvXSUBANY(newXS_deffile("Net::StatsD::XS::count", _send)).any_i32 = 2;*/

    static XOP op_timer;

    XopENTRY_set(&op_timer, xop_name, "timer");

    Perl_custom_op_register(aTHX_ timer, &op_timer);

    newXS_deffile("Net::StatsD::XS::Timer::_time", _time);

    cv = newXS_deffile("Net::StatsD::XS::timer", empty);

    cv_set_call_checker(cv, call_checker, (SV*)cv);

    timer_stash
        = Perl_gv_stashpvn(aTHX_ STR_WITH_LEN("Net::StatsD::XS::Timer"), 0);
}

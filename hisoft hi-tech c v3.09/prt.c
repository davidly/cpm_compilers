/*
   This code originally taken from Apple's open source project.
   I'm not using it for anything other than testing rvos.
   I made changes to support 64 bit-integers and rvos and enable
   building on a more modern compiler.
*/

#include <stdarg.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

#define isdigit(d) ((d) >= '0' && (d) <= '9')
#define Ctod(c) ((c) - '0')

#define MAXBUF ( sizeof( uint64_t ) * 8 )  // enough for binary

static void printnum( uint64_t u,   /* number to print */
               int  base,
               void (*putc)(char))
{
    char buf[MAXBUF];
    char * p = &buf[MAXBUF-1];
    static char digs[] = "0123456789abcdef";

    do
    {
        *p-- = digs[u % base];
        u /= base;
    } while (u != 0);

    while (++p != &buf[MAXBUF])
        (*putc)(*p);
} //printnum

static void printfloat( float f, int precision, void (*putc)(char) )
{
    if ( f < 0.0 )
    {
        (*putc)( '-' );
        f *= -1.0;
    }
    
    long wholePart = (long) f;
    printnum( wholePart, 10, putc );

    if ( precision > 0 )
    {
        (*putc)( '.' );
        float fraction = f - wholePart;

        while( precision > 0 )
        {
            fraction *= 10;
            wholePart = (long) fraction;
            (*putc)( '0' + wholePart );

            fraction -= wholePart;
            precision--;
        }
    }
} //printfloat

void printdouble( double d, int precision, void (*putc)(char) )
{
    if ( d < 0.0 )
    {
        (*putc)( '-' );
        d *= -1.0;
    }
    
    long wholePart = (long) d;
    printnum( wholePart, 10, putc );

    if ( precision > 0 )
    {
        (*putc)( '.' );
        double fraction = d - wholePart;

        while( precision > 0 )
        {
            fraction *= 10;
            wholePart = (long) fraction;
            (*putc)( '0' + wholePart );

            fraction -= wholePart;
            precision--;
        }
    }
} //printdouble

const static bool _doprnt_truncates = false;

static void _doprnt(
        const char     *fmt,
        va_list        *argp,
        void           (*putc)(char),
        int            radix)          /* default radix - for '%r' */
{
        int      length;
        int      prec;
        bool     ladjust;
        char     padc;
        int64_t  n;
        uint64_t u;
        int      plus_sign;
        int      sign_char;
        bool     altfmt, truncate;
        int      base;
        char     c;
        int      capitals;
        int      num_width = 4;

        while ((c = *fmt) != '\0') {
            if (c != '%') {
                (*putc)(c);
                fmt++;
                continue;
            }

            fmt++;

            length = 0;
            prec = -1;
            ladjust = false;
            padc = ' ';
            plus_sign = 0;
            sign_char = 0;
            altfmt = false;

            while (true) {
                c = *fmt;
                if (c == '#') {
                    altfmt = true;
                }
                else if (c == '-') {
                    ladjust = true;
                }
                else if (c == '+') {
                    plus_sign = '+';
                }
                else if (c == ' ') {
                    if (plus_sign == 0)
                        plus_sign = ' ';
                }
                else
                    break;
                fmt++;
            }

            if (c == '0') {
                padc = '0';
                c = *++fmt;
            }

            if (isdigit(c)) {
                while(isdigit(c)) {
                    length = 10 * length + Ctod(c);
                    c = *++fmt;
                }
            }
            else if (c == '*') {
                length = va_arg(*argp, int);
                c = *++fmt;
                if (length < 0) {
                    ladjust = !ladjust;
                    length = -length;
                }
            }

            if (c == '.') {
                c = *++fmt;
                if (isdigit(c)) {
                    prec = 0;
                    while(isdigit(c)) {
                        prec = 10 * prec + Ctod(c);
                        c = *++fmt;
                    }
                }
                else if (c == '*') {
                    prec = va_arg(*argp, int);
                    c = *++fmt;
                }
            }

            if (c == 'l')
            {
                c = *++fmt;     /* need it if sizeof(int) < sizeof(long) */
                if ( c == 'l' )
                {
                    c = *++fmt;
                    num_width = 8;
                }
            }

            truncate = false;
            capitals=0;         /* Assume lower case printing */

            switch(c) {
                case 'b':
                case 'B':
                {
                    char *p;
                    bool     any;
                    int  i;

                    if ( 4 == num_width )
                        u = va_arg(*argp, uint32_t );
                    else
                        u = va_arg(*argp, uint64_t );
                    p = va_arg(*argp, char *);
                    base = *p++;
                    printnum(u, base, putc);

                    if (u == 0)
                        break;

                    any = false;
                    while ((i = *p++) != '\0') {
                        if (*fmt == 'B')
                            i = 33 - i;
                        if (*p <= 32) {
                            /*
                             * Bit field
                             */
                            int j;
                            if (any)
                                (*putc)(',');
                            else {
                                (*putc)('<');
                                any = true;
                            }
                            j = *p++;
                            if (*fmt == 'B')
                                j = 32 - j;
                            for (; (c = *p) > 32; p++)
                                (*putc)(c);
                            printnum((unsigned)( (u>>(j-1)) & ((2<<(i-j))-1)),
                                        base, putc);
                        }
                        else if (u & (1<<(i-1))) {
                            if (any)
                                (*putc)(',');
                            else {
                                (*putc)('<');
                                any = true;
                            }
                            for (; (c = *p) > 32; p++)
                                (*putc)(c);
                        }
                        else {
                            for (; *p > 32; p++)
                                continue;
                        }
                    }
                    if (any)
                        (*putc)('>');
                    break;
                }

                case 'c':
                    c = va_arg(*argp, int);
                    (*putc)(c);
                    break;

                case 's':
                {
                    char *p;
                    char *p2;

                    if (prec == -1)
                        prec = 0x7fffffff;      /* MAXINT */

                    p = va_arg(*argp, char *);

                    if (p == (char *)0)
                        p = (char *) "";

                    if (length > 0 && !ladjust) {
                        n = 0;
                        p2 = p;

                        for (; *p != '\0' && n < prec; p++)
                            n++;

                        p = p2;

                        while (n < length) {
                            (*putc)(' ');
                            n++;
                        }
                    }

                    n = 0;

                    while (*p != '\0') {
                        if (++n > prec || (length > 0 && n > length))
                            break;

                        (*putc)(*p++);
                    }

                    if (n < length && ladjust) {
                        while (n < length) {
                            (*putc)(' ');
                            n++;
                        }
                    }

                    break;
                }

                case 'o':
                    truncate = _doprnt_truncates;
                case 'O':
                    base = 8;
                    goto print_unsigned;

                case 'd':
                    truncate = _doprnt_truncates;
                case 'D':
                    base = 10;
                    goto print_signed;

                case 'f':
                    goto print_float;

                case 'u':
                    truncate = _doprnt_truncates;
                case 'U':
                    base = 10;
                    goto print_unsigned;

                case 'p':
                    altfmt = true;
                case 'x':
                    truncate = _doprnt_truncates;
                    base = 16;
                    goto print_unsigned;

                case 'X':
                    base = 16;
                    capitals=16;        /* Print in upper case */
                    goto print_unsigned;

                case 'z':
                    truncate = _doprnt_truncates;
                    base = 16;
                    goto print_signed;
                        
                case 'Z':
                    base = 16;
                    capitals=16;        /* Print in upper case */
                    goto print_signed;

                case 'r':
                    truncate = _doprnt_truncates;
                case 'R':
                    base = radix;
                    goto print_signed;

                case 'n':
                    truncate = _doprnt_truncates;
                case 'N':
                    base = radix;
                    goto print_unsigned;

                print_signed:
                    if ( 4 == num_width )
                        n = va_arg(*argp, int32_t );
                    else
                        n = va_arg(*argp, int64_t );
                    if (n >= 0) {
                        u = n;
                        sign_char = plus_sign;
                    }
                    else {
                        u = -n;
                        sign_char = '-';
                    }
                    goto print_num;

                print_unsigned:
                    if ( 4 == num_width )
                        u = va_arg(*argp, uint32_t );
                    else
                        u = va_arg(*argp, uint64_t );
                    goto print_num;

                print_num:
                {
                    char        buf[MAXBUF];    /* build number here */
                    char *     p = &buf[MAXBUF-1];
                    static char digits[] = "0123456789abcdef0123456789ABCDEF";
                    char *prefix = 0;

                    if (truncate) u = (long)((int)(u));

                    if (u != 0 && altfmt) {
                        if (base == 8)
                            prefix = (char *) "0";
                        else if (base == 16)
                            prefix = (char *) "0x";
                    }

                    do {
                        /* Print in the correct case */
                        *p-- = digits[(u % base)+capitals];
                        u /= base;
                    } while (u != 0);

                    length -= (&buf[MAXBUF-1] - p);
                    if (sign_char)
                        length--;
                    if (prefix)
                        length -= strlen((const char *) prefix);

                    if (padc == ' ' && !ladjust) {
                        /* blank padding goes before prefix */
                        while (--length >= 0)
                            (*putc)(' ');
                    }
                    if (sign_char)
                        (*putc)(sign_char);
                    if (prefix)
                        while (*prefix)
                            (*putc)(*prefix++);
                    if (padc == '0') {
                        /* zero padding goes after sign and prefix */
                        while (--length >= 0)
                            (*putc)('0');
                    }
                    while (++p != &buf[MAXBUF])
                        (*putc)(*p);

                    if (ladjust) {
                        while (--length >= 0)
                            (*putc)(' ');
                    }
                    break;
                }
                print_float: // only 4-byte floats are supported
                {
                    // varargs promotes floats to doubles in va_arg

                    double d = va_arg( *argp, double );
                    printdouble( d, ( -1 == prec ? 6 : prec ), putc );
                    break;
                }

                case '\0':
                    fmt--;
                    break;

                default:
                    (*putc)(c);
            }
        fmt++;
        }
} //_doprnt

extern "C" void riscv_print_text( const char * p );

static void conslog_putc( char c)
{
    static char ac[2] = {0};
    ac[0] = c;
    riscv_print_text( ac );
}

extern "C" void riscv_printf( const char *fmt, ... )
{
    va_list listp;
    va_start(listp, fmt);
    _doprnt(fmt, &listp, conslog_putc, 16);
    va_end(listp);
} //riscv_printf

static char *copybyte_str;

static void copybyte( char byte )
{
  *copybyte_str++ = byte;
  *copybyte_str = '\0';
} //copybyte

extern "C" int riscv_sprintf( char *buf, const char *fmt, ... )
{
    va_list listp;
    va_start(listp, fmt);
    copybyte_str = buf;
    _doprnt(fmt, &listp, copybyte, 16);
    va_end(listp);
    return strlen(buf);
} //riscv_sprintf

extern "C" char * riscv_floattoa( char * buffer, float f, int precision )
{
    copybyte_str = buffer;
    printfloat( f, 6, copybyte );
    return buffer;
} //riscv_floattoa

// no threads = no locks. satisify the Gnu C runtime's requirements so other parts of the runtime work

extern "C" void _lock_acquire_recursive( _lock_t * ) {}
extern "C" void _lock_release_recursive( _lock_t * ) {}
extern "C" void _lock_close_recursive( _lock_t * ) {}
extern "C" void _lock_init_recursive( _lock_t * ) {}
extern "C" void pthread_setcancelstate() {}

#if false
int main()
{
    char ac[100];

    riscv_sprintf( ac, "hello %d\n", 27 );
    riscv_print_text( ac );
    riscv_printf( "and now from printf: %d\n", 37 );
    return 0;
}
#endif

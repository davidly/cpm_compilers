#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

extern "C" int main()
{
    char ac[100];
    strcpy( ac, "TZ=PST+8" );
    putenv( ac );

    time_t tt;
    time( &tt );
    struct tm * t = localtime( &tt );

    printf( "year: %d, month %d, day %d, hour %d, min %d, sec %d\n",
            t->tm_year + 1900, 1 + t->tm_mon, t->tm_mday, t->tm_hour, t->tm_min, t->tm_sec );

    return 0;
} //main



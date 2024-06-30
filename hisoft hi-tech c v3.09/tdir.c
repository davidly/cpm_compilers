#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <sys/stat.h>

int main( int argc, char * argv[] )
{
    const char * foldername = "testfolder";

    int result = mkdir( foldername, S_IRWXU );
    if ( 0 != result )
    {
        printf( "mkdir failed, error %d\n", errno );
        printf( "folder '%s' exists; deleting it\n", foldername );
        result = rmdir( foldername );
        if ( 0 != result )
        {
            printf( "rmdir of folder failed, error %d\n", errno );
            exit( 1 );
        }

        int result = mkdir( foldername, S_IRWXU );
        if ( 0 != result )
        {
            printf( "creation of folder failed, error %d\n", errno );
            exit( 1 );
        }
    }

    result = chdir( foldername );
    if ( 0 != result )
    {
        printf( "cd into the test folder failed, error %d\n", errno );
        exit( 1 );
    }

    result = chdir( ".." );
    if ( 0 != result )
    {
        printf( "cd back up to previous folder .. failed, error %d\n", errno );
        exit( 1 );
    }

    printf( "success\n" );
    return 0;
} //main


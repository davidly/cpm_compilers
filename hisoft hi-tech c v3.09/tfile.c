#include <stdio.h>

long portable_filelen( FILE * fp )
{
    long current = ftell( fp );
    fseek( fp, 0, SEEK_END );
    long len = ftell( fp );
    fseek( fp, current, SEEK_SET );
    return len;
} //portable_filelen

int main( int argc, char * argv[] )
{
    FILE * fp = fopen( "test.txt", "r" );
    if ( fp )
    {
        printf( "file open succeeded, fp %p\n", fp );

        long filelen = portable_filelen( fp );
        printf( "filelen: %ld\n", filelen );

        if ( filelen > 0 )
        {
            unique_ptr<char> dictionary( new char [ filelen + 1 ] );
            long lread = fread( dictionary.get(), 1, filelen, fp );

            printf( "result of read: %ld\n", lread );

            if ( 0 == lread )
            {
                printf( "unable to read dictionary file, return value %ld, errno %d\n", lread, errno );
                return 0;
            }
    
            dictionary.get()[ lread ] = 0;
    
            printf( "input file: %s\n", dictionary.get() );
        }

        int result = fclose( fp );

        if ( 0 == result )
            printf( "file close succeeded\n" );
        else
            printf( "file close failed, errno %d\n", errno );
    }
    else
        printf( "can't open file, error %d\n", errno );

    return 0;
} //main


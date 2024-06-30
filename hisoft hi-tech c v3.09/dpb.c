#define LINT_ARGS

#include <stdio.h>

typedef unsigned char uint8_t;
typedef unsigned int uint16_t;
typedef unsigned long uint32_t;

struct DiskParameterBlock /* for BDOS 31. https://www.seasip.info/Cpm/format22.html */
{
    uint16_t spt;    /* Number of 128-byte records per track                  */
    uint8_t  bsh;    /* Block shift. 3 => 1k, 4 => 2k, 5 => 4k....            */
    uint8_t  blm;    /* Block mask. 7 => 1k, 0Fh => 2k, 1Fh => 4k...          */
    uint8_t  exm;    /* Extent mask, see later                                */
    uint16_t dsm;    /* (no. of blocks on the disc)-1                         */
    uint16_t drm;    /* (no. of directory entries)-1                          */
    uint8_t  al0;    /* Directory allocation bitmap, first byte               */
    uint8_t  al1;    /* Directory allocation bitmap, second byte              */
    uint16_t cks;    /* Checksum vector size, 0 for a fixed disc              */
    uint16_t off;    /* Offset, number of reserved tracks                     */
};

int main()
{
    struct DiskParameterBlock *pdpb = 0;

    pdpb = bdoshl( 31, 0 );

    printf( "pdpb: %x\n", pdpb );
    printf( "  spt / sectors per track:    %u\n", pdpb->spt );
    printf( "  bsh / block shift:          %u\n", pdpb->bsh );
    printf( "  blm / block mask:           %u\n", pdpb->blm );
    printf( "  exm / extent mask:          %u\n", pdpb->exm );
    printf( "  dsm / blocks minus 1:       %u\n", pdpb->dsm );
    printf( "  drm / dir entries minus 1:  %u\n", pdpb->drm );
    printf( "  al0 / alloc bitmap 1:       %u\n", pdpb->al0 );
    printf( "  al1 / alloc bitmap 2:       %u\n", pdpb->al1 );
    printf( "  cks / checksum vector size: %u\n", pdpb->cks );
    printf( "  off / offset in tracks:     %u\n", pdpb->off );
} /*main*/


#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <limits.h>
#include <assert.h>

#include <cstring>
#include <string>
#include <memory>
#include <vector>
#include <mutex>
#include <chrono>

//#include <rvos.h>

using namespace std;
using namespace std::chrono;

//#pragma GCC optimize ("O0")

#ifdef _MSC_VER

    #define USE_PPL
    #include <ppl.h>
    using namespace concurrency;

    // Don't include windows.h just for this one API that has no equivalent in the standard C++ runtime

    extern "C" unsigned long __stdcall GetModuleFileNameA( void * module, char * filename, unsigned long size );
    #define PATH_MAX 300

    char * realpath( char * exepath, char * output )
    {
        // ignore exepath since NULL refers to that module

        GetModuleFileNameA( NULL, output, PATH_MAX );

        return output;
    } //realpath

#else // likely G++ / Clang++

    //#define __forceinline __attribute__((always_inline))     // this generates useless warnings in g++ that I can't turn off. 
    #define __forceinline

    #ifndef __min
        #define __min( a, b ) ( a < b ) ? a : b
    #endif

    #ifndef _countof
        template < typename T, size_t N > size_t _countof( T ( & arr )[ N ] ) { return std::extent< T[ N ] >::value; }
    #endif

    char * strlwr( char * str )
    {
        unsigned char *p = (unsigned char *) str;
    
        while ( *p )
        {
            *p = (unsigned char) tolower( *p );
            p++;
        }
        return str;
    }//strlwr

#endif

class CAnagramSet;
class CRealDictionary;

const int MaxAnStringLen = 60;
CAnagramSet * g_Results = NULL;
int g_LongestWord = 0;
CRealDictionary * g_SortedWords = NULL;
bool g_IncrementalProgress = false;
bool g_OneThread = false;

// Set UseInternal to true to use memcmp and memcpy, but that's slower for both Windows and linux

#define UseInternalMemFunctions false

__forceinline void my_memcpy( void * a, void * b, int c )
{
#if UseInternalMemFunctions
    memcpy( a, b, c );
#else
    char *pa = (char *) a;
    char *pb = (char *) b;

    while ( c > 0 )
    {
        *pa++ = *pb++;
        c--;
    }
#endif
} //my_memcpy

class CFile
{
    public:
        FILE * fp;

        CFile( FILE * file )
        {
            fp = file;
        }

        ~CFile()
        {
            Close();
        }

        void Close()
        {
            if ( NULL != fp )
            {
                fclose( fp );
                fp = NULL;
            }
        }
};

class CAnString
{
    public:
        int len;
        char buf[ MaxAnStringLen + 1 ];

        CAnString( char * p, int c )
        {
            len = c;
            my_memcpy( buf, p, c + 1 );
        }

        CAnString( char * p )
        {
            len = strlen( p );
            my_memcpy( buf, p, len + 1 );
        }

        CAnString()
        {
            len = 0;
            buf[ 0 ] = 0;
        }

        CAnString( int l )
        {
            len = l;
            buf[ l ] = 0;
        }

        void Set( char * p, int lens )
        {
            len = lens;
            my_memcpy( buf, p, 1 + lens );
        }

        void Set( CAnString * p )
        {
            len = p->len;
            my_memcpy( buf, p->buf, 1 + len );
        }
}; //CAnString

class CBTEntry
{
    public:
        CBTEntry * left;
        CBTEntry * right;
        CAnString words;

        CBTEntry( char * s, int lens )
        {
            left = NULL;
            right = NULL;
            words.Set( s, lens );
        }
}; //CBTEntry

__forceinline int Compare( CAnString * a, CAnString * b )
{
    int l = __min( a->len, b->len );

#if UseInternalMemFunctions
    int c = memcmp( a->buf, b->buf, l );

    if ( 0 != c )
        return c;
#else
    char * pa = a->buf;
    char * pb = b->buf;
    char * pastpa = pa + l;

    do
    {
        int c = *pa - *pb;
        if ( 0 != c )
            return c;
        pa++;
        pb++;
    } while ( pa < pastpa );
#endif

    return a->len - b->len;
} //Compare

__forceinline int Compare( char * a, int lena, CAnString * b )
{
    int l = __min( lena, b->len );

#if UseInternalMemFunctions
    int c = memcmp( a, b->buf, l );

    if ( 0 != c )
        return c;
#else
    char * pa = a;
    char * pb = b->buf;
    char * pastpa = pa + l;

    do
    {
        int c = *pa - *pb;
        if ( 0 != c )
            return c;
        pa++;
        pb++;
    } while ( pa < pastpa );
#endif

    return lena - b->len;
} //Compare

__forceinline bool Same( CAnString * a, CAnString * b )
{
    if ( a->len != b->len )
        return false;

#if UseInternalMemFunctions
    return ( 0 == memcmp( a->buf, b->buf, a->len ) );
#else
    for ( int i = 0; i < a->len; i++ )
        if ( a->buf[ i ] != b->buf[ i ] )
            return false;

    return true;
#endif
}

class CBinaryTree
{
    private:
        CBTEntry * root;
        int count;
        std::mutex mtx;

    public:
        CBinaryTree()
        {
            root = NULL;
            count = 0;
        }

        void FreeTree( CBTEntry * p )
        {
            if ( NULL != p->left )
            {
                FreeTree( p->left );
                p->left = NULL;
            }

            if ( NULL != p->right )
            {
                FreeTree( p->right );
                p->right = NULL;
            }

            delete p;
        }

        ~CBinaryTree()
        {
            if ( NULL != root )
            {
                FreeTree( root );
                root = NULL;
            }
        }

        int Count() { return count; }

        bool Add( char * s, int lens )
        {
            lock_guard<mutex> lock( mtx );
            {
                if ( NULL == root )
                {
                    root = new CBTEntry( s, lens );
                    count++;
                    return true;
                }
    
                CBTEntry * e = root;
    
                do
                {
                    int c = Compare( s, lens, & e->words );
    
                    if ( 0 == c )
                        return false;
    
                    if ( c < 0 )
                    {
                        if ( NULL == e->left )
                        {
                            e->left = new CBTEntry( s, lens );
                            count++;
                            return true;
                        }
    
                        e = e->left;
                    }
                    else
                    {
                        if ( NULL == e->right )
                        {
                            e->right = new CBTEntry( s, lens );
                            count++;
                            return true;
                        }
    
                        e = e->right;
                    }
                } while ( true );
            }
        }

        bool IsEmpty()
        {
            return ( NULL == root );
        } //IsEmpty

        void Fill( CBTEntry * p, int * pCurrent, CAnString ** elements )
        {
            elements[ *pCurrent ] = & p->words;
            ( *pCurrent )++;

            if ( NULL != p->left )
                Fill( p->left, pCurrent, elements );

            if ( NULL != p->right )
                Fill( p->right, pCurrent, elements );
        }

        void Fill( int * pCurrent, CAnString ** elements )
        {
            if ( NULL != root )
                Fill( root, pCurrent, elements );
        }

}; //CBinaryTree

class CAnagramSet
{
    private:
        CBinaryTree ** pTrees;
        int treeCount;

    public:
        CAnagramSet( int c = 7 )
        {
            treeCount = c;
    
            pTrees = new CBinaryTree * [ c ];
            memset( pTrees, 0, c * sizeof ( CBinaryTree * ) );
    
            Clear();
        }
    
        ~CAnagramSet()
        {
            for ( int i = 0; i < treeCount; i++ )
            {
                if ( NULL != pTrees[ i ] )
                {
                    delete pTrees[ i ];
                    pTrees[ i ] = 0;
                }
            }
    
            delete [] pTrees;
            pTrees = NULL;
        }
    
        int Count()
        {
            int count = 0;
            for ( int i = 0; i < treeCount; i++ )
                count += pTrees[ i ]->Count();
    
            return count;
        }
    
        bool IsEmpty()
        {
            for ( int i = 0; i < treeCount; i++ )
                if ( 0 != pTrees[ i ]->Count() )
                    return false;
    
            return true;
        }
    
        bool Add( char * s, int lens )
        {
            CBinaryTree * p;
            if ( 1 == treeCount )
            {
                p = pTrees[ 0 ];
            }
            else
            {
                unsigned long hcode = GetHashCode( s, lens );
                p = pTrees[ hcode % treeCount ];
            }
    
            return p->Add( s, lens );
        }
    
        unsigned long GetHashCode( char * s, int lens )
        {
            unsigned long h = (unsigned long) lens;
    
            for ( int i = 0; i < lens; i++ )
            {
                h ^= 3u * s[ i ];
                h <<= 3;
            }
    
            return h;
        } //GetHashCode
    
        void Clear()
        {
            for ( int i = 0; i < treeCount; i++ )
            {
                if ( NULL != pTrees[ i ] )
                {
                    delete pTrees[ i ];
                    pTrees[ i ] = 0;
                }
    
                pTrees[ i ] = new CBinaryTree();
            }
        }
    
        void GetAnagrams( CAnString ** array, int count )
        {
            int sofar = 0;
    
            for ( int i = 0; i < treeCount; i++ )
                pTrees[ i ]->Fill( &sofar, array );

            assert( sofar == count );
        }
}; //CAnagramSet

class CWordEntry
{
    public:
        char * word;
        CWordEntry * next;

        CWordEntry( char * str, int len )
        {
            word = new char[ len + 1 ];
            strcpy( word, str );
            next = NULL;
        }
}; //CWordEntry

class CDictionaryEntry
{
    public: 
        CAnString sortedWord;
        CWordEntry * entries;
        CDictionaryEntry * next;

        CDictionaryEntry( CAnString * input, CWordEntry * pWordEntry, CDictionaryEntry * pDictionaryEntry )
        {
            sortedWord.Set( input );
            entries = pWordEntry;
            next = pDictionaryEntry;
        }
}; //CDictionaryEntry

class CRealDictionary
{
    private:
        CDictionaryEntry ** entries;
        static const int dictionaryHashSize = 1000003;

        __forceinline unsigned long long GetHashCode( CAnString * s )
        {
            int len = s->len;
            unsigned long long h = (unsigned long long) len;

            int i = 0;
            do
            {
                char x = s->buf[ i++ ] - 19;
                h ^= 3u * x;
                h <<= 4;
            } while ( i < len );

            return h;
        } //GetHashCode

    public:
        CRealDictionary()
        {
            entries = new CDictionaryEntry * [ dictionaryHashSize ];
            memset( entries, 0, dictionaryHashSize * sizeof ( CDictionaryEntry * ) );
        }

        int GetEntry( CAnString * input )
        {
            return (int) ( GetHashCode( input ) % ( unsigned long long) dictionaryHashSize );
        } //GetEntry

        void Add( CAnString * input, CWordEntry * p, int entry )
        {
            CDictionaryEntry * pEntry = entries[ entry ];

            CDictionaryEntry * newEntry = new CDictionaryEntry( input, p, pEntry );

            entries[ entry ] = newEntry;
        } //Add

        void Add( CAnString * input, CWordEntry * p )
        {
            Add( input, p, GetEntry( input ) );
        } //Add

        bool TryGetValue( CAnString * input, CWordEntry ** p, int entry )
        {
            CDictionaryEntry * pEntry = entries[ entry ];

            while ( NULL != pEntry )
            {
                if ( Same( & pEntry->sortedWord, input ) )
                {
                    *p = pEntry->entries;
                    return true;
                }

                pEntry = pEntry->next;
            }

            return false;
        } //TryGetValue

        bool TryGetValue( CAnString * input, CWordEntry ** p )
        {
            return TryGetValue( input, p, GetEntry( input ) );
        } //TryGetValue

        void Stats( int &longestChain, int &unused, int &moreThan5, int &collisions, int &singles )
        {
            moreThan5 = 0;
            longestChain = 0;
            collisions = 0;
            singles = 0;

            for ( int i = 0; i < dictionaryHashSize; i++ )
            {
                CDictionaryEntry *entry = entries[ i ];

                if ( NULL == entry )
                    unused++;
                else
                {
                    int count = 1;

                    entry = entry->next;

                    while ( NULL != entry )
                    {
                        count++;
                        entry = entry->next;
                    }

                    if ( count > 5 )
                        moreThan5++;

                    if ( 1 == count )
                        singles++;

                    if ( count > longestChain )
                    {
                        longestChain = count;

                        CDictionaryEntry *e = entries[ i ];

                        printf( "chain of %d hash %d\n", count, i );
                        while ( NULL != e )
                        {
                            printf( " '%s' (%d) ", e->sortedWord.buf, e->sortedWord.len );
                            e = e->next;
                        }

                        printf( "\n" );
                    }

                    if ( count > 1 )
                        collisions++;
                }
            }
        } //Stats
}; //CRealDictionary

class Combo
{
    private:
        int k;
        int kminus1;
        int nk;
        int istop;
        char * input;
        char * output;
        int num[ MaxAnStringLen ];

    public:
        Combo( CAnString * elements, CAnString * result, int K )
        {
            int inputLen = elements->len;
            input = elements->buf;
            output = result->buf;
            k = K;
            kminus1 = k - 1;
            nk = inputLen - 1 - kminus1;

            // Optimize the case when K is half the length (and the length is even obvs) by leaving the first char as-is.
            // This reduces the combinations produced in half by omitting duplicates.
            // Note that this forces Next() to be a while loop instead of a do..while loop to work with 2-char strings

            istop = ( ( k + k ) == inputLen ) ? 0 : -1;

            for ( int i = 0; i < k; i++ )
            {
                num[ i ] = i;
                output[ i ] = input[ i ];
            }
        } //Combo

        bool Next()
        {
            int i = kminus1;

            // can't be a do..while loop because that would produce duplicate results for 2-char strings ( a & b + b & a )

            while ( i > istop )
            {
                if ( num[ i ] < ( nk + i ) )
                {
                    int n = num[ i ] = num[ i ] + 1;
                    output[ i ] = input[ n ];
    
                    if ( i < kminus1 )
                    {
                        for ( int j = i + 1; j < k; j++ )
                        {
                            n = num[ j ] = num[ j - 1 ] + 1;
                            output[ j ] = input[ n ];
                        }
                    }
    
                    return true;
                }

                i--;
            }
    
            return false;
        } //Next
}; //Combo

int SpaceCount( CAnString * p )
{
    int spaces = 0;

    for ( int i = 0; i < p->len; i++ )
        if ( ' ' == p->buf[ i ] )
            spaces++;

    return spaces;
} //SpaceCount

class CStringBuilder
{
    private:
        char * pbuf;
        int allocated;
        int used;

    public:
        CStringBuilder( int initialSize = 100 )
        {
            allocated = initialSize;
            pbuf = new char[ allocated ];
            used = 0;
        }

        ~CStringBuilder()
        {
            delete pbuf;
        }

        void Append( CAnString * p, int offset, int count )
        {
            EnsureSize( count );
            my_memcpy( pbuf + used, p->buf + offset, count );
            used += count;
        }

        void Append( char * p, int len )
        {
            EnsureSize( len );
            my_memcpy( pbuf + used, p, len );
            used += len;
        }

        void Append( CAnString * p )
        {
            Append( p->buf, p->len );
        }

        void Append( char * p )
        {
            Append( p, strlen( p ) );
        }

        void Append( char c )
        {
            EnsureSize( 1 );
            pbuf[ used++ ] = c;
        }

        void Append( char c, int count )
        {
            EnsureSize( count );

            for ( int x = 0; x < count; x++ )
                pbuf[ used++ ] = c;
        }

        void EnsureSize( int touse )
        {
            int request = touse + used;

            // >= to reserve space for a null at the end.

            if ( request >= allocated )
            {
                int oldsize = allocated;

                do
                {
                    allocated *= 2;
                } while ( allocated <= request );

                char * pnew = new char[ allocated ];
                my_memcpy( pnew, pbuf, used );
                delete pbuf;
                pbuf = pnew;
            }
        } //EnsureSize

        char * ToString( int & len )
        {
            // the caller doesn't own the string and it's only valid until the next call into this object.

            len = used;
            pbuf[ used ] = 0;
            return pbuf;
        } //ToString

        void Reset()
        {
            used = 0;
        }

        int Length() { return used; }

        void SetLength( int length )
        {
            // This function is just very trusting
            assert( length < allocated );

            used = length;
        }
}; //CStringBuilder

int FindSpace( CAnString * p, int offset )
{
    int o = offset;

    while ( o < p->len )
    {
        if ( ' ' == p->buf[ o ] )
            return o;

        o++;
    }

    return -1;
} //FindSpace

int Compare( char * a, int aLength, char * b, int bOffset, int bLength )
{
    int o = 0;
    int l = __min( aLength, bLength );

    while ( o < l )
    {
        if ( a[ o ] != b[ o + bOffset ] )
            return a[ o ] - b[ o + bOffset ];

        o++;
    }

    return aLength - bLength;
} //Compare

void AddAnagram( CAnagramSet * set, char * pAnagram, int len )
{
    bool fAdded = set->Add( pAnagram, len );

    if ( g_IncrementalProgress && ( set == g_Results ) && fAdded )
        printf( "%s\n", pAnagram );
} //AddAnagram

void FindPhraseAnagrams( CAnagramSet * set, CAnString * input, int anagramWords );

void InsidePhraseAnagrams( CAnagramSet * set, CAnString * input, int anagramWords, int len )
{
    //printf( "ipa, input '%s', awords %d, len %d\n", input->buf, anagramWords, len );

    int rightlen = input->len - len;

    if ( ( len > g_LongestWord ) || ( ( 2 == anagramWords ) && ( rightlen > g_LongestWord ) ) )
        return;

    CAnString left( len );
    CAnString leftPrevious( len );
    CAnString right( rightlen );

    //printf( "top, left %s, prev %s, right %s\n", left.buf, leftPrevious.buf, right.buf );
    
    unique_ptr<CStringBuilder> sb;
    unique_ptr<CAnagramSet> rightSet;
    
    // for each unique combination of characters in the input string at the specified length, written to left
    // note: when there are duplicate characters there will be duplicate combinations.
    
    Combo combo( input, &left, len );
    
    do
    {
        CWordEntry * listL;

        if ( ( g_SortedWords->TryGetValue( &left, &listL ) ) && ( !Same( &left, &leftPrevious ) ) )
        {
            leftPrevious.Set( &left );
    
            // Put input letters not in left into right. Take advantage of the fact that all arrays are sorted.
    
            int r = 0;
            int leftStart = 0;
    
            for ( int j = 0; j < input->len; j++ )
            {
                char c = input->buf[ j ];

                if ( leftStart < len )
                {
                    int l = leftStart;

                    do
                    {
                        int lc = left.buf[ l ];

                        if ( lc < c )
                        {
                            l++;
                            continue;
                        }
    
                        if ( lc == c )
                        {
                            c = (char) 0;
                            leftStart = l + 1;
                            break;
                        }
                        else
                        {
                            leftStart = l;
                            break;
                        }
                    } while ( l < len );

                    if ( l == len )
                        leftStart = l;
    
                    if ( 0 != c )
                        right.buf[ r++ ] = c;
                }
                else
                    right.buf[ r++ ] = c;
            }
    
            CWordEntry * listR;

            if ( g_SortedWords->TryGetValue( &right, &listR ) ) 
            {
                if ( nullptr == sb )
                    sb.reset( new CStringBuilder() );

                CWordEntry * sL = listL;

                do
                {
                    assert( len == strlen( sL->word ) );

                    CWordEntry *sR = listR;

                    do
                    {
                        assert( rightlen == strlen( sR->word ) );

                        int c = strcmp( sL->word, sR->word );
                        sb->Reset();

                        if ( c < 0 )
                        {
                            sb->Append( sL->word, len );
                            sb->Append( ' ' );
                            sb->Append( sR->word, rightlen );
                        }
                        else
                        {
                            sb->Append( sR->word, rightlen );
                            sb->Append( ' ' );
                            sb->Append( sL->word, len );
                        }

                        int lenAnagram = 0;
                        char * pAnagram = sb->ToString( lenAnagram );
                        AddAnagram( set, pAnagram, lenAnagram );

                        sR = sR->next;
                    } while ( NULL != sR );

                    sL = sL->next;
                } while ( NULL != sL );
            }
    
            if ( ( anagramWords > 2 ) && ( right.len > 1 ) )
            {
                if ( nullptr == rightSet.get() )
                    rightSet.reset( new CAnagramSet( 1 ) );

                FindPhraseAnagrams( rightSet.get(), & right, anagramWords - 1 );

                if ( !rightSet->IsEmpty() )
                {
                    if ( nullptr == sb.get() )
                        sb.reset( new CStringBuilder() );

                    int cAnagrams = rightSet->Count();
                    unique_ptr<CAnString *> array (  new CAnString *[ cAnagrams ] );
                    rightSet->GetAnagrams( array.get(), cAnagrams );

                    for ( int a = 0; a < cAnagrams; a++ )
                    {
                        CAnString * anagram = array.get()[ a ];
                        int spaces = SpaceCount( anagram );

                        CWordEntry * sL = listL;
                        assert( len == strlen( sL->word ) );

                        do
                        {
                            sb->Reset();
                            int wordsRight = 1 + spaces;
                            int offset = 0;
    
                            do
                            {
                                int sp = FindSpace( anagram, offset );
                                if ( -1 == sp )
                                    sp = anagram->len;

                                int comp = Compare( sL->word, len, anagram->buf, offset, sp - offset );
    
                                if ( comp < 0 )
                                {
                                    sb->Append( anagram, 0, offset );
                                    sb->Append( sL->word, len );
                                    sb->Append( ' ' );
                                    sb->Append( anagram, offset, anagram->len - offset );
    
                                    break;
                                }
    
                                wordsRight--;
                                offset = sp + 1;
                            } while ( wordsRight > 0 );
    
                            if ( 0 == sb->Length() )
                            {
                                sb->Append( anagram );
                                sb->Append( ' ' );
                                sb->Append( sL->word, len );
                            }

                            int lenAnagram = 0;
                            char * pAnagram = sb->ToString( lenAnagram );
                            AddAnagram( set, pAnagram, lenAnagram );

                            sL = sL->next;
                        } while ( NULL != sL );
                    }
    
                    rightSet->Clear();
                }
            }
        }
    } while ( combo.Next() );
} //InsidePhraseAnagrams

void FindPhraseAnagrams( CAnagramSet * set, CAnString * input, int anagramWords )
{
    int limit = ( input->len / 2 ) + 1;

#ifdef USE_PPL

    int singleThreaded = g_OneThread ? INT_MAX : 6;

    if ( limit < singleThreaded )
    {
        for ( int len = 1; len < limit; len++ )
            InsidePhraseAnagrams( set, input, anagramWords, len );
    }
    else
    {
        parallel_for( 1, limit, [&] ( int len )
        {
            InsidePhraseAnagrams( set, input, anagramWords, len );
        } );
    }

#else // USE_PPL

    if ( g_OneThread )
    {
        for ( int len = 1; len < limit; len++ )
            InsidePhraseAnagrams( set, input, anagramWords, len );
    }
    else
    {
        #pragma omp parallel for schedule(nonmonotonic:dynamic)
        for ( int len = 1; len < limit; len++ )
            InsidePhraseAnagrams( set, input, anagramWords, len );
    }

#endif // USE_PPL

} //FindPhraseAnagrams

void Usage()
{
    printf( "Usage: an [-c] [-i] [-o] [-p] [-t] [-w:X] [word1] [word2] [...]\n" );
    printf( "  Anagram\n" );
    printf( "  arguments: -c    Show the total count of anagrams at the end\n" );
    //printf( "             -f    Use file words.txt (in the an.exe folder) instead of embedded dictionary\n" );
    printf( "             -i    Show Incremental progress as anagrams are found. They won't be sorted and -p won't work.\n" );
    printf( "             -o    One thread only. Default is as parallel as possible.\n" );
    printf( "             -p    Produce all permutations of words in anagrams.\n" );
    printf( "             -t    Show time spent running the app.\n" );
    printf( "             -w:X  X is the maximum number of words in the anagram. Default 3. 1 to 9 are valid.\n" );
    printf( "  examples:  an laying           Find anagrams of the word\n" );
    printf( "             an -w:1 laying      Find single-word anagrams\n" );
    printf( "             an -w:3 playing     Find one to three word anagrams\n" );
    printf( "             an -w:3 -p playing  Find one to three word anagrams and show all permutations\n" );
    printf( "             an phoebe bridgers  Find anagrams\n" );
    printf( "             an -i verylongstringwithmanywords -w:9  -- Show incremental progress because it'll take forever.\n" );
    printf( "  notes:     The combinatorics blow up beyond about 22 characters for 3-word anagrams\n" );
    printf( "             and even sooner for more-word anagrams. Use -i to see early results.\n" );
    printf( "             The file words.txt must be in the same directory as this .exe. Feel free to add/delete words.\n" );

    exit( 1 );
} //Usage

int compare( const void *a, const void *b )
{
    char ca = * (char *) a;
    char cb = * (char *) b;

    return ca - cb;
} //compare

int compareAG( const void *a, const void *b )
{
    CAnString * ca = * (CAnString **) a;
    CAnString * cb = * (CAnString **) b;

    return strcmp( ca->buf, cb->buf );
} //compareAG

// This just finds single words that contain all the same letters as the input

void FindAnagrams( CAnString * sortedInput, char * input, CAnagramSet * results )
{
    CWordEntry * list;

    if ( g_SortedWords->TryGetValue( sortedInput, &list ) )
    {
        CWordEntry * l = list;

        do
        {
            // don't add the input word

            if ( strcmp( input, l->word ) )
                AddAnagram( results, l->word, sortedInput->len );

            l = l->next;
        } while ( NULL != l );
    }
} //FindAnagrams

// PermuteWords find permutations of words that constitute anagrams; it's not used in generating
// the set of anagrams unless the user specifies -p

void PermuteWords( CStringBuilder & sb, char ** strings, bool * used, int count, int level, CAnagramSet & perms )
{
    if ( level == count )
    {
        int lenPerm = 0;
        char * pPerm = sb.ToString( lenPerm );
        perms.Add( pPerm, lenPerm );
        return;
    }

    int len = sb.Length();

    for ( int i = 0; i < count; i++ )
    {
        if ( used[ i ] )
            continue;

        used[ i ] = true;

        if ( 0 != len )
            sb.Append( ' ' );

        sb.Append( strings[ i ] );

        PermuteWords( sb, strings, used, count, level + 1, perms );

        sb.SetLength( len );
        used[ i ] = false;
    }
} //PermuteWords

void FindWordsInSentencePermutations( CAnString * anagram, CAnagramSet & permSet )
{
    int cWords = 1 + SpaceCount( anagram );

    unique_ptr<char *> strings( new char * [ cWords ] );
    unique_ptr<bool> used( new bool[ cWords ] );

    for ( int i = 0; i < cWords; i++ )
    {
        strings.get()[ i ] = NULL;
        used.get()[ i ] = false;
    }

    // Copy the string and insert null-termination where each space was

    std::string theCopy( anagram->buf );
    char * pTheCopy = (char *) theCopy.c_str();

    strings.get()[ 0 ] = pTheCopy;
    int word = 1;
    for ( char *p = pTheCopy; *p; p++ )
    {
        if ( ' ' == *p )
        {
            *p = 0;
            strings.get()[ word++ ] = p + 1;
        }
    }

    CStringBuilder sb;
    PermuteWords( sb, strings.get(), used.get(), cWords, 0, permSet );

    for ( int i = 0; i < cWords; i++ )
        strings.get()[ i ] = NULL;
} //FindWordsInSentencePermutations

void PrintNumberWithCommas( long long n )
{
    if ( n < 0 )
    {
        printf( "-" );
        PrintNumberWithCommas( -n );
        return;
    }
   
    if ( n < 1000 )
    {
        printf( "%lld", n );
        return;
    }

    PrintNumberWithCommas( n / 1000 );
    printf( ",%03lld", n % 1000 );
} //PrintNumberWithCommas

long portable_filelen( FILE * fp )
{
    long current = ftell( fp );
    fseek( fp, 0, SEEK_END );
    long len = ftell( fp );
    fseek( fp, current, SEEK_SET );
    return len;
} //portable_filelen

bool isvalidchar( char c )
{
    return ( ( c <= 'z' ) && ( c >= 'a' ) );
} //isvalidchar

bool ValidateCharsSorted( char * p, int len )
{
    if ( len < 2 )
        return true;

    for ( int x = 0; x < len - 1; x++ )
        if ( p[x] > p[ x + 1 ] )
            return false;

    return true;
} //ValidateCharsSorted

// Insertion sort is faster than qsort for small arrays

void SortChars( char * p, int len )
{
    for ( int i = 1; i < len; i++ )
    {
        int j = i;

        do 
        {
            if ( p[ j - 1 ] < p[ j ] )
                break;

            char t = p[ j ];
            p[ j ] = p[ j - 1 ];
            p[ j - 1 ] = t;
            j--;
        } while ( j > 0 );
    }

    assert( ValidateCharsSorted( p, len ) );
} //SortChars

extern "C" int main( int argc, char * argv[] )
{
    high_resolution_clock::time_point tStart = high_resolution_clock::now();

    unique_ptr<char> acDictionary( new char[ PATH_MAX ] );
    const char * pResult = 0; //realpath( argv[ 0 ], acDictionary.get() );

    if ( NULL != pResult )
    {
        char * pLastSlash = strrchr( acDictionary.get(), '\\' );
        if ( NULL == pLastSlash )
            pLastSlash = strrchr( acDictionary.get(), '/' );

        if ( NULL != pLastSlash )
            strcpy( pLastSlash + 1, "words.txt" );
    }
    else
    {
        strcpy( acDictionary.get(), "words.txt" );
    }

    char input[ MaxAnStringLen + 1 ] = { 0 };
    bool showCount = false;
    bool showTime = false;
    bool allPermutations = false;
    g_IncrementalProgress = false;
    int maxAnagramWords = 3;


    for ( int i = 1; i < argc; i++ )
    {
        char * parg = argv[ i ];
        int arglen = strlen( parg );
        char c0 = parg[ 0 ];
        char c1 = tolower( parg[ 1 ] );

        if ( '-' == c0 || '/' == c0 )
        {
            if ( 'w' == c1 )
            {
                if ( ':' != parg[2] || arglen < 4 )
                    Usage();

                maxAnagramWords = atoi( parg + 3 );
                if ( maxAnagramWords < 1 || maxAnagramWords > 9 )
                    Usage();
            }
            else if ( 'c' == c1 )
                showCount = true;
            else if ( 'i' == c1 )
                g_IncrementalProgress = true;
            else if ( 'o' == c1 )
                g_OneThread = true;
            else if ( 'p' == c1 )
                allPermutations = true;
            else if ( 't' == c1 )
                showTime = true;
            else
                Usage();
        }
        else
        {
            int l = strlen( argv[ i ] );
            int inputlen = strlen( input );

            if ( ( l + inputlen ) > _countof( input ) )
            {
                printf( "input string is too long; only %d characters supported\n", MaxAnStringLen );
                Usage();
            }

            strcpy( input + inputlen, argv[ i ] );
        }
    }

    if ( 0 == input[ 0 ] )
    {
        printf( "no input string specified\n" );
        Usage();
    }

    if ( strlen( input ) + maxAnagramWords > MaxAnStringLen )
    {
        printf( "input string is too long\n" );
        Usage();
    }

    try
    {
        strlwr( input );
        int inputLen = strlen( input );
        int uniqueWords = 0;

        g_SortedWords = new CRealDictionary();

        const int maxDictionaryLine = MaxAnStringLen;
        char line[ maxDictionaryLine ];
        int collisions = 0;

        CFile fileDictionary( fopen( acDictionary.get(), "rb" ) );
        if ( NULL == fileDictionary.fp )
        {
            printf( "can't open file %s\n", acDictionary.get() );
            return 0;
        }

        // open the dictionary, read it all into RAM, lowercase it (because someone might add a word), and parse it.

        long filelen = portable_filelen( fileDictionary.fp );
        unique_ptr<char> dictionary( new char [ filelen + 1 ] );
        long lread = fread( dictionary.get(), 1, filelen, fileDictionary.fp );
        if ( lread <= 0 )
        {
            printf( "unable to read dictionary file\n" );
            return 0;
        }

        fileDictionary.Close();
        dictionary.get()[ filelen ] = 0;
        strlwr( dictionary.get() );

        char * pbuf = dictionary.get();
        char * pbeyond = pbuf + filelen;
        const int MaxDictionaryLineLen = _countof( line ) - 1;

        while ( pbuf < pbeyond )
        {
            int len = 0;
            while ( ( pbuf < pbeyond ) && ( isvalidchar( *pbuf ) ) && ( len < MaxDictionaryLineLen ) )
                line[ len++ ] = *pbuf++;

            while ( ( pbuf < pbeyond ) && !isvalidchar( *pbuf ) )
                pbuf++;

            if ( 0 != len )
            {
                line[ len ] = 0;

                if ( ( ( maxAnagramWords > 1 ) && ( len <= inputLen ) ) ||
                     ( ( maxAnagramWords == 1 ) && ( len == inputLen ) ) )
                {
                    if ( len > g_LongestWord )
                        g_LongestWord = len;

                    uniqueWords++;                    
                    CAnString wordSorted( line, len );

                    // SortChars runs in about 16ms and qsort in 19ms
                    SortChars( wordSorted.buf, len );
                    // qsort( wordSorted.buf, len, 1, compare );

                    CWordEntry * newEntry = new CWordEntry( line, len );
                    CWordEntry * p = NULL;
                    int entry = g_SortedWords->GetEntry( &wordSorted );

                    if ( g_SortedWords->TryGetValue( & wordSorted, & p, entry ) )
                    {
                        while ( NULL != p->next )
                            p = p->next;

                        p->next = newEntry;
                        collisions++;
                    }
                    else
                    {
                        g_SortedWords->Add( & wordSorted, newEntry, entry );
                    }
                }
            }
        }

        dictionary.reset();

        high_resolution_clock::time_point tAfterReadWords = high_resolution_clock::now();

        //printf( "uniquewords: %d, collisions: %d\n", uniqueWords, collisions );

        g_Results = new CAnagramSet();

        CAnString startingInput( input );
        SortChars( startingInput.buf, inputLen );
        //qsort( startingInput.buf, inputLen, 1, compare );

        // Find single-word anagrams

        FindAnagrams( &startingInput, input, g_Results );

        // Find multi-word anagrams

        FindPhraseAnagrams( g_Results, & startingInput, maxAnagramWords );

        int cAnagrams = g_Results->Count();

        high_resolution_clock::time_point tAfterGenerate = high_resolution_clock::now();
        if ( !g_IncrementalProgress )
        {
            unique_ptr<CAnString *> array ( new CAnString * [ cAnagrams ] );
            g_Results->GetAnagrams( array.get(), cAnagrams );
            qsort( array.get(), cAnagrams, sizeof( void * ), compareAG );

            CStringBuilder sb( 4096 );
            CAnagramSet permsSet( 1 );

            for ( int a = 0; a < cAnagrams; a++ )
            {
                if ( allPermutations )
                {
                    permsSet.Clear();
                    FindWordsInSentencePermutations( array.get()[ a ], permsSet );
                    int permsCount = permsSet.Count();
                    unique_ptr<CAnString *> arrayPerms ( new CAnString *[ permsCount ] );
                    permsSet.GetAnagrams( arrayPerms.get(), permsCount );
                    bool first = true;

                    for ( int i = 0; i < permsSet.Count(); i++ )
                    {
                        if ( first )
                            first = false;
                        else
                            sb.Append( ' ', 2 );

                        sb.Append( arrayPerms.get()[ i ]->buf );
                        sb.Append( '\n' );
                    }
                }
                else
                {
                    sb.Append( array.get()[ a ]->buf );
                    sb.Append( '\n' );
                }
            }

            int len = 0;
            printf( "%s", sb.ToString( len ) );
        }

        if ( showCount )
        {
            printf( "  found " );
            PrintNumberWithCommas( cAnagrams );
            printf( " anagram%s for %s\n", ( 1 == cAnagrams ) ? "" : "s", input );
        }

        if ( showTime )
        {
            high_resolution_clock::time_point tAfterRender = high_resolution_clock::now();

            long long totalTime = duration_cast<std::chrono::milliseconds>( tAfterRender - tStart ).count();
            long long dictionaryTime = duration_cast<std::chrono::milliseconds>( tAfterReadWords - tStart ).count();
            long long generateTime = duration_cast<std::chrono::milliseconds>( tAfterGenerate - tAfterReadWords ).count();
            long long renderTime = duration_cast<std::chrono::milliseconds>( tAfterRender - tAfterGenerate ).count();

            printf( "  " ); PrintNumberWithCommas( totalTime); printf( " milliseconds total" );
            printf( " including "); PrintNumberWithCommas( dictionaryTime ); printf( " loading+creating dictionary," );
            printf( " " ); PrintNumberWithCommas( generateTime ); printf( " generating," );
            printf( " " ); PrintNumberWithCommas( renderTime ); printf( " printing\n" );
        }

#if false
        int longestChain = 0;
        int unused = 0;
        int moreThan5 = 0;
        int singles = 0;
        g_SortedWords->Stats( longestChain, unused, moreThan5, collisions, singles );
        printf( "longestchain %d, unused %d, moreThan5 %d, collisions %d, singles %d\n", longestChain, unused, moreThan5, collisions, singles );
#endif

    }
    catch( ... )
    {
        printf( "caught an exception in an.exe, exiting\n" );
    }

    return 0;
} //main



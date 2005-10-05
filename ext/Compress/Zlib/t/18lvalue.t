
use lib 't';
use strict;
use warnings;
use bytes;

use Test::More ;
use ZlibTestUtils;

BEGIN 
{ 
    plan(skip_all => "lvalue sub tests need Perl ??")
        if $] < 5.006 ; 

    # use Test::NoWarnings, if available
    my $extra = 0 ;
    $extra = 1
        if eval { require Test::NoWarnings ;  import Test::NoWarnings; 1 };

    plan tests => 10 + $extra ;

    use_ok('Compress::Zlib', 2) ;
}
 


my $hello = <<EOM ;
hello world
this is a test
EOM

my $len   = length $hello ;

# Check zlib_version and ZLIB_VERSION are the same.
is Compress::Zlib::zlib_version, ZLIB_VERSION, 
    "ZLIB_VERSION matches Compress::Zlib::zlib_version" ;


{
    title 'deflate/inflate with lvalue sub';

    my $hello = "I am a HAL 9000 computer" ;
    my $data = $hello ;

    my($X, $Z);
    sub getData : lvalue { $data }
    sub getX    : lvalue { $X }
    sub getZ    : lvalue { $Z }

    ok my $x = new Compress::Zlib::Deflate ( -AppendOutput => 1 );

    cmp_ok $x->deflate(getData, getX), '==',  Z_OK ;

    cmp_ok $x->flush(getX), '==', Z_OK ;
     
    my $append = "Appended" ;
    $X .= $append ;
     
    ok my $k = new Compress::Zlib::Inflate ( -AppendOutput => 1 ) ;
     
    cmp_ok $k->inflate(getX, getZ), '==', Z_STREAM_END ; ;
     
    ok $hello eq $Z ;
    is $X, $append;
    
}



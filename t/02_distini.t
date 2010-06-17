use strict;
use warnings;
use Test::More 'no_plan';
use File::Temp qw[tempdir];
use File::Spec;

use_ok('Dist::Zooky::DistIni');

{
  my $dir = tempdir( CLEANUP => 1, DIR => '.' );
  
  my $meta = {
    type => 'MakeMaker',
    name => 'Foo-Bar',
    version => '0.02',
    author => [ 'Duck Dodgers', 'Ivor Module', ],
    license => [ 'Perl_5' ],
  };

  my $distini = Dist::Zooky::DistIni->new( metadata => $meta );
  isa_ok( $distini, 'Dist::Zooky::DistIni' );
  
  my $file = File::Spec->catfile( $dir, 'dist.ini' );

  $distini->write( $file );

  ok( -e $file, 'The file exists' );
}

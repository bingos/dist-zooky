package Dist::Zooky::Core::ModBuild;

# ABSTRACT: gather meta data for Module::Build dists

use strict;
use warnings;
use Moose;
use IPC::Cmd qw[run can_run];

with 'Dist::Zooky::Role::Core';
with 'Dist::Zooky::Role::Meta';

sub _build_metadata {
  my $self = shift;

  my $struct;

  {
    local $ENV{PERL_MM_USE_DEFAULT} = 1;

    my $cmd = [ $^X, 'Build.PL' ];
    run ( command => $cmd, verbose => 0 );
  }

  if ( -e 'MYMETA.yml' ) {

    $struct = $self->meta_from_file( 'MYMETA.yml' );
    
  }
  else {

    die "Couldn\'t find a 'MYMETA.yml' file, giving up\n";

  }

  {
    my $cmd = [ $^X, 'Build', 'distclean' ];
    run( command => $cmd, verbose => 0 );
  }

  return $struct;
}

__PACKAGE__->meta->make_immutable;
no Moose;

qq[MakeMaker];


package Dist::Zooky::Core::ModBuild;

use strict;
use warnings;
use Moose;
use IPC::Cmd qw[run can_run];

with 'Dist::Zooky::Role::Core';
with 'Dist::Zooky::Role::Meta';

sub examine {
  my $self = shift;

  {
    local $ENV{PERL_MM_USE_DEFAULT} = 1;

    my $cmd = [ $^X, 'Build.PL' ];
    run ( command => $cmd, verbose => 0 );
  }

  if ( -e 'MYMETA.yml' ) {

    my $struct = $self->meta_from_file( 'MYMETA.yml' );
    $self->_set_name( $struct->{name} );
    $self->_set_author( $struct->{author} );
    $self->_set_license( $struct->{license} );
    $self->_set_version( $struct->{version} );
    $self->_set_prereqs( $struct->{prereqs} );
    
  }
  else {

    die "Couldn\'t find a 'MYMETA.yml' file, giving up\n";

  }

  {
    my $cmd = [ $^X, 'Build', 'distclean' ];
    run( command => $cmd, verbose => 0 );
  }

  return;
}

sub return_meta {
  my $self = shift;
  return { map { ( $_, $self->$_ ) } qw(author name version license Prereq) };
}

__PACKAGE__->meta->make_immutable;
no Moose;

qq[MakeMaker];


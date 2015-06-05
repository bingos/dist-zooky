package Dist::Zooky::Core::FromMETA;

# ABSTRACT: gather meta data from META files

use strict;
use warnings;
use Moose;

with 'Dist::Zooky::Role::Core';
with 'Dist::Zooky::Role::Meta';

sub _build_metadata {
  my $self = shift;

  my $struct;

  if ( -e 'META.json' ) {

    $struct = $self->meta_from_file( 'META.json' );

  }
  elsif ( -e 'META.yml' ) {

    $struct = $self->meta_from_file( 'META.yml' );

  }
  else {

    die "There is no 'META.json' nor 'META.yml' found\n"

  }

  return { %$struct };
}

__PACKAGE__->meta->make_immutable;
no Moose;

qq[What does a meta make if a meta makes];


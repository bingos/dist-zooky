package Dist::Zooky::License;

# ABSTRACT: license objects for Dist::Zooky

use strict;
use warnings;
use Module::Pluggable search_path => 'Software::License', except => qr/(Custom)$/;
use Class::Load ();
use Moose;

has 'metaname' => (
  is => 'ro',
  isa => 'Str',
  required => 1,
);

has 'license' => (
  is => 'ro',
  isa => 'ArrayRef[Software::License]',
  lazy => 1,
  builder => '_build_license',
  init_arg => undef,
);

sub _build_license {
  my $self = shift;
  my @licenses;
  foreach my $plugin ( $self->plugins ) {
    Class::Load::load_class( $plugin );
    my $license;
    eval {
      $license = $plugin->new({ holder => 'noddy' }); # need to set holder
    };
    next if $@;
    push @licenses, $license
      if $license->meta2_name eq $self->metaname
      or $license->meta_name  eq $self->metaname;
  }
  return \@licenses;
}

__PACKAGE__->meta->make_immutable;
no Moose;

qq[Licenses];

=pod
=cut

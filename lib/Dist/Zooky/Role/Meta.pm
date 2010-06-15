package Dist::Zooky::Role::Meta;

use strict;
use warnings;
use Moose::Role;
use CPAN::Meta;

sub prereqs_from_meta_file {
  my $self = shift;
  my $file = shift || return;

  if  ( -e $file ) {
    my $meta = eval { CPAN::Meta->load_file( $file ); };
    return { } unless $meta;
    my $prereqs = $meta->effective_prereqs;
    return $prereqs->as_string_hash;
  }
  return { }
}

no Moose::Role;

qq[Show me the META!]

__END__

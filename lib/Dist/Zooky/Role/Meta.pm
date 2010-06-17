package Dist::Zooky::Role::Meta;

# ABSTRACT: Dist::Zooky role for meta parsing

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

sub meta_from_file {
  my $self = shift;
  my $file = shift || return;

  if  ( -e $file ) {
    my $meta = eval { CPAN::Meta->load_file( $file ); };
    return { } unless $meta;
    return $meta->as_struct;
  }
  return { }
}

no Moose::Role;

qq[Show me the META!];

=pod

=head1 METHODS

=over

=item C<prereqs_from_meta_file>

=item C<meta_from_file>

=back

=cut

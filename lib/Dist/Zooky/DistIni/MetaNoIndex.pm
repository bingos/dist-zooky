package Dist::Zooky::DistIni::MetaNoIndex;

# ABSTRACT: Dist::Zooky DistIni plugin for MetaNoIndex

use strict;
use warnings;
use Module::Load::Conditional qw[check_install];
use Moose;

with 'Dist::Zooky::Role::DistIni';

sub content {
  my $self = shift;
  return unless
    check_install( module => 'Dist::Zilla::Plugin::MetaNoIndex' );
  if ( my $noindex = $self->metadata->{no_index} ) {
    my $content = "[MetaNoIndex]\n";
    foreach my $type ( keys %{ $noindex } ) {
      $content .= join "\n", map { "$type = " . $_ } @{ $noindex->{$type} };
    }
    return $content;
  }
  return;
}

__PACKAGE__->meta->make_immutable;
no Moose;

qq[No Index, No Problem];

=pod

=head1 METHODS

=over

=item C<content>

Returns C<content> for adding to C<dist.ini>.

=back

=cut

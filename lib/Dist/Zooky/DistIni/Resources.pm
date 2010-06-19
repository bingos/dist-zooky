package Dist::Zooky::DistIni::Resources;

# ABSTRACT: Dist::Zooky DistIni plugin to write MetaResources

use strict;
use warnings;
use Moose;

with 'Dist::Zooky::Role::DistIni';

sub content {
  my $self = shift;
  return unless my $resources = $self->metadata->{resources};
  my $content = "[MetaResources]\n";
  foreach my $type ( keys %{ $resources } ) {
    next if $type eq 'license'; 
    my $ref = ref $resources->{$type};
    if ( $ref eq 'HASH' ) {
      foreach my $item ( keys %{ $resources->{$type} } ) {
        $content .= "$type.$item = " . $resources->{$type}->{$item} . "\n";
      }
    }
    elsif ( $ref eq 'ARRAY' ) {
      $content .= "$type = $_\n" for @{ $resources->{$type} };
    }
    else {
      $content .= "$type = " . $resources->{$type} . "\n";
    }
  }
  return $content;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=pod

=head1 METHODS

=over

=item C<content>

Returns C<content> for adding to C<dist.ini>.

=back

=cut

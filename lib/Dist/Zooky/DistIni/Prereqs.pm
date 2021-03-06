package Dist::Zooky::DistIni::Prereqs;

# ABSTRACT: Dist::Zooky DistIni plugin to handle prereqs

use strict;
use warnings;
use Moose;

with 'Dist::Zooky::Role::DistIni';

my $template = q|
{{
   if ( keys %configure ) {
      $OUT .= "[Prereqs / ConfigureRequires]\n";
      $OUT .= join(' = ', $_, $configure{$_}) . "\n" for sort keys %configure;
   }
   else {
      $OUT .= ';[Prereqs / ConfigureRequires]';
   }
}}
{{
   if ( keys %build ) {
      $OUT .= "[Prereqs / BuildRequires]\n";
      $OUT .= join(' = ', $_, $build{$_}) . "\n" for sort keys %build;
   }
   else {
      $OUT .= ';[Prereqs / BuildRequires]';
   }
}}
{{
   if ( keys %runtime ) {
      $OUT .= "[Prereqs]\n";
      $OUT .= join(' = ', $_, $runtime{$_}) . "\n" for sort keys %runtime;
   }
   else {
      $OUT .= ';[Prereqs]';
   }
}}
|;

sub content {
  my $self = shift;
  my %stash;
  $stash{$_} = $self->metadata->{prereqs}->{$_}->{requires}
    for qw(configure build runtime);
  my $content = $self->fill_in_string(
    $template,
    \%stash,
  );
  return $content;
}

__PACKAGE__->meta->make_immutable;
no Moose;

qq[WHAT DO YOU REQUIRE?];

=pod

=head1 METHODS

=over

=item C<content>

Returns C<content> for adding to C<dist.ini>.

=back

=cut

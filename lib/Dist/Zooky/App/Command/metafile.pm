package Dist::Zooky::App::Command::metafile;

# ABSTRACT: The other command that Dist::Zooky uses

use strict;
use warnings;
use Dist::Zooky::App -command;

sub abstract { 'Dist::Zooky!' }

sub execute {
  my ($self, $opt, $args) = @_;
  require Dist::Zooky;
  my $zooky = Dist::Zooky->new( metafile => 1 );
  $zooky->examine;
  return;
}

qq[Lighten up and play];

=pod

=head1 DESCRIPTION

Dist::Zooky anther command, this is it. And it is not the default so
you should never need to specify it.

=head1 METHOD

=over

=item C<execute>

This runs L<Dist::Zooky> for you.

=back

=cut

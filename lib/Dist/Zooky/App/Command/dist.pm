package Dist::Zooky::App::Command::dist;

# ABSTRACT: The one command that Dist::Zooky uses

use strict;
use warnings;
use Dist::Zooky::App -command;

sub abstract { 'Dist::Zooky!' }

sub opt_spec {
  return (
      [ 'make=s', 'Specify make utility to use', ],
  );
}

sub execute {
  my ($self, $opt, $args) = @_;
  require Dist::Zooky;
  my $zooky = Dist::Zooky->new( ( defined $opt->{make} ? ( make => $opt->{make} ) : () ) );
  $zooky->examine;
  return;
}

qq[Lighten up and play];

=pod

=head1 DESCRIPTION

Dist::Zooky has but one command, this is it. And it is the default so
you should never need to specify it.

=head1 METHOD

=over

=item C<execute>

This runs L<Dist::Zooky> for you.

=back

=cut

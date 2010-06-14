package Dist::Zooky::App::Command::dist;

use strict;
use warnings;
use Dist::Zooky::App -command;

sub abstract { 'Dist::Zooky!' }

sub execute {
  my ($self, $opt, $args) = @_;
  require Dist::Zooky;
  my $zooky = Dist::Zooky->new();
  $zooky->examine;
  return;
}

qq[Lighten up and play]

__END__

package Dist::Zooky;

# ABSTRACT: converts a distribution to Dist::Zilla

use strict;
use warnings;
use Class::MOP;
use Moose;
use MooseX::Types::Perl qw(DistName LaxVersionStr);
use Dist::Zooky::License;
use Dist::Zooky::DistIni;
use Module::Pluggable search_path => 'Dist::Zooky::Core';

has name => (
  is   => 'ro',
  isa  => DistName,
  writer => 'set_name',
);

sub examine {
  my $self = shift;

  die "Hey, you already have a 'dist.ini' giving up\n" if -e 'dist.ini';

  my $type;
  if ( -e 'Build.PL' ) {
    $type = 'ModBuild';
  }
  elsif ( -e 'Makefile.PL' ) {
    {
      open my $MAKEFILEPL, '<', 'Makefile.PL' or die "$!\n";
      local $/;
      my $mfpl = <$MAKEFILEPL>;
      if ( $mfpl =~ /inc::Makefile::Install/s ) {
        #$type = 'ModInstall';
        $type = 'MakeMaker';
      }
      else {
         $type = 'MakeMaker';
      }
      close $MAKEFILEPL;
    }
  }

  my $core;

  foreach my $plugin ( $self->plugins ) {
    if ( $plugin =~ /$type$/ ) {
      Class::MOP::load_class( $plugin );
      $core = $plugin->new();
    }
  }

  die "No core plugin found for '$type'\n" unless $core;

  $core->examine;

  my $meta = $core->return_meta();

  if ( defined $meta->{license} ) {
    my @licenses;
    foreach my $license ( @{ $meta->{license} } ) {
      my $aref = Dist::Zooky::License->new( metaname => $license )->license;
      push @licenses, map { ( split /::/, ref $_ )[-1] } @$aref;
    }
    $meta->{license} = \@licenses;
  }

  $meta->{type} = $type;

  my $ini = Dist::Zooky::DistIni->new( metadata => $meta );
  $ini->write;
}

__PACKAGE__->meta->make_immutable;
no Moose;

qq[And Dist::Zooky too!];

=pod

=head1 NAME

Dist::Zooky - converts a distribution to Dist::Zilla

=head1 SYNOPSIS

  use Dist::Zooky;

  my $dzooky = Dist::Zooky->new();

  $dzooky->examine;

=head1 DESCRIPTION

=cut

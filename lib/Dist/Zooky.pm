package Dist::Zooky;

# ABSTRACT: converts a distribution to Dist::Zilla

use strict;
use warnings;
use Class::MOP;
use Moose;
use MooseX::Types::Perl qw(DistName LaxVersionStr);
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
        $type = 'ModInstall';
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

  {
    open my $distini, '>', 'dist.ini' or die "Could not open 'dist.ini': $!\n";
    print $distini join(' = ', $_, $meta->{$_}), "\n" for grep { defined $meta->{$_} } qw(name author version license);
    ( my $holder = $meta->{author} ) =~ s/\s*\<.+?\>\s*//g;
    print $distini "copyright_holder = $holder\n";
    print $distini "\n";
    print $distini "[$_]\n" for 
      qw(GatherDir PruneCruft ManifestSkip MetaYAML MetaJSON License);
    print $distini "[Readme]\n" unless -e 'README';
    print $distini "[ExecDir]\n";
    print $distini "dir = scripts\n" if -e 'scripts';
    print $distini "[$_]\n" for
      qw(ExtraTests ShareDir);
    print $distini +( $type eq 'ModBuild' ? '[ModuleBuild]' : '[MakeMaker]' ), "\n";
    print $distini "[$_]\n" for qw(Manifest TestRelease ConfirmRelease UploadToCPAN);
    print $distini "\n";
    print $distini "[Prereq]\n";
    print $distini join(' = ', $_, $meta->{Prereq}->{$_}), "\n" for sort keys %{ $meta->{Prereq} };
    close $distini;
  }
}

__PACKAGE__->meta->make_immutable;
no Moose;

qq[And Dist::Zooky too!]

__END__

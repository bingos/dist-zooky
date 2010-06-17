package Dist::Zooky::Core::MakeMaker;

use strict;
use warnings;
use Moose;
use IPC::Cmd qw[run can_run];

with 'Dist::Zooky::Role::Core';
with 'Dist::Zooky::Role::Meta';

has 'make' => (
  is => 'ro',
  isa => 'Str',
  default => sub { can_run('make') },
);

sub examine {
  my $self = shift;

  {
    local $ENV{PERL_MM_USE_DEFAULT} = 1;
    local $ENV{PERL_EXTUTILS_AUTOINSTALL} = '--defaultdeps';

    my $cmd = [ $^X, 'Makefile.PL' ];
    run ( command => $cmd, verbose => 0 );
  }

  if ( -e 'MYMETA.yml' ) {

    my $struct = $self->meta_from_file( 'MYMETA.yml' );
    $self->_set_name( $struct->{name} );
    $self->_set_author( $struct->{author} );
    $self->_set_license( $struct->{license} );
    $self->_set_version( $struct->{version} );
    $self->_set_prereqs( $struct->{prereqs} );
    
  }
  else {

    $self->_parse_makefile;

  }

  {
    my $cmd = [ $self->make, 'distclean' ];
    run( command => $cmd, verbose => 0 );
  }

  return;
}

sub _parse_makefile {
  my $self = shift;

  die "No 'Makefile' found\n" unless -e 'Makefile';

  my $distname;
  my $author;
  my $version;
  my $license;
  my %p;
  my %c;
  my %b;
  {
    open my $MAKEFILE, '<', 'Makefile' or die "Could not open 'Makefile': $!\n";

    while( local $_ = <$MAKEFILE> ) {
      chomp;
      if ( m|^[\#]\s+AUTHOR\s+=>\s+q\[(.*?)\]$| ) {
        $author = $1;
        next;
      }
      if ( m|^[\#]\s+LICENSE\s+=>\s+q\[(.*?)\]$| ) {
        $license = $1;
        next;
      }
      if ( m|^DISTNAME\s+=\s+(.*?)$| ) {
        $distname = $1;
        next;
      }
      if ( m|^VERSION\s+=\s+(.*?)$| ) {
        $version = $1;
        next;
      }

      if ( my ($prereqs) = m|^[\#]\s+PREREQ_PM\s+=>\s+(.+)| ) {
        while( $prereqs =~ m/(?:\s)([\w\:]+)=>(?:q\[(.*?)\],?|undef)/g ) {
            if( defined $p{$1} ) {
                my $ver = $self->_version_to_number(version => $2);
                $p{$1} = $ver
                  if $self->_vcmp( $ver, $p{$1} ) > 0;
            }
            else {
                $p{$1} = $self->_version_to_number(version => $2);                  
            }
        }
        next;
      }

      if ( my ($buildreqs) = m|^[\#]\s+BUILD_REQUIRES\s+=>\s+(.+)| ) {
        while( $buildreqs =~ m/(?:\s)([\w\:]+)=>(?:q\[(.*?)\],?|undef)/g ) {
            if( defined $b{$1} ) {
                my $ver = $self->_version_to_number(version => $2);
                $b{$1} = $ver
                  if $self->_vcmp( $ver, $b{$1} ) > 0;
            }
            else {
                $b{$1} = $self->_version_to_number(version => $2);                  
            }
        }
        next;
      }

      if ( my ($confreqs) = m|^[\#]\s+CONFIGURE_REQUIRES\s+=>\s+(.+)| ) {
        while( $confreqs =~ m/(?:\s)([\w\:]+)=>(?:q\[(.*?)\],?|undef)/g ) {
            if( defined $c{$1} ) {
                my $ver = $self->_version_to_number(version => $2);
                $c{$1} = $ver
                  if $self->_vcmp( $ver, $c{$1} ) > 0;
            }
            else {
                $c{$1} = $self->_version_to_number(version => $2);                  
            }
        }
        next;
      }

    }

    close $MAKEFILE;
  }
  $self->_set_name( $distname );
  $self->_set_author( $author );
  $self->_set_license( $license );
  $self->_set_version( $version );
  my $prereqs = { };
  $prereqs->{runtime}   = { requires => \%p } if scalar keys %p;
  $prereqs->{configure} = { requires => \%c } if scalar keys %c;
  $prereqs->{build}     = { requires => \%c } if scalar keys %c;
  $self->_set_prereqs( $prereqs );
  return;
}

sub return_meta {
  my $self = shift;
  return { map { ( $_, $self->$_ ) } qw(author name version license Prereq) };
}

__PACKAGE__->meta->make_immutable;
no Moose;

qq[MakeMaker];


package Dist::Zooky::Core::MakeMaker;

use strict;
use warnings;
use Software::LicenseUtils;
use Params::Check               qw[check];
use Moose;
use IPC::Cmd qw[run can_run];

with 'Dist::Zooky::Role::Core';

has 'name' => (
  is => 'ro',
  isa => 'Str',
  init_arg => undef,
  writer => '_set_name',
);

has 'version' => (
  is => 'ro',
  isa => 'Str',
  init_arg => undef,
  writer => '_set_version',
);

has 'author' => (
  is => 'ro',
  isa => 'Str',
  init_arg => undef,
  writer => '_set_author',
);

has 'license' => (
  is => 'ro',
  isa => 'Str',
  init_arg => undef,
  writer => '_set_license',
);

has 'Prereq' => (
  is => 'ro',
  isa => 'HashRef',
  init_arg => undef,
  writer => '_set_prereqs',
);

sub examine {
  my $self = shift;
  my $make = can_run('make');
  {
    my $cmd = [ $^X, 'Makefile.PL' ];
    run ( command => $cmd, verbose => 0 );
  }
  die "No 'Makefile' found\n" unless -e 'Makefile';

  my $distname;
  my $author;
  my $version;
  my $license;
  my %p;
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

      if ( my ($found) = m|^[\#]\s+PREREQ_PM\s+=>\s+(.+)| ) {
        while( $found =~ m/(?:\s)([\w\:]+)=>(?:q\[(.*?)\],?|undef)/g ) {
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
    }

    close $MAKEFILE;
  }
  ($license) = map { ( split /::/ )[-1] } Software::LicenseUtils->guess_license_from_meta("license: $license");
  $self->_set_name( $distname );
  $self->_set_author( $author );
  $self->_set_license( $license );
  $self->_set_version( $version );
  $self->_set_prereqs( \%p );
  {
    my $cmd = [ $make, 'distclean' ];
    run( command => $cmd, verbose => 0 );
  }
  return;
}

sub return_meta {
  my $self = shift;
  return { map { ( $_, $self->$_ ) } qw(author name version license Prereq) };
}

sub _version_to_number {
    my $self = shift;
    my %hash = @_;

    my $version;
    my $tmpl = {
        version => { default => '0.0', store => \$version },
    };

    check( $tmpl, \%hash ) or return;

    return $version if $version =~ /^\.?\d/;
    return '0.0';
}

sub _vcmp {
    my $self = shift;
    my ($x, $y) = @_;
    
    s/_//g foreach $x, $y;

    return $x <=> $y;
}

__PACKAGE__->meta->make_immutable;
no Moose;

qq[MakeMaker]

__END__

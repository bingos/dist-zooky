package Dist::Zooky::Role::Core;

# ABSTRACT: role for core plugins

use strict;
use warnings;
use Params::Check qw[check];
use Moose::Role;

use MooseX::Types::Moose qw[Str ArrayRef];
use Moose::Util::TypeConstraints;
subtype( 'ArrayRefStr', as ArrayRef[Str] );
coerce( 'ArrayRefStr', from 'Str', via { [ $_ ] } );

requires 'examine';
requires 'return_meta';

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
  isa => 'ArrayRefStr',
  init_arg => undef,
  writer => '_set_author',
  coerce => 1,
);

has 'license' => (
  is => 'ro',
  isa => 'ArrayRefStr',
  init_arg => undef,
  writer => '_set_license',
  coerce => 1,
);

has 'Prereq' => (
  is => 'ro',
  isa => 'HashRef',
  init_arg => undef,
  writer => '_set_prereqs',
);

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

no Moose::Role;

qq[And Dist::Zooky too!];


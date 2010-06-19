package Dist::Zooky::Role::DistIni;

# ABSTRACT: role for DistIni plugins

use strict;
use warnings;
use Moose::Role;

with 'Dist::Zilla::Role::TextTemplate';

has 'type' => (
  is => 'ro',
  isa => 'Str',
  required => 1,
);

has 'metadata' => (
  is => 'ro',
  isa => 'HashRef',
  required => 1,
);

requires 'content';

no Moose::Role;

qq[Gotta role];


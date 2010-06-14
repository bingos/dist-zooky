package Dist::Zooky::Role::Core;

# ABSTRACT: role for core plugins

use strict;
use warnings;
use Moose::Role;

requires 'examine';
requires 'return_meta';

no Moose::Role;

qq[And Dist::Zooky too!]

__END__

package Dist::Zooky::Role::Core;

# ABSTRACT: role for core plugins

use strict;
use warnings;
use Params::Check qw[check];
use Moose::Role;

requires 'examine';
requires 'return_meta';

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

qq[And Dist::Zooky too!]

__END__

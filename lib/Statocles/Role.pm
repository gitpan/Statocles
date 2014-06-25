package Statocles::Role;
# ABSTRACT: Base module for all Statocles roles
$Statocles::Role::VERSION = '0.014';
use strict;
use warnings;
use base 'Statocles::Class';

sub modules {
    my ( $class, %args ) = @_;
    my @modules = grep { !/^Moo::Lax$/ } $class->SUPER::modules( %args );
    return (
        @modules,
        'Moo::Role::Lax',
    );
}

1;

__END__

=pod

=head1 NAME

Statocles::Role - Base module for all Statocles roles

=head1 VERSION

version 0.014

=head1 SYNOPSIS

    package MyRole;
    use Statocles::Role;

=head1 DESCRIPTION

This is the base module that all Statocles roles should use.

In addition to all the imports from L<Statocles::Class> (except L<Moo::Lax>),
this module imports:

=over

=item L<Moo::Role::Lax>

Turns the module into a Role.

=back

=head1 SEE ALSO

=over

=item L<Statocles::Class>

=back

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

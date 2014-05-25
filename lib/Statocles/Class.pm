package Statocles::Class;
{
  $Statocles::Class::VERSION = '0.004';
}
# ABSTRACT: Base module for all Statocles classes

use strict;
use warnings;
use base 'Statocles::Base';

sub modules {
    my ( $class, %args ) = @_;
    my @modules = $class->SUPER::modules( %args );
    return (
        @modules,
        'Moo::Lax',
        'MooX::Types::MooseLike::Base' => [qw( :all )],
    );
}

1;

__END__

=pod

=head1 NAME

Statocles::Class - Base module for all Statocles classes

=head1 VERSION

version 0.004

=head1 SYNOPSIS

    package MyClass;
    use Statocles::Class;

=head1 DESCRIPTION

This is the base module that all Statocles classes should use.

In addition to all the imports from L<Statocles::Base>, this module imports:

=over

=item Moo::Lax

Moo without strictures.

=item MooX::Types::MooseLike::Base

To get all the Moose-y type constraints.

=back

=head1 SEE ALSO

=over

=item L<Statocles::Base>

=back

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
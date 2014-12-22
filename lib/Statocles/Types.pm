package Statocles::Types;
# ABSTRACT: Type constraints and coercions for Statocles
$Statocles::Types::VERSION = '0.029';
use Type::Library -base, -declare => qw( Store Theme );
use Type::Utils -all;
use Types::Standard -types;

class_type Store, { class => "Statocles::Store" };
coerce Store, from Str, via { Statocles::Store->new( path => $_ ) };
coerce Store, from InstanceOf['Path::Tiny'], via { Statocles::Store->new( path => $_ ) };

class_type Theme, { class => "Statocles::Theme" };
coerce Theme, from Str, via { Statocles::Theme->new( store => $_ ) };
coerce Theme, from InstanceOf['Path::Tiny'], via { Statocles::Theme->new( store => $_ ) };

1;

__END__

=pod

=head1 NAME

Statocles::Types - Type constraints and coercions for Statocles

=head1 VERSION

version 0.029

=head1 SYNOPSIS

    use Statocles::Class;
    use Statocles::Types qw( :all );

    has store => (
        isa => Store,
        coerce => Store->coercion,
    );

    has theme => (
        isa => Theme,
        coerce => Theme->coercion,
    );

=head1 DESCRIPTION

This is a L<type library|Type::Tiny::Manual::Library> for common Statocles types.

=head1 TYPES

=head2 Store

A L<Statocles::Store> object.

This can be coerced from any L<Path::Tiny> object or any String, which will be
used as the filesystem path to the store's documents (the L<path
attribute|Statocles::Store/path>)

=head2 Theme

A L<Statocles::Theme> object.

This can be coerced from any L<Path::Tiny> object or any String, which will be
used as the L<store attribute|Statocles::Theme/store> (which will then be given
to the Store's path attribute).

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

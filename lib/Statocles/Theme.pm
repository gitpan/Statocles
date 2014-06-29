package Statocles::Theme;
# ABSTRACT: Templates, headers, footers, and navigation
$Statocles::Theme::VERSION = '0.016';
use Statocles::Class;
use File::Share qw( dist_dir );
use Scalar::Util qw( blessed );


has path => (
    is => 'ro',
    isa => Path,
    coerce => Path->coercion,
);


has templates => (
    is => 'ro',
    isa => HashRef[HashRef[InstanceOf['Statocles::Template']]],
    lazy => 1,
    builder => 'read',
);


around BUILDARGS => sub {
    my ( $orig, $self, @args ) = @_;
    my $args = $self->$orig( @args );
    if ( $args->{path} && $args->{path} =~ /^::/ ) {
        my $name = substr $args->{path}, 2;
        $args->{path} = Path::Tiny->new( dist_dir( 'Statocles' ) )->child( 'theme', $name );
    }
    return $args;
};


sub read {
    my ( $self ) = @_;
    my %tmpl;
    my $iter = $self->path->iterator({ recurse => 1, follow_symlinks => 1 });
    while ( my $path = $iter->() ) {
        if ( $path =~ /[.]ep$/ ) {
            my $name = $path->basename( '.ep' ); # remove extension
            my $group = $path->parent->basename;
            $tmpl{ $group }{ $name } = Statocles::Template->new(
                path => $path,
            );
        }
    }
    return \%tmpl;
}


sub template {
    my ( $self, $app, $template ) = @_;
    return $self->templates->{ $app }{ $template };
}


sub coercion {
    my ( $class ) = @_;
    return sub {
        return $_[0] if blessed $_[0] and $_[0]->isa( $class );
        return $class->new( path => $_[0] );
    };
}

1;

__END__

=pod

=head1 NAME

Statocles::Theme - Templates, headers, footers, and navigation

=head1 VERSION

version 0.016

=head1 SYNOPSIS

    # Template directory layout
    /theme/site/layout.html.ep
    /theme/blog/index.html.ep
    /theme/blog/post.html.ep

    my $theme      = Statocles::Theme->new( path => '/theme' );
    my $layout     = $theme->template( site => 'layout.html' );
    my $blog_index = $theme->template( blog => 'index.html' );
    my $blog_post  = $theme->template( blog => 'post.html' );

=head1 DESCRIPTION

A Theme contains all the L<templates|Statocles::Template> that
L<applications|Statocles::App> need. This class handles finding and parsing
files into L<template objects|Statocles::Template>.

When the L</path> is read, the templates inside are organized based on
their name and their parent directory.

=head1 ATTRIBUTES

=head2 path

The source directory for this theme.

If the path begins with ::, will pull one of the Statocles default
themes from the Statocles share directory.

=head2 templates

The template objects for this theme.

=head1 METHODS

=head2 BUILDARGS

Handle the path :: share theme.

=head2 read()

Read the C<path> and create the L<template|Statocles::Template> objects
inside.

=head2 template( $section => $name )

Get the L<template|Statocles::Template> from the given C<section> with the
given C<name>.

=head2 coercion

Class method to coerce a string representing a path into a Statocles::Theme
object. Returns a subref suitable to be used as a type coercion in an attriute.

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

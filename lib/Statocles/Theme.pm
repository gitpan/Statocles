package Statocles::Theme;
# ABSTRACT: Templates, headers, footers, and navigation
$Statocles::Theme::VERSION = '0.030';
use Statocles::Base 'Class';
use File::Share qw( dist_dir );
use Scalar::Util qw( blessed );


has store => (
    is => 'ro',
    isa => Store,
    coerce => Store->coercion,
    required => 1,
);


has _templates => (
    is => 'ro',
    isa => HashRef[HashRef[InstanceOf['Statocles::Template']]],
    default => sub { {} },
    lazy => 1,  # Must be lazy or the clearer won't re-init the default
    clearer => 'clear',
);


around BUILDARGS => sub {
    my ( $orig, $self, @args ) = @_;
    my $args = $self->$orig( @args );
    if ( $args->{store} && !ref $args->{store} && $args->{store} =~ /^::/ ) {
        my $name = substr $args->{store}, 2;
        $args->{store} = Path::Tiny->new( dist_dir( 'Statocles' ) )->child( 'theme', $name );
    }
    return $args;
};


sub read {
    my ( $self, $app, $template ) = @_;
    my $path = Path::Tiny->new( $app, $template . ".ep" );
    my $content = $self->store->read_file( $path );
    return Statocles::Template->new(
        path => $path,
        content => $content,
        store => $self->store,
    );
}


sub template {
    my ( $self, $app, $template ) = @_;
    return $self->_templates->{ $app }{ $template } ||= $self->read( $app, $template );
}

1;

__END__

=pod

=head1 NAME

Statocles::Theme - Templates, headers, footers, and navigation

=head1 VERSION

version 0.030

=head1 SYNOPSIS

    # Template directory layout
    /theme/site/layout.html.ep
    /theme/blog/index.html.ep
    /theme/blog/post.html.ep

    my $theme      = Statocles::Theme->new( store => '/theme' );
    my $layout     = $theme->template( site => 'layout.html' );
    my $blog_index = $theme->template( blog => 'index.html' );
    my $blog_post  = $theme->template( blog => 'post.html' );

=head1 DESCRIPTION

A Theme contains all the L<templates|Statocles::Template> that
L<applications|Statocles::App> need. This class handles finding and parsing
files into L<template objects|Statocles::Template>.

When the L</store> is read, the templates inside are organized based on
their name and their parent directory.

=head1 ATTRIBUTES

=head2 store

The source L<store|Statocles::Store> for this theme.

If the path begins with ::, will pull one of the Statocles default
themes from the Statocles share directory.

=head2 _templates

The cached template objects for this theme.

=head1 METHODS

=head2 BUILDARGS

Handle the path :: share theme.

=head2 read( $section => $name )

Read the template for the given C<section> and C<name> and create the
L<template|Statocles::Template> object.

=head2 template( $section => $name )

Get the L<template|Statocles::Template> from the given C<section> with the
given C<name>.

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

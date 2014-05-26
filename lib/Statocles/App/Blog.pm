package Statocles::App::Blog;
{
  $Statocles::App::Blog::VERSION = '0.005';
}
# ABSTRACT: A blog application

use Statocles::Class;
use Statocles::Page::Document;
use Statocles::Page::List;

extends 'Statocles::App';


has source => (
    is => 'ro',
    isa => InstanceOf['Statocles::Store'],
);


has url_root => (
    is => 'ro',
    isa => Str,
    required => 1,
);


has theme => (
    is => 'ro',
    isa => InstanceOf['Statocles::Theme'],
    required => 1,
);


sub post_pages {
    my ( $self ) = @_;
    my @pages;
    for my $doc ( @{ $self->source->documents } ) {
        my $path = join "/", $self->url_root, $doc->path;
        $path =~ s{/{2,}}{/}g;
        $path =~ s{[.]\w+$}{.html};
        push @pages, Statocles::Page::Document->new(
            layout => $self->theme->templates->{site}{layout},
            template => $self->theme->templates->{blog}{post},
            document => $doc,
            path => $path,
        );
    }
    return @pages;
}


sub index {
    my ( $self ) = @_;
    return Statocles::Page::List->new(
        path => join( "/", $self->url_root, 'index.html' ),
        template => $self->theme->template( blog => 'index' ),
        layout => $self->theme->template( site => 'layout' ),
        pages => [ $self->post_pages ],
    );
}


sub pages {
    my ( $self ) = @_;
    return ( $self->post_pages, $self->index );
}

1;

__END__

=pod

=head1 NAME

Statocles::App::Blog - A blog application

=head1 VERSION

version 0.005

=head1 DESCRIPTION

This is a simple blog application for Statocles.

=head1 ATTRIBUTES

=head2 source

The Statocles::Source to read for documents.

=head2 url_root

The URL root of this application. All pages from this app will be under this
root. Use this to ensure two apps do not try to write the same path.

=head2 theme

The Statocles::Theme for this app. See L<#THEME> for what templates this app
requires.

=head1 METHODS

=head2 post_pages()

Get the individual post Statocles::Page objects.

=head2 index()

Get the index page (a Statocles::Page object) for this application.

=head2 pages()

Get all the pages for this application.

=head1 THEME

=over

=item blog => index

The index page template. Gets the following template variables:

=over

=item site

The Statocles::Site object.

=item pages

An array reference containing all the blog post pages. Each page is a hash reference with the following keys:

=over

=item content

The post content

=item title

The post title

=item author

The post author

=back

=item blog => post

The main post page template. Gets the following template variables:

=over

=item site

The Statocles::Site object

=item content

The post content

=item title

The post title

=item author

The post author

=back

=back

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

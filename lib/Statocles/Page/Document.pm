package Statocles::Page::Document;
# ABSTRACT: Render documents into HTML
$Statocles::Page::Document::VERSION = '0.013';
use Statocles::Class;
with 'Statocles::Page';
use Text::Markdown;
use Statocles::Template;


has published => (
    is => 'ro',
    isa => InstanceOf['Time::Piece'],
);


has document => (
    is => 'ro',
    isa => InstanceOf['Statocles::Document'],
);


has '+template' => (
    default => sub {
        Statocles::Template->new( content => '<%= $content %>' );
    },
);


sub content {
    my ( $self ) = @_;
    return $self->markdown->markdown( $self->document->content );
}


sub vars {
    my ( $self ) = @_;
    return (
        content => $self->content,
        doc => $self->document,
    );
}

1;

__END__

=pod

=head1 NAME

Statocles::Page::Document - Render documents into HTML

=head1 VERSION

version 0.013

=head1 DESCRIPTION

This page class takes a single L<document|Statocles::Document> and renders it as HTML.

=head1 ATTRIBUTES

=head2 published

The publish date/time of this page. A L<Time::Piece> object.

=head2 document

The L<document|Statocles::Document> this page will render.

=head2 template

The L<template|Statocles::Template> to render the
L<document|Statocles::Document>.

=head1 METHODS

=head2 content

Generate the document HTML by converting Markdown.

=head2 vars

Get the template variables for this page.

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

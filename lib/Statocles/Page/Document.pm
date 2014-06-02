package Statocles::Page::Document;
# ABSTRACT: Render documents into HTML
$Statocles::Page::Document::VERSION = '0.007';
use Statocles::Class;
with 'Statocles::Page';
use Text::Markdown;
use Statocles::Template;


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


sub render {
    my ( $self, %args ) = @_;
    my $content = $self->template->render(
        %args,
        %{$self->document},
        content => $self->content,
        path => $self->path,
    );
    return $self->layout->render(
        %args,
        content => $content,
        path => $self->path,
    );
}

1;

__END__

=pod

=head1 NAME

Statocles::Page::Document - Render documents into HTML

=head1 VERSION

version 0.007

=head1 DESCRIPTION

This page class takes a single L<document|Statocles::Document> and renders it as HTML.

=head1 ATTRIBUTES

=head2 document

The L<document|Statocles::Document> this page will render.

=head2 template

The L<template|Statocles::Template> to render the
L<document|Statocles::Document>.

=head1 METHODS

=head2 content

Generate the document HTML by converting Markdown.

=head2 render

Render the page, using the L<template|Statocles::Page/template> and wrapping
with the L<layout|Statocles::Page/layout>.

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

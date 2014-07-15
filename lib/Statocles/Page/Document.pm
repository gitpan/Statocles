package Statocles::Page::Document;
# ABSTRACT: Render documents into HTML
$Statocles::Page::Document::VERSION = '0.020';
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


has tags => (
    is => 'ro',
    isa => ArrayRef[HashRef],
    default => sub { [] },
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


sub sections {
    my ( $self ) = @_;
    my @sections = split /\n---\n/, $self->document->content;
    return map { $self->markdown->markdown( $_ ) } @sections;
}

1;

__END__

=pod

=head1 NAME

Statocles::Page::Document - Render documents into HTML

=head1 VERSION

version 0.020

=head1 DESCRIPTION

This page class takes a single L<document|Statocles::Document> and renders it as HTML.

=head1 ATTRIBUTES

=head2 published

The publish date/time of this page. A L<Time::Piece> object.

=head2 document

The L<document|Statocles::Document> this page will render.

=head2 tags

The tag links for this document. An array of link hashes with the following
keys:

    title   - The title of the link
    href    - The page of the link

=head1 METHODS

=head2 content

Generate the document HTML by converting Markdown.

=head2 vars

Get the template variables for this page.

=head2 sections

Get a list of content divided into sections. The Markdown "---" marker divides
sections.

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

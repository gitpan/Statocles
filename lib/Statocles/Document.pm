package Statocles::Document;
# ABSTRACT: Base class for all Statocles documents
$Statocles::Document::VERSION = '0.007';
use Statocles::Class;


has path => (
    is => 'rw',
    isa => Path,
    coerce => Path->coercion,
);


has title => (
    is => 'rw',
    isa => Str,
);


has author => (
    is => 'rw',
    isa => Str,
);


has content => (
    is => 'rw',
    isa => Str,
);


has tags => (
    is => 'rw',
    isa => ArrayRef,
    default => sub { [] },
    coerce => sub {
        if ( !ref $_[0] ) {
            return [ split /\s*,\s*/, $_[0] ];
        }
        return $_[0];
    },
);


sub dump {
    my ( $self ) = @_;
    return {
        map { $_ => $self->$_ } qw( title author content tags )
    };
}

1;

__END__

=pod

=head1 NAME

Statocles::Document - Base class for all Statocles documents

=head1 VERSION

version 0.007

=head1 DESCRIPTION

A Statocles::Document is the base unit of content in Statocles.
L<Applications|Statocles::App> take documents to build
L<pages|Statocles::Page>.

This is the Model class in the Model-View-Controller pattern.

=head1 ATTRIBUTES

=head2 path

The path to this document.

=head2 title

The title from this document.

=head2 author

The author of this document.

=head2 content

The raw content of this document, in markdown.

=head2 tags

The tags for this document. Tags are used to categorize documents.

Tags may be specified as an array or as a comma-seperated string of
tags.

=head1 METHODS

=head2 dump

Get this document as a hash reference.

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

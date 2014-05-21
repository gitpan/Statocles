package Statocles::Document;
{
  $Statocles::Document::VERSION = '0.002';
}
# ABSTRACT: Base class for all Statocles documents

use Statocles::Class;


has path => (
    is => 'rw',
    isa => Str,
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


sub dump {
    my ( $self ) = @_;
    return {
        map { $_ => $self->$_ } qw( title author content )
    };
}

1;

__END__

=pod

=head1 NAME

Statocles::Document - Base class for all Statocles documents

=head1 VERSION

version 0.002

=head1 DESCRIPTION

A Statically::Document is the base unit of content in Statocles. Applications
take Documents to build Pages.

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

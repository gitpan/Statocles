package Statocles::Page::Feed;
# ABSTRACT: A page for a feed of another page
$Statocles::Page::Feed::VERSION = '0.015';
use Statocles::Class;
with 'Statocles::Page';


has page => (
    is => 'ro',
    isa => InstanceOf['Statocles::Page::List'],
);


has type => (
    is => 'ro',
    isa => Str,
);


sub vars {
    my ( $self ) = @_;
    return (
        pages => $self->page->pages,
    );
}

1;

__END__

=pod

=head1 NAME

Statocles::Page::Feed - A page for a feed of another page

=head1 VERSION

version 0.015

=head1 DESCRIPTION

A feed page encapsulates a L<list page|Statocles::Page::List> to display in a
feed view (RSS or ATOM or similar).

=head1 ATTRIBUTES

=head2 page

The source L<list page|Statocles::Page::List> to use for this feed.

=head2 type

The MIME type of this feed.

    application/rss+xml     - RSS feed
    application/atom+xml    - Atom feed

=head1 METHODS

=head2 vars

Get the template variables for this page.

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

package Statocles::Page::Plain;
# ABSTRACT: A plain page (with templates)
$Statocles::Page::Plain::VERSION = '0.031';
use Statocles::Base 'Class';
with 'Statocles::Page';


has content => (
    is => 'ro',
    isa => Str,
    required => 1,
);


has last_modified => (
    is => 'ro',
    isa => InstanceOf['Time::Piece'],
    default => sub { Time::Piece->new },
);


sub vars {
    my ( $self ) = @_;
    return (
        content => $self->content,
    );
}

1;

__END__

=pod

=head1 NAME

Statocles::Page::Plain - A plain page (with templates)

=head1 VERSION

version 0.031

=head1 SYNOPSIS

    my $page = Statocles::Page::Plain->new(
        path => '/path/to/page.html',
        content => '...',
    );

    my $js = Statocles::Page::Plain->new(
        path => '/js/app.js',
        content => '...',
    );

=head1 DESCRIPTION

This L<Statocles::Page> contains any content you want to put in it, while still
allowing for templates and layout. This is useful when you generate HTML (or
anything else) outside of Statocles.

=head1 ATTRIBUTES

=head2 content

The content of the page, already rendered to HTML.

=head2 last_modified

The last modified time of the page.

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

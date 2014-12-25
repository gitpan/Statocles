package Statocles::App::Static;
# ABSTRACT: Manage static files like CSS, JS, images, and other untemplated content
$Statocles::App::Static::VERSION = '0.031';
use Statocles::Base 'Class';
extends 'Statocles::App';
use Statocles::Page::File;


has url_root => (
    is => 'ro',
    isa => Str,
    required => 1,
);


has store => (
    is => 'ro',
    isa => Store,
    required => 1,
    coerce => Store->coercion,
);


sub pages {
    my ( $self ) = @_;

    my @pages;
    my $iter = $self->store->find_files;
    while ( my $path = $iter->() ) {
        next if $path->basename =~ /^[.]/;
        push @pages, Statocles::Page::File->new(
            path => $path,
            fh => $self->store->open_file( $path ),
        );
    }

    return @pages;
}

1;

__END__

=pod

=head1 NAME

Statocles::App::Static - Manage static files like CSS, JS, images, and other untemplated content

=head1 VERSION

version 0.031

=head1 ATTRIBUTES

=head2 url_root

The root URL for this application. Required.

=head2 store

The L<store|Statocles::Store> containing this app's files. Required.

=head1 METHODS

=head2 pages

Get the L<pages|Statocles::Page> for this app.

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

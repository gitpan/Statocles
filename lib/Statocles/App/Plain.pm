package Statocles::App::Plain;
# ABSTRACT: Plain documents made into pages with no extras
$Statocles::App::Plain::VERSION = '0.030';
use Statocles::Base 'Class';
extends 'Statocles::App';
use List::Util qw( first );
use Statocles::Page::Document;


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


has theme => (
    is => 'ro',
    isa => Theme,
    required => 1,
    coerce => Theme->coercion,
);


sub pages {
    my ( $self ) = @_;
    my @pages;

    for my $doc ( @{ $self->store->documents } ) {
        my $url = $doc->path;
        $url =~ s/[.]markdown$/.html/;

        my $page = Statocles::Page::Document->new(
            path => join( '/', $self->url_root, $url ),
            document => $doc,
            layout => $self->theme->template( site => 'layout.html' ),
            published => Time::Piece->new,
        );

        if ( $url eq 'index.html' ) {
            unshift @pages, $page;
        }
        else {
            push @pages, $page;
        }
    }

    return @pages;
}

1;

__END__

=pod

=head1 NAME

Statocles::App::Plain - Plain documents made into pages with no extras

=head1 VERSION

version 0.030

=head1 SYNOPSIS

    my $app = Statocles::App::Plain->new(
        url_root => '/',
        store => 'share/root',
        theme => 'share/theme/default',
    );
    my @pages = $app->pages;

=head1 DESCRIPTION

This application builds simple pages based on L<documents|Statocles::Document>. Use this
to have basic informational pages like "About Us" and "Contact Us".

=head1 ATTRIBUTES

=head2 url_root

The root URL for this application. Required.

=head2 store

The L<store|Statocles::Store> containing this app's documents. Required.

=head2 theme

The L<theme|Statocles::Theme> for this app. Required.

Only layouts are used.

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

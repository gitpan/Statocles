package Statocles::Page::List;
# ABSTRACT: A page presenting a list of other pages
$Statocles::Page::List::VERSION = '0.029';
use Statocles::Base 'Class';
with 'Statocles::Page';
use List::Util qw( max );
use List::MoreUtils qw( part );
use Statocles::Template;


has pages => (
    is => 'ro',
    isa => ArrayRef[ConsumerOf['Statocles::Page']],
);


has [qw( next prev )] => (
    is => 'ro',
    isa => Path,
    coerce => Path->coercion,
);


has '+search_change_frequency' => (
    default => sub { 'daily' },
);


has '+search_priority' => (
    default => sub { 0.3 },
);


sub paginate {
    my ( $class, %args ) = @_;

    # Unpack the args so we can pass the rest to new()
    my $after = delete $args{after} // 5;
    my $pages = delete $args{pages};
    my $path_format = delete $args{path};
    my $index = delete $args{index};

    my @sets = part { int( $_ / $after ) } 0..$#{$pages};
    my @retval;
    for my $i ( 0..$#sets ) {
        my $path = $index && $i == 0 ? $index : sprintf( $path_format, $i + 1 );
        my $prev = $index && $i == 1 ? $index : sprintf( $path_format, $i );
        push @retval, $class->new(
            path => $path,
            pages => [ @{$pages}[ @{ $sets[$i] } ] ],
            ( $i != $#sets ? ( next => sprintf( $path_format, $i + 2 ) ) : () ),
            ( $i > 0 ? ( prev => $prev ) : () ),
            published => $pages->[0]->last_modified,
            %args,
        );
    }

    return @retval;
}


sub vars {
    my ( $self ) = @_;
    return (
        pages => $self->pages,
    );
}


sub last_modified {
    my ( $self ) = @_;
    return $self->published || max map { $_->last_modified } @{ $self->pages };
}

1;

__END__

=pod

=head1 NAME

Statocles::Page::List - A page presenting a list of other pages

=head1 VERSION

version 0.029

=head1 DESCRIPTION

A List page contains a set of other pages. These are frequently used for index
pages.

=head1 ATTRIBUTES

=head2 pages

The pages that should be shown in this list.

=head2 next

The path to the next page in the pagination series.

=head2 prev

The path to the previous page in the pagination series.

=head2 search_change_frequency

Override the default L<search_change_frequency|Statocles::Page/search_change_frequency>
to C<daily>, because these pages aggregate other pages.

=head2 search_priority

Override the default L<search_priority|Statocles::Page/search_priority> to reduce
the rank of list pages to C<0.3>.

It is more important for users to get to the full page than
to get to this list page, which may contain truncated content, and whose relevant
content may appear 3-4 items down the page.

=head1 METHODS

=head2 paginate

Build a paginated list of Statocles::Page::List objects.

Takes a list of key-value pairs with the following keys:

    path    - An sprintf format string to build the path, like '/page-%i.html'.
              Pages are indexed started at 1.
    index   - The special, unique path for the first page. Optional.
    pages   - The arrayref of Statocles::Page::Document objects to paginate.
    after   - The number of items per page. Defaults to 5.

Return a list of Statocles::Page::List objects in numerical order, the index
page first (if any).

=head2 vars

Get the template variables for this page.

=head2 last_modified

Get the last modified date of this page. This will be the most recent last modified
date of the pages inside this page.

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

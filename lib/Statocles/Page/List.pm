package Statocles::Page::List;
# ABSTRACT: A page presenting a list of other pages
$Statocles::Page::List::VERSION = '0.010';
use Statocles::Class;
with 'Statocles::Page';
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


has '+template' => (
    default => sub {
        Statocles::Template->new(
            content => <<'ENDTEMPLATE'
% for my $page ( @$pages ) {
<%= $page->{published} %> <%= $page->{path} %> <%= $page->{title} %> <%= $page->{author} %> <%= $page->{content} %>
% }
ENDTEMPLATE
        );
    },
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
            %args,
        );
    }

    return @retval;
}


sub render {
    my ( $self, %args ) = @_;
    my $content = $self->template->render(
        %args,
        pages => [
            map { +{ %{ $_->document }, published => $_->published, content => $_->content, path => $_->path } }
            @{ $self->pages }
        ],
        app => $self->app,
        next => $self->next,
        prev => $self->prev,
    );
    return $self->layout->render(
        %args,
        content => $content,
        app => $self->app,
    );
}

1;

__END__

=pod

=head1 NAME

Statocles::Page::List - A page presenting a list of other pages

=head1 VERSION

version 0.010

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

=head2 template

The body template for this list. Should be a string or a Statocles::Template
object.

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

=head2 render

Render this page. Returns the full content of the page.

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

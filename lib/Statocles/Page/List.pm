package Statocles::Page::List;
{
  $Statocles::Page::List::VERSION = '0.005';
}
# ABSTRACT: A page presenting a list of other pages

use Statocles::Class;
with 'Statocles::Page';
use Statocles::Template;


has pages => (
    is => 'ro',
    isa => ArrayRef[ConsumerOf['Statocles::Page']],
);


has '+template' => (
    default => sub {
        Statocles::Template->new(
            content => <<'ENDTEMPLATE'
% for my $page ( @$pages ) {
<%= $page->{path} %> <%= $page->{title} %> <%= $page->{author} %> <%= $page->{content} %>
% }
ENDTEMPLATE
        );
    },
);


sub render {
    my ( $self, %args ) = @_;
    my $content = $self->template->render(
        %args,
        pages => [
            map { +{ %{ $_->document }, content => $_->content, path => $_->path } }
            @{ $self->pages }
        ],
    );
    return $self->layout->render(
        %args,
        content => $content,
    );
}

1;

__END__

=pod

=head1 NAME

Statocles::Page::List - A page presenting a list of other pages

=head1 VERSION

version 0.005

=head1 DESCRIPTION

A List page contains a set of other pages. These are frequently used for index
pages.

=head1 ATTRIBUTES

=head2 pages

The pages that should be shown in this list.

=head2 template

The body template for this list. Should be a string or a Statocles::Template
object.

=head1 METHODS

=head2 render

Render this page. Returns the full content of the page.

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

package Statocles::Page::File;
# ABSTRACT: A page wrapping a file (handle)
$Statocles::Page::File::VERSION = '0.029';
use Statocles::Base 'Class';
with 'Statocles::Page';


has fh => (
    is => 'ro',
    isa => FileHandle,
    required => 1,
);


has last_modified => (
    is => 'ro',
    isa => InstanceOf['Time::Piece'],
    default => sub { Time::Piece->new },
);


# XXX: This may have to be implemented in the future, to allow for some useful edge
# cases.
sub vars { die "Unimplemented" }


sub render {
    my ( $self ) = @_;
    return $self->fh;
}

1;

__END__

=pod

=head1 NAME

Statocles::Page::File - A page wrapping a file (handle)

=head1 VERSION

version 0.029

=head1 SYNOPSIS

    open my $fh, '<', '/path/to/file.txt';

    my $page = Statocles::Page::File->new(
        path => '/path/to/page.txt',
        fh => $fh,
    );

=head1 DESCRIPTION

This L<Statocles::Page> wraps a file handle in order to move files from one
L<store|Statocles::Store> to another.

=head1 ATTRIBUTES

=head2 fh

The file handle containing the contents of the page. Required.

=head2 last_modified

The last modified time of the page.

=head1 METHODS

=head2 vars

Dies. This page has no templates and no template variables.

=head2 render

Return

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

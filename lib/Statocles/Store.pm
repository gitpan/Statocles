package Statocles::Store;
{
  $Statocles::Store::VERSION = '0.004';
}
# ABSTRACT: A repository for Documents and Pages

use Statocles::Class;
use Statocles::Document;
use File::Find qw( find );
use File::Spec::Functions qw( splitdir );
use File::Path qw( make_path );
use File::Slurp qw( write_file );
use YAML;


has path => (
    is => 'ro',
    isa => Str,
    required => 1,
);


has documents => (
    is => 'rw',
    isa => ArrayRef[InstanceOf['Statocles::Document']],
    lazy => 1,
    builder => 'read_documents',
);


sub read_documents {
    my ( $self ) = @_;
    my $root_path = $self->path;
    my @docs;
    find(
        sub {
            if ( /[.]ya?ml$/ ) {
                my @yaml_docs = YAML::LoadFile( $_ );
                my $rel_path = $File::Find::name;
                $rel_path =~ s/\Q$root_path//;
                my $doc_path = join "/", splitdir( $rel_path );
                push @docs, map { Statocles::Document->new( path => $rel_path, %$_ ) } @yaml_docs;
            }
        },
        $root_path,
    );
    return \@docs;
}


sub write_page {
    my ( $self, $path, $html ) = @_;
    my $full_path = catfile( $self->path, $path );
    my ( $volume, $dirs, $file ) = splitpath( $full_path );
    make_path( catpath( $volume, $dirs, '' ) );
    write_file( $full_path, $html );
    return;
}

1;

__END__

=pod

=head1 NAME

Statocles::Store - A repository for Documents and Pages

=head1 VERSION

version 0.004

=head1 DESCRIPTION

A Statocles::Store reads and writes Documents and Pages.

This class handles the parsing and inflating of Document objects.

=head1 ATTRIBUTES

=head2 path

The path to the directory containing the documents.

=head2 documents

All the documents currently read by this store.

=head1 METHODS

=head2 read_documents()

Read the directory C<path> and create the Statocles::Document objects inside.

=head2 write_page( $path, $html )

Write the page C<html> to the given C<path>.

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

package Statocles::Store;
{
  $Statocles::Store::VERSION = '0.006';
}
# ABSTRACT: A repository for Documents and Pages

use Statocles::Class;
use Statocles::Document;
use File::Find qw( find );
use File::Spec::Functions qw( file_name_is_absolute splitdir );
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
                my $data = $self->read_document( $_ );
                my $rel_path = $File::Find::name;
                $rel_path =~ s/\Q$root_path//;
                my $doc_path = join "/", splitdir( $rel_path );
                push @docs, Statocles::Document->new( path => $rel_path, %$data );
            }
        },
        $root_path,
    );
    return \@docs;
}


sub read_document {
    my ( $self, $path ) = @_;
    open my $fh, '<', $path or die "Could not open '$path' for reading: $!\n";
    my $doc;
    my $buffer = '';
    while ( my $line = <$fh> ) {
        if ( !$doc ) { # Building YAML
            if ( $line =~ /^---/ && $buffer ) {
                $doc = YAML::Load( $buffer );
                $buffer = '';
            }
            else {
                $buffer .= $line;
            }
        }
        else { # Building Markdown
            $buffer .= $line;
        }
    }
    close $fh;

    # Clear the remaining buffer
    if ( !$doc && $buffer ) { # Must be only YAML
        $doc = YAML::Load( $buffer );
    }
    elsif ( !$doc->{content} && $buffer ) {
        $doc->{content} = $buffer;
    }

    return $doc;
}


sub write_document {
    my ( $self, $path, $doc ) = @_;
    if ( file_name_is_absolute( $path ) ) {
        die "Cannot write document '$path': Path must not be absolute";
    }
    my $full_path = catfile( $self->path, $path );
    my ( $vol, $dirs, $file ) = splitpath( $full_path );
    make_path( catpath( $vol, $dirs ) );

    $doc = { %{ $doc } }; # Shallow copy for safety
    my $content = delete $doc->{content};
    my $header = YAML::Dump( $doc );
    chomp $header;

    open my $fh, '>', $full_path or die "Could not open '$full_path' for writing: $!";
    print $fh join "\n", $header, '---', $content;
    close $fh;

    return $full_path;
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

version 0.006

=head1 DESCRIPTION

A Statocles::Store reads and writes Documents and Pages.

This class handles the parsing and inflating of Document objects.

=head2 Frontmatter Document Format

Documents are formatted with a YAML document on top, and Markdown content
on the bottom, like so:

    ---
    title: This is a title
    author: preaction
    ---
    # This is the markdown content
    
    This is a paragraph

=head1 ATTRIBUTES

=head2 path

The path to the directory containing the documents.

=head2 documents

All the documents currently read by this store.

=head1 METHODS

=head2 read_documents()

Read the directory C<path> and create the Statocles::Document objects inside.

=head2 read_document( path )

Read a single document in either pure YAML or combined YAML/Markdown
(Frontmatter) format and return a datastructure suitable to be given to
C<Statocles::Document::new>.

=head2 write_document( $path, $doc )

Write a document to the store. Returns the full path to the newly-updated
document.

The document is written in Frontmatter format.

=head2 write_page( $path, $html )

Write the page C<html> to the given C<path>.

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

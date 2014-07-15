package Statocles::Store;
# ABSTRACT: A repository for Documents and Pages
$Statocles::Store::VERSION = '0.020';
use Statocles::Class;
use Scalar::Util qw( blessed );
use Statocles::Document;
use YAML;
use File::Spec::Functions qw( splitdir );

my $DT_FORMAT = '%Y-%m-%d %H:%M:%S';


has path => (
    is => 'ro',
    isa => Path,
    coerce => Path->coercion,
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
    my $iter = $root_path->iterator( { recurse => 1, follow_symlinks => 1 } );
    while ( my $path = $iter->() ) {
        if ( $path =~ /[.]ya?ml$/ ) {
            my $rel_path = rootdir->child( $path->relative( $root_path ) );
            my $data = $self->read_document( $rel_path );
            push @docs, Statocles::Document->new( path => $rel_path, %$data );
        }
    }
    return \@docs;
}


sub read_document {
    my ( $self, $path ) = @_;
    diag( 1, "Read document: ", $path );
    my $full_path = $self->path->child( $path );
    open my $fh, '<', $full_path or die "Could not open '$full_path' for reading: $!\n";
    my $doc;
    my $buffer = '';
    while ( my $line = <$fh> ) {
        if ( !$doc ) { # Building YAML
            if ( $line =~ /^---/ && $buffer ) {
                eval {
                    $doc = YAML::Load( $buffer );
                };
                if ( $@ ) {
                    die "Error parsing YAML in '$full_path'\n$@";
                }
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
        eval {
            $doc = YAML::Load( $buffer );
        };
        if ( $@ ) {
            die "Error parsing YAML in '$full_path'\n$@";
        }
    }
    elsif ( !$doc->{content} && $buffer ) {
        $doc->{content} = $buffer;
    }

    return $self->_thaw_document( $doc );
}

sub _thaw_document {
    my ( $self, $doc ) = @_;
    if ( exists $doc->{last_modified} ) {
        $doc->{last_modified} = Time::Piece->strptime( $doc->{last_modified}, $DT_FORMAT );
    }
    return $doc;
}


sub write_document {
    my ( $self, $path, $doc ) = @_;
    $path = Path->coercion->( $path ); # Allow stringified paths, $path => $doc
    if ( $path->is_absolute ) {
        die "Cannot write document '$path': Path must not be absolute";
    }
    diag( 1, "Write document: ", $path );

    $doc = { %{ $doc } }; # Shallow copy for safety
    my $content = delete( $doc->{content} ) // '';
    my $header = YAML::Dump( $self->_freeze_document( $doc ) );
    chomp $header;

    my $full_path = $self->path->child( $path );
    $full_path->touchpath->spew( join "\n", $header, '---', $content );

    return $full_path;
}

sub _freeze_document {
    my ( $self, $doc ) = @_;
    if ( exists $doc->{last_modified} ) {
        $doc->{last_modified} = $doc->{last_modified}->strftime( $DT_FORMAT );
    }
    return $doc;
}


sub write_file {
    my ( $self, $path, $content ) = @_;
    diag( 1, "Write file: ", $path );
    my $full_path = $self->path->child( $path );
    $full_path->touchpath->spew( $content );
    return;
}


sub coercion {
    my ( $class ) = @_;
    return sub {
        return $_[0] if blessed $_[0] and $_[0]->isa( $class );
        return $class->new( path => $_[0] );
    };
}

1;

__END__

=pod

=head1 NAME

Statocles::Store - A repository for Documents and Pages

=head1 VERSION

version 0.020

=head1 DESCRIPTION

A Statocles::Store reads and writes L<documents|Statocles::Document> and
files (mostly L<pages|Statocles::Page>).

This class handles the parsing and inflating of
L<"document objects"|Statocles::Document>.

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

The path to the directory containing the L<documents|Statocles::Document>.

=head2 documents

All the L<documents|Statocles::Document> currently read by this store.

=head1 METHODS

=head2 read_documents()

Read the directory C<path> and create the L<document|Statocles::Document> objects inside.

=head2 read_document( path )

Read a single L<document|Statocles::Document> in either pure YAML or combined
YAML/Markdown (Frontmatter) format and return a datastructure suitable to be
given to L<Statocles::Document|Statocles::Document>.

=head2 write_document( $path, $doc )

Write a L<document|Statocles::Document> to the store. Returns the full path to
the newly-updated document.

The document is written in Frontmatter format.

=head2 write_file( $path, $content )

Write the given C<content> to the given C<path>. This is mostly used to write
out L<page objects|Statocles::Page>.

=head2 coercion

Class method to coerce a string representing a path into a Statocles::Store
object. Returns a subref suitable to be used as a type coercion in an attriute.

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

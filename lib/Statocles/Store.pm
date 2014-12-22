package Statocles::Store;
# ABSTRACT: A repository for Documents and Pages
$Statocles::Store::VERSION = '0.029';
use Statocles::Base 'Class';
use Scalar::Util qw( blessed );
use Statocles::Document;
use YAML;
use List::MoreUtils qw( firstidx );
use File::Spec::Functions qw( splitdir );

my $DATETIME_FORMAT = '%Y-%m-%d %H:%M:%S';
my $DATE_FORMAT = '%Y-%m-%d';


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
    clearer => 'clear',
);

sub BUILD {
    my ( $self ) = @_;
    if ( !$self->path->exists ) {
        die sprintf "Store path '%s' does not exist", $self->path->stringify;
    }
    elsif ( !$self->path->is_dir ) {
        die sprintf "Store path '%s' is not a directory", $self->path->stringify;
    }
}


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
    site->log->debug( "Read document: " . $path );
    my $full_path = $self->path->child( $path );
    my @lines = $full_path->lines_utf8;

    shift @lines while $lines[0] =~ /^---/;
    # The next --- is the end of the YAML frontmatter
    my $i = firstidx { /^---/ } @lines;

    my $doc;
    # If we found the marker between YAML and Markdown
    if ( $i > 0 ) {
        # Before the marker is YAML
        eval {
            $doc = YAML::Load( join "", @lines[0..$i-1] );
        };
        if ( $@ ) {
            die "Error parsing YAML in '$full_path'\n$@";
        }
        # After the marker is Markdown
        if ( !$doc->{content} ) {
            $doc->{content} = join "", @lines[$i+1..$#lines];
        }
    }
    # Otherwise, must be completely YAML
    else {
        eval {
            $doc = YAML::Load( join "", @lines );
        };
        if ( $@ ) {
            die "Error parsing YAML in '$full_path'\n$@";
        }
    }

    return $self->_thaw_document( $doc );
}

sub _thaw_document {
    my ( $self, $doc ) = @_;
    if ( exists $doc->{last_modified} ) {

        my $dt;
        eval {
            $dt = Time::Piece->strptime( $doc->{last_modified}, $DATETIME_FORMAT );
        };

        if ( $@ ) {
            eval {
                $dt = Time::Piece->strptime( $doc->{last_modified}, $DATE_FORMAT );
            };

            if ( $@ ) {
                die sprintf "Could not parse last_modified '%s'. Does not match '%s' or '%s'",
                    $doc->{last_modified},
                    $DATETIME_FORMAT,
                    $DATE_FORMAT,
                    ;
            }

        }

        $doc->{last_modified} = $dt;
    }
    return $doc;
}


sub write_document {
    my ( $self, $path, $doc ) = @_;
    $path = Path->coercion->( $path ); # Allow stringified paths, $path => $doc
    if ( $path->is_absolute ) {
        die "Cannot write document '$path': Path must not be absolute";
    }
    site->log->debug( "Write document: " . $path );

    $doc = { %{ $doc } }; # Shallow copy for safety
    my $content = delete( $doc->{content} ) // '';
    my $header = YAML::Dump( $self->_freeze_document( $doc ) );
    chomp $header;

    my $full_path = $self->path->child( $path );
    $full_path->touchpath->spew_utf8( join "\n", $header, '---', $content );

    return $full_path;
}

sub _freeze_document {
    my ( $self, $doc ) = @_;
    if ( exists $doc->{last_modified} ) {
        $doc->{last_modified} = $doc->{last_modified}->strftime( $DATETIME_FORMAT );
    }
    return $doc;
}


sub read_file {
    my ( $self, $path ) = @_;
    site->log->debug( "Read file: " . $path );
    return $self->path->child( $path )->slurp_utf8;
}


sub has_file {
    my ( $self, $path ) = @_;
    return $self->path->child( $path )->is_file;
}


sub find_files {
    my ( $self ) = @_;
    my $iter = $self->path->iterator({ recurse => 1 });
    return sub {
        my $path = $iter->();
        return unless $path;
        $path = $iter->() while $path->is_dir;
        return $path->relative( $self->path )->absolute( '/' );
    };
}


sub open_file {
    my ( $self, $path ) = @_;
    return $self->path->child( $path )->openr_raw;
}


sub write_file {
    my ( $self, $path, $content ) = @_;
    site->log->debug( "Write file: " . $path );
    my $full_path = $self->path->child( $path );

    if ( ref $content eq 'GLOB' ) {
        my $fh = $full_path->touchpath->openw_raw;
        while ( my $line = <$content> ) {
            $fh->print( $line );
        }
    }
    else {
        $full_path->touchpath->spew_utf8( $content );
    }

    return;
}

1;

__END__

=pod

=head1 NAME

Statocles::Store - A repository for Documents and Pages

=head1 VERSION

version 0.029

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

=head2 clear()

Clear the cached documents in this Store.

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

=head2 read_file( $path )

Read the file from the given C<path>.

=head2 has_file( $path )

Returns true if a file exists with the given C<path>.

NOTE: This should not be used to check for directories, as not all stores have
directories.

=head2 find_files()

Returns an iterator that, when called, produces a single path suitable to be passed
to L<read_file>.

=head2 open_file( $path )

Open the file with the given path. Returns a filehandle.

The filehandle opened is using raw bytes, not UTF-8 characters.

=head2 write_file( $path, $content )

Write the given C<content> to the given C<path>. This is mostly used to write
out L<page objects|Statocles::Page>.

C<content> may be a simple string or a filehandle. If given a string, will
write the string using UTF-8 characters. If given a filehandle, will write out
the raw bytes read from it with no special encoding.

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

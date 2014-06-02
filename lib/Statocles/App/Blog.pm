package Statocles::App::Blog;
# ABSTRACT: A blog application
$Statocles::App::Blog::VERSION = '0.007';
use Statocles::Class;
use Statocles::Page::Document;
use Statocles::Page::List;

extends 'Statocles::App';


has source => (
    is => 'ro',
    isa => InstanceOf['Statocles::Store'],
);


has url_root => (
    is => 'ro',
    isa => Str,
    required => 1,
);


has theme => (
    is => 'ro',
    isa => InstanceOf['Statocles::Theme'],
    required => 1,
);


our $default_post = {
    author => '',
    content => <<'ENDCONTENT',
Markdown content goes here.
ENDCONTENT
};

sub command {
    my ( $self, $name, @argv ) = @_;
    if ( $argv[0] eq 'help' ) {
        print <<ENDHELP;
$name help -- This help file
$name post <title> -- Create a new blog post with the given title
ENDHELP
    }
    elsif ( $argv[0] eq 'post' ) {
        my $title = join " ", @argv[1..$#argv];
        my $slug = lc $title;
        $slug =~ s/\s+/-/g;
        my ( undef, undef, undef, $day, $mon, $year ) = localtime;
        my @parts = (
            sprintf( '%04i', $year + 1900 ),
            sprintf( '%02i', $mon + 1 ),
            sprintf( '%02i', $day ),
            "$slug.yml",
        );
        my $path = Path::Tiny->new( @parts );
        my %doc = (
            %$default_post,
            title => $title,
        );
        my $full_path = $self->source->write_document( $path => \%doc );
        print "New post at: $full_path\n";
        if ( $ENV{EDITOR} ) {
            system $ENV{EDITOR}, $full_path;
        }
    }
    return 0;
}


sub post_pages {
    my ( $self ) = @_;
    my @pages;
    for my $doc ( @{ $self->source->documents } ) {
        my $path = join "/", $self->url_root, $doc->path;
        $path =~ s{/{2,}}{/}g;
        $path =~ s{[.]\w+$}{.html};
        push @pages, Statocles::Page::Document->new(
            layout => $self->theme->templates->{site}{layout},
            template => $self->theme->templates->{blog}{post},
            document => $doc,
            path => $path,
        );
    }
    return @pages;
}


sub index {
    my ( $self ) = @_;
    return Statocles::Page::List->new(
        path => join( "/", $self->url_root, 'index.html' ),
        template => $self->theme->template( blog => 'index' ),
        layout => $self->theme->template( site => 'layout' ),
        pages => [ sort { $b->path cmp $a->path } $self->post_pages ],
    );
}


sub pages {
    my ( $self ) = @_;
    return ( $self->post_pages, $self->index );
}

1;

__END__

=pod

=head1 NAME

Statocles::App::Blog - A blog application

=head1 VERSION

version 0.007

=head1 DESCRIPTION

This is a simple blog application for Statocles.

=head1 ATTRIBUTES

=head2 source

The L<store|Statocles::Store> to read for documents.

=head2 url_root

The URL root of this application. All pages from this app will be under this
root. Use this to ensure two apps do not try to write the same path.

=head2 theme

The L<theme|Statocles::Theme> for this app. See L</THEME> for what templates this app
uses.

=head1 METHODS

=head2 command( app_name, args )

Run a command on this app. The app name is used to build the help, so
users get exactly what they need to run.

=head2 post_pages()

Get the individual post Statocles::Page objects.

=head2 index()

Get the index page (a L<page|Statocles::Page> object) for this application.

=head2 pages()

Get all the L<pages|Statocles::Page> for this application.

=head1 THEME

=over

=item blog => index

The index page template. Gets the following template variables:

=over

=item site

The L<Statocles::Site> object.

=item pages

An array reference containing all the blog post pages. Each page is a hash reference with the following keys:

=over

=item content

The post content

=item title

The post title

=item author

The post author

=back

=item blog => post

The main post page template. Gets the following template variables:

=over

=item site

The L<Statocles::Site> object

=item content

The post content

=item title

The post title

=item author

The post author

=back

=back

=head1 SEE ALSO

=over 4

=item L<Statocles::App>

=back

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

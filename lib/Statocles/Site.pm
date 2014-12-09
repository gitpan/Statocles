package Statocles::Site;
# ABSTRACT: An entire, configured website
$Statocles::Site::VERSION = '0.027';
use Statocles::Class;
use Statocles::Store;
use Mojo::URL;
use Mojo::DOM;


has title => (
    is => 'ro',
    isa => Str,
);


has base_url => (
    is => 'ro',
    isa => Str,
);


has apps => (
    is => 'ro',
    isa => HashRef[InstanceOf['Statocles::App']],
);


has index => (
    is => 'ro',
    isa => Str,
    default => sub { '' },
);


has nav => (
    is => 'ro',
    isa => HashRef[ArrayRef[HashRef[Str]]],
    default => sub { {} },
);


has build_store => (
    is => 'ro',
    isa => InstanceOf['Statocles::Store'],
    required => 1,
    coerce => Statocles::Store->coercion,
);


has deploy_store => (
    is => 'ro',
    isa => InstanceOf['Statocles::Store'],
    lazy => 1,
    default => sub { $_[0]->build_store },
    coerce => Statocles::Store->coercion,
);


sub app {
    my ( $self, $name ) = @_;
    return $self->apps->{ $name };
}


sub build {
    my ( $self ) = @_;
    $self->write( $self->build_store );
}


sub deploy {
    my ( $self ) = @_;
    $self->write( $self->deploy_store );
}


sub write {
    my ( $self, $store ) = @_;
    my $apps = $self->apps;
    my @pages;
    my %args = (
        site => $self,
    );

    # Collect all the pages for this site
    for my $app_name ( keys %{ $apps } ) {
        my $app = $apps->{$app_name};

        my $index_path;
        if ( $self->index eq $app_name ) {
            $index_path = ($app->index)[0]->path;
        }

        for my $page ( $app->pages ) {
            if ( $index_path && $page->path eq $index_path ) {
                # Rename the app's page so that we don't get two pages with identical
                # content, which is bad for SEO
                $page->path( '/index.html' );
            }
            push @pages, $page;
        }
    }

    # Rewrite page content to add base URL
    my $base_path = Mojo::URL->new( $self->base_url )->path;
    $base_path =~ s{/$}{};
    for my $page ( @pages ) {
        my $html = $page->render( %args );

        if ( $base_path =~ /\S/ ) {
            my $dom = Mojo::DOM->new( $html );
            for my $attr ( qw( src href ) ) {
                for my $el ( $dom->find( "[$attr]" )->each ) {
                    my $url = $el->attr( $attr );
                    next unless $url =~ m{^/};
                    $el->attr( $attr, join "", $base_path, $url );
                }
            }
            $html = $dom->to_string;
        }

        $store->write_file( $page->path, $html );
    }

    # Build the sitemap.xml
    my @indexed_pages = grep { !$_->isa( 'Statocles::Page::Feed' ) } @pages;
    my $default_theme = Statocles::Theme->new( store => '::default' );
    my $tmpl = $default_theme->template( site => 'sitemap.xml' );
    $store->write_file( 'sitemap.xml', $tmpl->render( site => $self, pages => \@indexed_pages ) );

    # robots.txt is the best way for crawlers to automatically discover sitemap.xml
    # We should do more with this later...
    my @robots = (
        "Sitemap: " . $self->url( 'sitemap.xml' ),
        "User-Agent: *",
        "Disallow: ",
    );
    $store->write_file( 'robots.txt', join "\n", @robots );
}


sub url {
    my ( $self, $path ) = @_;
    my $base = $self->base_url;
    # Remove the / from both sides of the join so we don't double up
    $base =~ s{/$}{};
    $path =~ s{^/}{};
    return join "/", $base, $path;
}

1;

__END__

=pod

=head1 NAME

Statocles::Site - An entire, configured website

=head1 VERSION

version 0.027

=head1 SYNOPSIS

    my $site = Statocles::Site->new(
        title => 'My Site',
        nav => [
            { title => 'Home', href => '/' },
            { title => 'Blog', href => '/blog' },
        ],
        apps => {
            blog => Statocles::App::Blog->new( ... ),
        },
    );

    $site->deploy;

=head1 DESCRIPTION

A Statocles::Site is a collection of L<applications|Statocles::App>.

=head1 ATTRIBUTES

=head2 title

The site title, used in templates.

=head2 base_url

The base URL of the site, including protocol and domain. Used mostly for feeds.

=head2 apps

The applications in this site. Each application has a name
that can be used later.

=head2 index

The application to use as the site index. The application's individual index()
method will be called to get the index page.

=head2 nav

Named navigation lists. A hash of arrays of hashes with the following keys:

    title - The title of the link
    href - The href of the link

The most likely name for your navigation will be C<main>. Navigation names
are defined by your L<theme|Statocles::Theme>. For example:

    {
        main => [
            {
                title => 'Blog',
                href => '/blog/index.html',
            },
            {
                title => 'Contact',
                href => '/contact.html',
            },
        ],
    }

=head2 build_store

The L<store|Statocles::Store> object to use for C<build()>.

=head2 deploy_store

The L<store|Statocles::Store> object to use for C<deploy()>. Defaults to L<build_store>.

=head1 METHODS

=head2 app( name )

Get the app with the given C<name>.

=head2 build

Build the site in its build location

=head2 deploy

Write each application to its destination.

=head2 write( store )

Write the application to the given L<store|Statocles::Store>.

=head2 url( path )

Get the full URL to the given path by prepending the C<base_url>.

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

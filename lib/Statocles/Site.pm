package Statocles::Site;
# ABSTRACT: An entire, configured website
$Statocles::Site::VERSION = '0.008';
use Statocles::Class;


has title => (
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
    isa => ArrayRef[HashRef[Str]],
    default => sub { [] },
);


has build_store => (
    is => 'ro',
    isa => InstanceOf['Statocles::Store'],
    required => 1,
);


has deploy_store => (
    is => 'ro',
    isa => InstanceOf['Statocles::Store'],
    lazy => 1,
    default => sub { $_[0]->build_store },
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
    my %args = (
        site => $self,
    );
    for my $app_name ( keys %{ $apps } ) {
        my $app = $apps->{$app_name};
        for my $page ( $app->pages ) {
            if ( $self->index eq $app_name && $page->path eq $app->index->path ) {
                # Rename the app's page so that we don't get two pages with identical
                # content
                $page = Statocles::Page::List->new(
                    %{ $page },
                    path => '/index.html',
                );
            }
            $store->write_page( $page->path, $page->render( %args ) );
        }
    }
}

1;

__END__

=pod

=head1 NAME

Statocles::Site - An entire, configured website

=head1 VERSION

version 0.008

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

=head2 apps

The applications in this site. Each application has a name
that can be used later.

=head2 index

The application to use as the site index. The application's individual index()
method will be called to get the index page.

=head2 nav

The main site navigation. An array of hashes with the following keys:

    title - The title of the link
    href - The href of the link

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

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

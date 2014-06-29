package Statocles::Command;
# ABSTRACT: The statocles command-line interface
$Statocles::Command::VERSION = '0.017';
use Statocles::Class;
use Getopt::Long qw( GetOptionsFromArray );
use Pod::Usage::Return qw( pod2usage );
use Beam::Wire;


has site => (
    is => 'ro',
    isa => InstanceOf['Statocles::Site'],
);


sub main {
    my ( $class, @argv ) = @_;

    my %opt = (
        config => 'site.yml',
        site => 'site',
    );
    GetOptionsFromArray( \@argv, \%opt,
        'config:s',
        'site:s',
        'help|h',
        'version',
    );
    return pod2usage(0) if $opt{help};

    if ( $opt{version} ) {
        print "Statocles version $Statocles::Command::VERSION (Perl $^V)\n";
        return 0;
    }

    my $wire = Beam::Wire->new( file => $opt{config} );

    my $cmd = $class->new(
        site => $wire->get( $opt{site} ),
    );

    if ( @argv == 1 ) {
        my $method = $argv[0];
        if ( grep { $_ eq $method } qw( build deploy ) ) {
            $cmd->site->$method;
            return 0;
        }
        elsif ( $method eq 'apps' ) {
            my $apps = $cmd->site->apps;
            for my $app_name ( keys %{ $apps } ) {
                my $app = $apps->{$app_name};
                my $root = $app->url_root;
                my $class = ref $app;
                print "$app_name ($root -- $class)\n";
            }
            return 0;
        }
        elsif ( $method eq 'daemon' ) {
            require Mojo::Server::Daemon;
            my $daemon = Mojo::Server::Daemon->new(
                silent => 1,
                app => Statocles::Command::_MOJOAPP->new(
                    site => $cmd->site,
                ),
            );
            print "Listening on " . $daemon->listen->[0] . "\n";
            $daemon->run;
        }
    }
    else {
        my $app_name = $argv[0];
        return $cmd->site->apps->{ $app_name }->command( @argv );
    }

    return 0;
}

package Statocles::Command::_MOJOAPP;
$Statocles::Command::_MOJOAPP::VERSION = '0.017';
use Mojo::Base 'Mojolicious';
has 'site';

sub startup {
    my ( $self ) = @_;
    $self->routes->get( '/', sub { $_[0]->redirect_to( '/index.html' ) } );
    unshift @{ $self->static->paths },
        $self->site->build_store->path,
        # Add the deploy store for non-Statocles content
        # This won't work in certain situations, like a Git repo on another branch, but
        # this is convenience until we can track image directories and other non-generated
        # content.
        $self->site->deploy_store->path;
}

1;

__END__

=pod

=head1 NAME

Statocles::Command - The statocles command-line interface

=head1 VERSION

version 0.017

=head1 SYNOPSIS

    use Statocles::Command;
    exit Statocles::Command->main( @ARGV );

=head1 DESCRIPTION

This module implements the Statocles command-line interface.

=head1 ATTRIBUTES

=head2 site

The L<site|Statocles::Site> we're working with.

=head1 METHODS

=head2 main( @argv )

Run the command given in @argv. See L<statocles> for a list of commands and
options.

=head1 SEE ALSO

=over 4

=item L<statocles>

The documentation for the command-line application.

=back

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

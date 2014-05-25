package Statocles::Command;
{
  $Statocles::Command::VERSION = '0.003';
}
# ABSTRACT: The statocles command-line interface

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
        $cmd->site->$method;
    }

    return 0;
}

1;

__END__

=pod

=head1 NAME

Statocles::Command - The statocles command-line interface

=head1 VERSION

version 0.003

=head1 SYNOPSIS

    use Statocles::Command;
    exit Statocles::Command->main( @ARGV );

=head1 DESCRIPTION

This module implements the Statocles command-line interface.

=head1 ATTRIBUTES

=head2 site

The Statocles::Site we're working with.

=head1 METHODS

=head2 main( @argv )

Run the command given in @argv. See L<statocles> for a list of commands and
options.

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

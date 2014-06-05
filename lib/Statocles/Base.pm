package Statocles::Base;
# ABSTRACT: Base module for Statocles modules
$Statocles::Base::VERSION = '0.008';
use strict;
use warnings;
use base 'Import::Base';

sub modules {
    return (
        Statocles => [],
        strict => [],
        warnings => [],
        feature => [qw( :5.10 )],
        'Path::Tiny' => [qw( rootdir cwd )],
    );
}

1;

__END__

=pod

=head1 NAME

Statocles::Base - Base module for Statocles modules

=head1 VERSION

version 0.008

=head1 SYNOPSIS

    package MyModule;
    use Statocles::Module;

=head1 DESCRIPTION

This is the base module that all Statocles modules should use (unless they're
using a more-specific base).

This module imports the following into your namespace:

=over

=item L<Statocles>

The base module is imported to make sure that L<File::Share> can find the right
share directory.

=item L<strict>

=item L<warnings>

=item L<feature>

Currently the 5.10 feature bundle

=item L<Path::Tiny> qw( path rootdir )

We do a lot of work with the filesystem.

=back

=head1 SEE ALSO

=over

=item L<Import::Base>

=back

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

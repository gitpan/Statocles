package Statocles::Base;
{
  $Statocles::Base::VERSION = '0.002';
}
# ABSTRACT: Base module for Statocles modules

use strict;
use warnings;
use base 'Import::Base';

sub modules {
    return (
        strict => [],
        warnings => [],
        feature => [qw( :5.10 )],
        'File::Spec::Functions' => [qw( catdir catfile splitpath splitdir catpath )],
    );
}

1;

__END__

=pod

=head1 NAME

Statocles::Base - Base module for Statocles modules

=head1 VERSION

version 0.002

=head1 SYNOPSIS

    package MyModule;
    use Statocles::Module;

=head1 DESCRIPTION

This is the base module that all Statocles modules should use (unless they're
using a more-specific base).

This module imports the following into your namespace:

=over

=item strict

=item warnings

=item feature

Currently the 5.10 feature bundle

=item File::Spec::Functions qw( catdir catfile splitpath splitdir catpath )

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

package Statocles::Test;
# ABSTRACT: Base set of imports for all Statocles tests
$Statocles::Test::VERSION = '0.021';
use strict;
use warnings;

use base 'Statocles::Base';

sub modules {
    my ( $class, %args ) = @_;
    my @modules = $class->SUPER::modules( %args );
    return (
        @modules,
        'Test::Most',
        'Dir::Self' => [qw( __DIR__ )],
        'Path::Tiny' => [qw( path tempdir )],
    );
}

1;

__END__

=pod

=head1 NAME

Statocles::Test - Base set of imports for all Statocles tests

=head1 VERSION

version 0.021

=head1 SYNOPSIS

    # t/mytest.t
    use Statocles::Test;

=head1 DESCRIPTION

This is the base module that all Statocles test scripts should use.

In addition to all the imports from L<Statocles::Base>, this module imports:

=over

=item L<Test::Most>

Which includes Test::More, Test::Deep, Test::Differences, and Test::Exception.

=item L<Dir::Self>

Provides the __DIR__ keyword.

=item L<Path::Tiny> qw( path tempdir )

To create Path::Tiny objects and get temporary directories.

=back

=head1 SEE ALSO

=over

=item L<Statocles::Base>

=back

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

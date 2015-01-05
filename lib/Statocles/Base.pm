package Statocles::Base;
# ABSTRACT: Base module for Statocles modules
$Statocles::Base::VERSION = '0.032';
use strict;
use warnings;
use base 'Import::Base';

our @IMPORT_MODULES = (
    sub {
        # Disable spurious warnings on platforms that Net::DNS::Native does not
        # support. We don't use this much mojo
        $ENV{MOJO_NO_NDN} = 1;
        return;
    },
    strict => [],
    warnings => [],
    feature => [qw( :5.10 )],
    'Path::Tiny' => [qw( rootdir cwd )],
    'Time::Piece',
    'Statocles',
);

my @class_modules = (
    'Types::Standard' => [qw( :all )],
    'Types::Path::Tiny' => [qw( Path AbsPath )],
    'Statocles::Types' => [qw( :all )],
);

our %IMPORT_BUNDLES = (
    Test => [
        qw( Test::More Test::Deep Test::Differences Test::Exception ),
        'Dir::Self' => [qw( __DIR__ )],
        'Path::Tiny' => [qw( path tempdir cwd )],
        'Statocles::Test' => [qw( test_constructor test_pages )],
        'Statocles::Site',
        sub { $Statocles::VERSION = 0.001; return }, # Set version normally done via dzil
    ],

    Class => [
        '<Moo::Lax',
        @class_modules,
    ],

    Role => [
        '<Moo::Role::Lax',
        @class_modules,
    ],

);

1;

__END__

=pod

=head1 NAME

Statocles::Base - Base module for Statocles modules

=head1 VERSION

version 0.032

=head1 SYNOPSIS

    package MyModule;
    use Statocles::Base;

    use Statocles::Base 'Class';
    use Statocles::Base 'Role';
    use Statocles::Base 'Test';

=head1 DESCRIPTION

This is the base module that all Statocles modules should use.

=head1 MODULES

This module always imports the following into your namespace:

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

=item L<Time::Piece>

=back

=head1 BUNDLES

The following bundles are available. You may import one or more of these by name.

=head2 Class

The class bundle makes your package into a class and includes:

=over 4

=item L<Moo::Lax>

=item L<Types::Standard> ':all'

=item L<Types::Path::Tiny> ':all'

=item L<Statocles::Types> ':all'

=back

=head2 Role

The role bundle makes your package into a role and includes:

=over 4

=item L<Moo::Role::Lax>

=item L<Types::Standard> ':all'

=item L<Types::Path::Tiny> ':all'

=item L<Statocles::Types> ':all'

=back

=head2 Test

The test bundle includes:

=over 4

=item L<Test::More>

=item L<Test::Deep>

=item L<Test::Differences>

=item L<Test::Exception>

=item L<Dir::Self> '__DIR__'

=item L<Path::Tiny> 'path', 'tempdir'

=item L<Statocles::Test>

Some common test routines for Statocles.

=item L<Statocles::Site>

In order to have logging, a site object must be created.

=back

=head1 SEE ALSO

=over

=item L<Import::Base>

=back

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

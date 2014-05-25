package Statocles::App;
{
  $Statocles::App::VERSION = '0.004';
}
# ABSTRACT: Base class for Statocles applications

use Statocles::Class;

1;

__END__

=pod

=head1 NAME

Statocles::App - Base class for Statocles applications

=head1 VERSION

version 0.004

=head1 DESCRIPTION

A Statocles App turns Statocles::Documents into a set of Statocles::Pages
that can then be written to the filesystem (or served directly, if desired).

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

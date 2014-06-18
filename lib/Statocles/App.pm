package Statocles::App;
# ABSTRACT: Base class for Statocles applications
$Statocles::App::VERSION = '0.012';
use Statocles::Class;

1;

__END__

=pod

=head1 NAME

Statocles::App - Base class for Statocles applications

=head1 VERSION

version 0.012

=head1 DESCRIPTION

A Statocles App turns L<documents|Statocles::Documents> into a set of
L<pages|Statocles::Pages> that can then be written to the filesystem (or served
directly, if desired).

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

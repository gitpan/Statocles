package Statocles::Store;
# ABSTRACT: Base role for repositories of documents and files
$Statocles::Store::VERSION = '0.030';
use Statocles::Base 'Role';

1;

__END__

=pod

=head1 NAME

Statocles::Store - Base role for repositories of documents and files

=head1 VERSION

version 0.030

=head1 DESCRIPTION

A Statocles::Store reads and writes L<documents|Statocles::Document> and
files (mostly L<pages|Statocles::Page>).

This class handles the parsing and inflating of
L<"document objects"|Statocles::Document>.

=head1 SEE ALSO

=over 4

=item L<Statocles::Store::File> - A store for plain files

=back

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

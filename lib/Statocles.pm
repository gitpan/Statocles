package Statocles;
# ABSTRACT: A static site generator
$Statocles::VERSION = '0.015';
# This module exists for both documentation and to help File::Share
# find the right share dir

1;

__END__

=pod

=head1 NAME

Statocles - A static site generator

=head1 VERSION

version 0.015

=head1 DESCRIPTION

Statocles is an application for building static web pages from a set of plain
YAML and Markdown files. It is designed to make it as simple as possible to
develop rich web content using basic text-based tools.

=head2 FEATURES

=over

=item *

A simple format combining YAML and Markdown for editing site content.

=item *

A command-line application for building, deploying, and editing the site.

=item *

A L<blogging application|Statocles::App::Blog#FEATURES> with

=over

=item *

RSS and Atom syndication feeds.

=item *

Tags to organize blog posts. Tags have their own custom feeds.

=item *

Crosspost links to direct users to a syndicated blog.

=item *

Post-dated blog posts to appear automatically when the date is passed.

=back

=item *

Customizable L<templates|Statocles::Template> using L<the Mojolicious template
language|Mojo::Template#SYNTAX>.

=item *

A clean default theme using L<Twitter Bootstrap|http://getbootstrap.com>.

=back

=head1 GUIDES

=head2 GETTING STARTED

To get started with your own Statocle site, see
L<the Statocles setup help in Statocles::Help::Setup|Statocles::Help::Setup>.

=head1 OVERVIEW

=head2 DOCUMENTS

A L<document|Statocles::Document> is the main content of the site. The user does
all the work with documents: adding, editing, and removing documents.

The default store reads documents in a combined YAML and Markdown format,
easily editable with any text editor. A sample document looks like:

    ---
    title: This is a title
    author: preaction
    ---
    # This is the markdown content

    This is a paragraph

This is the same format that L<Jekyll|http://jekyllrb.com> uses. The document
format is described in the L<Statocles::Store> documentation under
L<Frontmatter Document Format|Statocles::Store/"Frontmatter Document Format">.

=head2 PAGES

A L<Statocles::Page> is rendered HTML ready to be sent to a user. Statocles
generates pages from the documents that the user provides. One document may
generate multiple pages, and pages may have multiple formats like HTML or RSS.

=over 4

=item L<Statocles::Page::Document>

This page renders a single document. This is used for the main page of a blog
post, for example.

=item L<Statocles::Page::List>

This page renders a list of other pages (not documents). This is used for index
pages.

=item L<Statocles::Page::Feed>

This page renders an alternate version of a list page, like an RSS or Atom feed.

=back

=head1 APPLICATIONS

An application is the module that will take the documents the user provides and
turn them into the pages that can be written out to the filesystem.

=over 4

=item L<Statocles::App::Blog>

A simple blogging application.

=back

=head1 SITES

A L<Statocles::Site> manages a bunch of applications, writing and deploying the
resulting pages.

Deploying the site may involve a simple file copy, but it could also involve a
Git repository, an FTP site, or a database.

=over 4

=item L<Statocles::Site::Git>

A simple Git repository site.

=back

=head1 STORES

A L<Statocles::Store> reads and writes documents and pages. The default store
reads documents in YAML and writes pages to a file, but stores could read
documents as JSON, or from a Mongo database, and write pages to a database, or
whereever you want!

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

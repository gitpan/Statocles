package Statocles::Theme;
{
  $Statocles::Theme::VERSION = '0.001';
}
# ABSTRACT: Templates, headers, footers, and navigation

use Statocles::Class;
use File::Find qw( find );
use File::Slurp qw( read_file );


has source_dir => (
    is => 'ro',
    isa => Str,
);


has templates => (
    is => 'ro',
    isa => HashRef[HashRef[InstanceOf['Statocles::Template']]],
    lazy => 1,
    builder => 'read',
);


sub read {
    my ( $self ) = @_;
    my %tmpl;
    find(
        sub {
            if ( /[.]tmpl$/ ) {
                my ( $vol, $dirs, $name ) = splitpath( $File::Find::name );
                $name =~ s/[.]tmpl$//;
                my @dirs = splitdir( $dirs );
                # $dirs will end with a slash, so the last item in @dirs is ''
                my $group = $dirs[-2];
                $tmpl{ $group }{ $name } = Statocles::Template->new(
                    path => $File::Find::name,
                );
            }
        },
        $self->source_dir,
    );
    return \%tmpl;
}


sub template {
    my ( $self, $app, $template ) = @_;
    return $self->templates->{ $app }{ $template };
}

1;

__END__

=pod

=head1 NAME

Statocles::Theme - Templates, headers, footers, and navigation

=head1 VERSION

version 0.001

=head1 SYNOPSIS

    # Template directory layout
    /theme/site/layout.tmpl
    /theme/blog/index.tmpl
    /theme/blog/post.tmpl

    my $theme      = Statocles::Theme->new( path => '/theme' );
    my $layout     = $theme->template( site => 'layout' );
    my $blog_index = $theme->template( blog => 'index' );
    my $blog_post  = $theme->template( blog => 'post' );

=head1 DESCRIPTION

A Theme contains all the templates that applications need.

When the C<source_dir> is read, the templates inside are organized based on
their name and their parent directory.

=head1 ATTRIBUTES

=head2 source_dir

The source directory for this theme.

=head2 templates

The template objects for this theme.

=head1 METHODS

=head2 read()

Read the C<source_dir> and create the Statocles::Template objects inside.

=head2 template( $section => $name )

Get the template from the given C<section> with the given C<name>.

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

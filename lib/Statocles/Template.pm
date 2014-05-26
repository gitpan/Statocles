package Statocles::Template;
{
  $Statocles::Template::VERSION = '0.005';
}
# ABSTRACT: A template object to pass around

use Statocles::Class;
use Mojo::Template;
use File::Slurp qw( read_file );


has content => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    default => sub {
        my ( $self ) = @_;
        return scalar read_file( $self->path );
    },
);


has path => (
    is => 'ro',
    isa => Str,
);


around BUILDARGS => sub {
    my ( $orig, $self, @args ) = @_;
    my $args = $self->$orig( @args );
    if ( !$args->{path} ) {
        my ( $i, $caller_class ) = ( 0, (caller 0)[0] );
        while ( $caller_class->isa( 'Statocles::Template' )
            || $caller_class->isa( 'Sub::Quote' )
            || $caller_class->isa( 'Method::Generate::Constructor' )
        ) {
            #; print "Class: $caller_class\n";
            $i++;
            $caller_class = (caller $i)[0];
        }
        #; print "Class: $caller_class\n";
        $args->{path} = join " line ", (caller($i))[1,2];
    }
    return $args;
};


sub render {
    my ( $self, %args ) = @_;
    my $t = Mojo::Template->new(
        name => $self->path,
    );
    $t->prepend( $self->_vars( keys %args ) );
    return $t->render( $self->content, \%args );
}

# Build the Perl string that will unpack the passed-in args
# This is how Mojolicious::Plugin::EPRenderer does it, but I'm probably
# doing something wrong here...
sub _vars {
    my ( $self, @vars ) = @_;
    return join " ", 'my $vars = shift;', map { "my \$$_ = \$vars->{'$_'};" } @vars;
}

1;

__END__

=pod

=head1 NAME

Statocles::Template - A template object to pass around

=head1 VERSION

version 0.005

=head1 DESCRIPTION

This is the template abstraction layer for Statocles.

=head1 ATTRIBUTES

=head2 content

The main template string. This will be generated by reading the file C<path> by
default.

=head2 path

The path to the file for this template. Optional.

=head1 METHODS

=head2 BUILDARGS( )

Set the default path to something useful for in-memory templates.

=head2 render( %args )

Render this template, passing in %args. Each key in %args will be available as
a scalar in the template.

=head1 TEMPLATE LANGUAGE

The default Statocles template language is Mojolicious's Embedded Perl template. Inside the template, every key of the %args passed to render() will be available as a simple scalar:

    # template.tmpl
    % for my $p ( @$pages ) {
    <%= $p->{content} %>
    % }

    my $tmpl = Statocles::Template->new( path => 'template.tmpl' );
    $tmpl->render(
        pages => [
            { content => 'foo' },
            { content => 'bar' },
        ]
    );

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

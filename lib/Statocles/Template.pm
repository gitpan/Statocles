package Statocles::Template;
# ABSTRACT: A template object to pass around
$Statocles::Template::VERSION = '0.023';
use Statocles::Class;
use Statocles::Store;
use Mojo::Template;
use Scalar::Util qw( blessed );


has content => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    default => sub {
        my ( $self ) = @_;
        return Path::Tiny->new( $self->path )->slurp;
    },
);


has path => (
    is => 'ro',
    isa => Str,
    coerce => sub {
        return "$_[0]"; # Force stringify in case of Path::Tiny objects
    },
);


has store => (
    is => 'ro',
    isa => InstanceOf['Statocles::Store'],
    predicate => 'has_store',
    coerce => Statocles::Store->coercion,
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
    $t->prepend( $self->_prelude( '_tmpl', keys %args ) );

    my $content;
    {
        # Add the helper subs, like Mojolicious::Plugin::EPRenderer does
        no strict 'refs';
        no warnings 'redefine';
        local *{"@{[$t->namespace]}::include"} = sub {
            $self->_include( \%args, @_ );
        };
        $content = $t->render( $self->content, \%args );
    }

    if ( blessed $content && $content->isa( 'Mojo::Exception' ) ) {
        die "Error in template: " . $content;
    }
    return $content;
}

# Build the Perl string that will unpack the passed-in args
# This is how Mojolicious::Plugin::EPRenderer does it, but I'm probably
# doing something wrong here...
sub _prelude {
    my ( $self, @vars ) = @_;
    return join " ",
        'use strict; use warnings;',
        'my $vars = shift;',
        map( { "my \$$_ = \$vars->{'$_'};" } @vars ),
        ;
}


# Find and include the given file. If it's a template, give it the given vars
sub _include {
    my ( $self, $vars, $name ) = @_;
    if ( !$self->has_store ) {
        die qq{Can not include: No store!};
    }

    my $store = $self->store;
    if ( $store->has_file( "$name.ep" ) ) {
        my $inner_tmpl = __PACKAGE__->new(
            path => "$name.ep",
            content => $store->read_file( "$name.ep" ),
            store => $store,
        );
        return $inner_tmpl->render( %$vars );
    }
    elsif ( $store->has_file( $name ) ) {
        return $store->read_file( $name );
    }

    die qq{Can not find include "$name" in store "$store"};
}


sub coercion {
    my ( $class ) = @_;
    return sub {
        die "Template is undef" unless defined $_[0];
        return !ref $_[0]
            ? Statocles::Template->new( content => $_[0] )
            : $_[0]
            ;
    };
}

1;

__END__

=pod

=head1 NAME

Statocles::Template - A template object to pass around

=head1 VERSION

version 0.023

=head1 DESCRIPTION

This is the template abstraction layer for Statocles.

=head1 ATTRIBUTES

=head2 content

The main template string. This will be generated by reading the file C<path> by
default.

=head2 path

The path to the file for this template. Optional.

=head2 store

A store to use for includes. Optional.

=head1 METHODS

=head2 BUILDARGS( )

Set the default path to something useful for in-memory templates.

=head2 render( %args )

Render this template, passing in %args. Each key in %args will be available as
a scalar in the template.

=head2 coercion

A class method to returns a coercion sub to convert strings into template
objects.

=head1 TEMPLATE LANGUAGE

The default Statocles template language is Mojolicious's Embedded Perl
template. Inside the template, every key of the %args passed to render() will
be available as a simple scalar:

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

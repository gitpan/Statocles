package Statocles::Site::Git;
# ABSTRACT: A git-based site
$Statocles::Site::Git::VERSION = '0.012';
use Statocles::Class;
extends 'Statocles::Site';

use File::Copy::Recursive qw( dircopy );
use Git::Repository;


has deploy_branch => (
    is => 'ro',
    isa => Str,
    default => sub { 'master' },
);


sub deploy {
    my ( $self ) = @_;

    my $build_dir = $self->build_store->path;
    my $deploy_dir = $self->deploy_store->path;

    my $git = Git::Repository->new( work_tree => "$deploy_dir" );

    my $current_branch = _current_branch( $git );

    $self->write( $self->build_store );
    my @files;
    my $iter = $build_dir->iterator( { recurse => 1, follow_symlinks => 1 } );
    while ( my $path = $iter->() ) {
        if ( $path->is_file ) {
            my $name = "$path";
            $name =~ s/\Q$build_dir/$deploy_dir/;
            # Git versions before 1.7.4.1 require a relative path to 'git add'
            my $deploy_path = Path::Tiny->new( $name );
            push @files, $deploy_path->relative( $deploy_dir )->stringify;
        }
    };

    if ( !_has_branch( $git, $self->deploy_branch ) ) {
        _git_run( $git, checkout => -b => $self->deploy_branch );
    }
    else {
        _git_run( $git, checkout => $self->deploy_branch );
    }

    dircopy( "$build_dir", "$deploy_dir" );
    _git_run( $git, add => @files );
    _git_run( $git, commit => -m => 'Site update' );

    if ( _has_remote( $git, 'origin' ) ) {
        _git_run( $git, push => origin => $self->deploy_branch );
    }

    _git_run( $git, checkout => $current_branch );

    return;
}

sub _git_run {
    my ( $git, @args ) = @_;
    my $cmdline = join " ", 'git', @args;
    my $cmd = $git->command( @args );
    my $stdout = readline( $cmd->stdout ) // '';
    my $stderr = readline( $cmd->stderr ) // '';
    $cmd->close;
    my $exit = $cmd->exit;
    if ( $exit ) {
        warn "git $args[0] exited with $exit\n-- CMD --\n$cmdline\n-- STDOUT --\n$stdout\n-- STDERR --\n$stderr\n";
    }
    return $cmd->exit;
}

sub _current_branch {
    my ( $git ) = @_;
    my @branches = map { s/^\*\s+//; $_ } grep { /^\*/ } $git->run( 'branch' );
    return $branches[0];
}

sub _has_branch {
    my ( $git, $branch ) = @_;
    return !!grep { $_ eq $branch } map { s/^[\*\s]\s+//; $_ } $git->run( 'branch' );
}

sub _has_remote {
    my ( $git, $remote ) = @_;
    return !!grep { $_ eq $remote } map { s/^[\*\s]\s+//; $_ } $git->run( 'remote' );
}

1;

__END__

=pod

=head1 NAME

Statocles::Site::Git - A git-based site

=head1 VERSION

version 0.012

=head1 DESCRIPTION

This site deploys to a Git repository.

=head1 ATTRIBUTES

=head2 deploy_branch

The Git branch to deploy to.

=head1 METHODS

=head2 deploy()

Deploy the site.

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

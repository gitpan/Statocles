package Statocles::Site::Git;
{
  $Statocles::Site::Git::VERSION = '0.003';
}

use Statocles::Class;
extends 'Statocles::Site';

use File::Find qw( find );
use File::Copy::Recursive qw( dircopy );
use Git::Repository;

=attr deploy_dir

The directory of the Git repository to deploy to.

=cut

has deploy_dir => (
    is => 'ro',
    isa => Str,
    default => '.',
);

=attr deploy_branch

The Git branch to deploy to.

=cut

has deploy_branch => (
    is => 'ro',
    isa => Str,
    default => 'master',
);

=method deploy()

Deploy the site.

=cut

sub deploy {
    my ( $self ) = @_;

    my $build_dir = $self->build_store->path;
    my $deploy_dir = $self->deploy_store->path;

    my $git = Git::Repository->new( work_tree => $deploy_dir );

    my $current_branch = _current_branch( $git );

    $self->write( $self->build_store );
    my @files;
    find( sub {
        if ( -f ) {
            my $name = $File::Find::name;
            $name =~ s/$build_dir/$deploy_dir/;
            push @files, $name;
        }
    }, $build_dir );

    if ( !_has_branch( $git, $self->deploy_branch ) ) {
        _git_run( $git, checkout => -b => $self->deploy_branch );
    }
    else {
        _git_run( $git, checkout => $self->deploy_branch );
    }

    dircopy( $build_dir, $deploy_dir );
    _git_run( $git, add => @files );
    _git_run( $git, commit => -m => 'Site update' );
    _git_run( $git, checkout => $current_branch );

    return;
}

sub _git_run {
    my ( $git, @args ) = @_;
    my $cmd = $git->command( @args );
    my $stdout = readline $cmd->stdout;
    my $stderr = readline $cmd->stderr;
    $cmd->close;
    if ( my $exit = $cmd->exit ) {
        warn "git $args[0] exited with $exit\n-- STDOUT --\n$stdout\n-- STDERR --\n$stderr\n";
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

1;
__END__

=head1 DESCRIPTION

This site deploys to a Git repository.


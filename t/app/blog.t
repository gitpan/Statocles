
use Statocles::Test;
use Capture::Tiny qw( capture );
use File::Spec::Functions qw( splitdir );
use Statocles::Theme;
use Statocles::Store;
use Statocles::App::Blog;
use Statocles::Template;
my $SHARE_DIR = path( __DIR__ )->parent->child( 'share' );

my $theme = Statocles::Theme->new(
    templates => {
        site => {
            layout => Statocles::Template->new(
                content => 'HEAD <%= $content %> FOOT',
            ),
        },
        blog => {
            index => Statocles::Template->new(
                content => <<'ENDTEMPLATE'
% for my $page ( @$pages ) {
<% $page->{title} %> <% $page->{author} %> <% $page->{content} %>
% }
ENDTEMPLATE
            ),
            post => Statocles::Template->new(
                content => '<%= $title %> <%= $author %> <%= $content %>',
            ),
        },
    },
);

my $md = Text::Markdown->new;
my $tmpdir = tempdir;

my $app = Statocles::App::Blog->new(
    source => Statocles::Store->new( path => $SHARE_DIR->child( 'blog' ) ),
    url_root => '/blog',
    theme => $theme,
);

my @got_pages = $app->pages;

subtest 'blog post pages' => sub {
    my @doc_paths;
    my $iter = $app->source->path->iterator({ recurse => 1, follow_symlinks => 1 });
    while ( my $path = $iter->() ) {
        next unless $path->is_file;
        my $rel_path = $path->relative( $app->source->path );
        my @dir_parts = splitdir( $rel_path->parent->stringify );
        push @doc_paths, [ @dir_parts, $rel_path->basename ];
    }

    my @pages;
    for my $doc_path ( @doc_paths ) {
        my $doc = Statocles::Document->new(
            path => rootdir->child( @$doc_path ),
            %{ $app->source->read_document( $SHARE_DIR->child( 'blog', @$doc_path ) ) },
        );

        my $page_path = join '/', '', 'blog', @$doc_path;
        $page_path =~ s/[.]yml$/.html/;

        my $page = Statocles::Page::Document->new(
            template => $theme->template( blog => 'post' ),
            layout => $theme->template( site => 'layout' ),
            path => $page_path,
            document => $doc,
        );

        push @pages, $page;
    }

    cmp_deeply
        [ $app->post_pages ],
        bag( @pages )
            or diag explain [ $app->post_pages ], \@pages;
};

subtest 'index page' => sub {
    my $page = Statocles::Page::List->new(
        path => '/blog/index.html',
        template => $theme->template( blog => 'index' ),
        layout => $theme->template( site => 'layout' ),
        # Sorting by path just happens to also sort by date
        pages => [ sort { $b->path cmp $a->path } $app->post_pages ],
    );

    cmp_deeply $app->index, $page;
};

subtest 'commands' => sub {
    # We need an app we can edit
    my $tmpdir = tempdir;
    my $app = Statocles::App::Blog->new(
        source => Statocles::Store->new( path => $tmpdir->child( 'blog' ) ),
        url_root => '/blog',
        theme => $theme,
    );

    subtest 'help' => sub {
        my @args = qw( blog help );
        my ( $out, $err, $exit ) = capture { $app->command( @args ) };
        ok !$err, 'blog help is on stdout';
        is $exit, 0;
        like $out, qr{blog post <title> -- Create a new blog post},
            'contains blog help information';
    };

    subtest 'post' => sub {
        subtest 'create new post' => sub {
            local $ENV{EDITOR}; # We can't very well open vim...
            my ( undef, undef, undef, $day, $mon, $year ) = localtime;
            my $doc_path = $tmpdir->child(
                'blog',
                sprintf( '%04i', $year + 1900 ),
                sprintf( '%02i', $mon + 1 ),
                sprintf( '%02i', $day ),
                'this-is-a-title.yml',
            );

            subtest 'run the command' => sub {
                my @args = qw( blog post This is a Title );
                my ( $out, $err, $exit ) = capture { $app->command( @args ) };
                ok !$err, 'nothing on stdout';
                is $exit, 0;
                like $out, qr{New post at: \Q$doc_path},
                    'contains blog post document path';
            };

            subtest 'check the generated document' => sub {
                my $doc = $app->source->read_document( $doc_path );
                cmp_deeply $doc, {
                    title => 'This is a Title',
                    author => '',
                    content => <<'ENDMARKDOWN',
Markdown content goes here.
ENDMARKDOWN
                };
                eq_or_diff $doc_path->slurp, <<'ENDCONTENT';
---
author: ''
title: This is a Title
---
Markdown content goes here.
ENDCONTENT
            };
        };
    };
};

done_testing;

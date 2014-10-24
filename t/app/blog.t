
use Statocles::Test;
use Capture::Tiny qw( capture );
use File::Spec::Functions qw( splitdir );
use Statocles::Theme;
use Statocles::Store;
use Statocles::App::Blog;
use Statocles::Template;
my $SHARE_DIR = path( __DIR__ )->parent->child( 'share' );

my $theme = Statocles::Theme->new(
    source_dir => $SHARE_DIR->child( 'theme' ),
);

my $md = Text::Markdown->new;
my $tmpdir = tempdir;

my $app = Statocles::App::Blog->new(
    source => Statocles::Store->new( path => $SHARE_DIR->child( 'blog' ) ),
    url_root => '/blog',
    theme => $theme,
    page_size => 2,
);

my @all_pages;

sub docs {
    my ( $root_path ) = @_;
    my @doc_specs;

    my $iter = $root_path->iterator({ recurse => 1, follow_symlinks => 1 });
    while ( my $path = $iter->() ) {
        next unless $path->is_file;
        next unless $path =~ /[.]yml$/;
        next if $path =~ m{\b9999\b}; # It will never be 9999

        my $rel_path = $path->relative( $root_path );
        my @doc_path = ( splitdir( $rel_path->parent->stringify ), $rel_path->basename );

        # Must have YYYY/MM/DD in the front of the path
        next unless @doc_path > 3;
        next unless join( "", @doc_path[0..2] ) =~ /\d{8}/;

        my $doc = Statocles::Document->new(
            path => rootdir->child( @doc_path ),
            %{ $app->source->read_document( $SHARE_DIR->child( 'blog', @doc_path ) ) },
        );

        push @doc_specs, {
            path => \@doc_path,
            doc => $doc,
        };
    }

    return @doc_specs;
}

sub pages {
    my ( @doc_specs ) = @_;

    my @pages;
    for my $doc_spec ( @doc_specs ) {
        my $page_path = join '/', '', 'blog', @{ $doc_spec->{ path } };
        $page_path =~ s/[.]yml$/.html/;

        my $date = join '-', @{ $doc_spec->{ path } }[0..2];

        my $page = Statocles::Page::Document->new(
            app => $app,
            published => Time::Piece->strptime( $date, '%Y-%m-%d' ),
            template => $theme->template( blog => 'post.html' ),
            layout => $theme->template( site => 'layout.html' ),
            path => $page_path,
            document => $doc_spec->{ doc },
        );

        push @pages, $page;
    }
    return @pages;
}

# Sorting by path just happens to also sort by date
my @sorted_docs = sort { $b->{doc}->path cmp $a->{doc}->path } docs( $app->source->path );

subtest 'blog post pages' => sub {
    my @pages = pages( @sorted_docs );
    cmp_deeply
        [ $app->post_pages ],
        bag( @pages )
            or diag explain [ $app->post_pages ], \@pages;
    push @all_pages, @pages;
};

subtest 'tag pages' => sub {
    my %page_args = (
        app => $app,
        template => $theme->template( blog => 'index.html' ),
        layout => $theme->template( site => 'layout.html' ),
    );
    my %rss_args = (
        app => $app,
        type => 'application/rss+xml',
        template => $theme->template( blog => 'index.rss' ),
    );
    my %atom_args = (
        app => $app,
        type => 'application/atom+xml',
        template => $theme->template( blog => 'index.atom' ),
    );

    my @tag_pages = (
        Statocles::Page::List->new(
            %page_args,
            path => '/blog/tag/better/index.html',
            pages => [ pages( @sorted_docs[0,1] ) ],
            next => '/blog/tag/better/page-2.html',
        ),
        Statocles::Page::List->new(
            %page_args,
            path => '/blog/tag/better/page-2.html',
            pages => [ pages( $sorted_docs[2] ) ],
            prev => '/blog/tag/better/index.html',
        ),
        Statocles::Page::List->new(
            %page_args,
            path => '/blog/tag/error-message/index.html',
            pages => [ pages( $sorted_docs[1] ) ],
        ),
        Statocles::Page::List->new(
            %page_args,
            path => '/blog/tag/more/index.html',
            pages => [ pages( $sorted_docs[0] ) ],
        ),
        Statocles::Page::List->new(
            %page_args,
            path => '/blog/tag/even-more-tags/index.html',
            pages => [ pages( $sorted_docs[0] ) ],
        ),
    );

    my @feeds = (
        [
            Statocles::Page::Feed->new(
                %atom_args,
                path => '/blog/tag/better.atom',
                page => $tag_pages[0],
            ),
            Statocles::Page::Feed->new(
                %rss_args,
                path => '/blog/tag/better.rss',
                page => $tag_pages[0],
            ),
        ],
        [
            Statocles::Page::Feed->new(
                %atom_args,
                path => '/blog/tag/error-message.atom',
                page => $tag_pages[2],
            ),
            Statocles::Page::Feed->new(
                %rss_args,
                path => '/blog/tag/error-message.rss',
                page => $tag_pages[2],
            ),
        ],
        [
            Statocles::Page::Feed->new(
                %atom_args,
                path => '/blog/tag/more.atom',
                page => $tag_pages[3],
            ),
            Statocles::Page::Feed->new(
                %rss_args,
                path => '/blog/tag/more.rss',
                page => $tag_pages[3],
            ),
        ],
        [
            Statocles::Page::Feed->new(
                %atom_args,
                path => '/blog/tag/even-more-tags.atom',
                page => $tag_pages[4],
            ),
            Statocles::Page::Feed->new(
                %rss_args,
                path => '/blog/tag/even-more-tags.rss',
                page => $tag_pages[4],
            ),
        ],
    );

    # Add feed pages to the tag pages
    for my $list ( @tag_pages[0,1] ) {
        $list->links->{feed} = [
            map { { href => $_->path, type => $_->type, } } @{ $feeds[0] }
        ];
        $list->links->{feed}[0]{title} = 'Atom';
        $list->links->{feed}[1]{title} = 'RSS';
    }
    for my $i ( 2..$#tag_pages ) {
        my $list = $tag_pages[$i];
        $list->links->{feed} = [
            map { { href => $_->path, type => $_->type } } @{ $feeds[$i-1] }
        ];
        $list->links->{feed}[0]{title} = 'Atom';
        $list->links->{feed}[1]{title} = 'RSS';
    }

    push @tag_pages, map { @$_ } @feeds;
    cmp_deeply [ $app->tag_pages ], bag( @tag_pages );
    push @all_pages, @tag_pages;

    subtest 'tag navigation' => sub {
        cmp_deeply [ $app->tags ], [
            { title => 'better', href => '/blog/tag/better/index.html' },
            { title => 'error message', href => '/blog/tag/error-message/index.html' },
            { title => 'even more tags', href => '/blog/tag/even-more-tags/index.html' },
            { title => 'more', href => '/blog/tag/more/index.html' },
        ];
    };
};

subtest 'index page(s)' => sub {
    my %page_args = (
        app => $app,
        template => $theme->template( blog => 'index.html' ),
        layout => $theme->template( site => 'layout.html' ),
    );
    my %rss_args = (
        app => $app,
        type => 'application/rss+xml',
        template => $theme->template( blog => 'index.rss' ),
    );
    my %atom_args = (
        app => $app,
        type => 'application/atom+xml',
        template => $theme->template( blog => 'index.atom' ),
    );

    my @pages = (
        Statocles::Page::List->new(
            %page_args,
            path => '/blog/index.html',
            # Sorting by path just happens to also sort by date
            pages => [ pages( @sorted_docs[0,1] ) ],
            next => '/blog/page-2.html',
        ),
        Statocles::Page::List->new(
            %page_args,
            path => '/blog/page-2.html',
            # Sorting by path just happens to also sort by date
            pages => [ pages( @sorted_docs[2,3] ) ],
            prev => '/blog/index.html',
        ),
    );

    my @feeds = (
        Statocles::Page::Feed->new(
            %atom_args,
            path => '/blog/index.atom',
            page => $pages[0],
        ),
        Statocles::Page::Feed->new(
            %rss_args,
            path => '/blog/index.rss',
            page => $pages[0],
        ),
    );

    for my $page ( @pages ) {
        $page->links->{feed} = [
            { title => 'Atom', href => $feeds[0]->path, type => $feeds[0]->type },
            { title => 'RSS', href => $feeds[1]->path, type => $feeds[1]->type },
        ];
    }

    push @pages, @feeds;

    cmp_deeply [$app->index], bag( @pages );
    push @all_pages, @pages;
};

subtest 'all pages()' => sub {
    cmp_deeply [ $app->pages ], bag( @all_pages );
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
        like $out, qr{\Qblog post [--date YYYY-MM-DD] <title> -- Create a new blog post},
            'contains blog help information';
    };

    subtest 'post' => sub {
        subtest 'create new post' => sub {
            subtest 'without $EDITOR, title is required' => sub {
                local $ENV{EDITOR};
                my @args = qw( blog post );
                my ( $out, $err, $exit ) = capture { $app->command( @args ) };
                like $err, qr{Title is required when \$EDITOR is not set};
                like $err, qr{blog post <title>};
                isnt $exit, 0;
            };

            subtest 'default document' => sub {
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
                        author => undef,
                        tags => undef,
                        last_modified => isa( 'Time::Piece' ),
                        content => <<'ENDMARKDOWN',
Markdown content goes here.
ENDMARKDOWN
                    };
                    my $dt_str = $doc->{last_modified}->strftime( '%Y-%m-%d %H:%M:%S' );
                    eq_or_diff $doc_path->slurp, <<ENDCONTENT;
---
author: ~
last_modified: $dt_str
tags: ~
title: This is a Title
---
Markdown content goes here.
ENDCONTENT
                };
            };
            subtest 'custom date' => sub {
                local $ENV{EDITOR}; # We can't very well open vim...

                my $doc_path = $tmpdir->child(
                    'blog', '2014', '04', '01', 'this-is-a-title.yml',
                );

                subtest 'run the command' => sub {
                    my @args = qw( blog post --date 2014-4-1 This is a Title );
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
                        author => undef,
                        tags => undef,
                        last_modified => isa( 'Time::Piece' ),
                        content => <<'ENDMARKDOWN',
Markdown content goes here.
ENDMARKDOWN
                    };
                    my $dt_str = $doc->{last_modified}->strftime( '%Y-%m-%d %H:%M:%S' );
                    eq_or_diff $doc_path->slurp, <<ENDCONTENT;
---
author: ~
last_modified: $dt_str
tags: ~
title: This is a Title
---
Markdown content goes here.
ENDCONTENT
                };
            };
        };
    };
};

subtest 'cache pages' => sub {
    my ( $index1 ) = $app->index;
    my ( $index2 ) = $app->index;
    $index1->path( '/index.html' );
    is $index2->path, $index1->path;
};

done_testing;

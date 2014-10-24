
# Check the syntax of all the built-in theme bundles

use Statocles::Test;
$Statocles::VERSION = '0.000001';
use Statocles::Document;
use Statocles::Page::List;
use Statocles::Page::Document;
use Statocles::Page::Feed;
use Statocles::App::Blog;
use Statocles::Site;
use Statocles::Store;
use Statocles::Theme;

my $THEME_DIR = path( __DIR__, '..', '..', 'share', 'theme' );

my $store = Statocles::Store->new(
    path => 'DUMMY',
    documents => [
        Statocles::Document->new(
            path => 'DUMMY',
            title => 'Title One',
            author => 'preaction',
            content => 'Content One',
        ),
        Statocles::Document->new(
            path => 'DUMMY',
            title => 'Title Two',
            author => 'preaction',
            content => 'Content Two',
        ),
    ],
);

my $blog = Statocles::App::Blog->new(
    url_root => '/blog',
    store => $store,
    theme => Statocles::Theme->new( path => 'DUMMY' ),
);

my $site = Statocles::Site->new(
    base_url => 'http://example.com',
    build_store => $store,
    deploy_store => $store,
    title => 'Test Title',
    apps => {
        blog => $blog,
    },
);

my %page = (
    document => Statocles::Page::Document->new(
        path => 'document.html',
        document => $store->documents->[0],
        published => Time::Piece->new,
    ),
);

$page{ list } = Statocles::Page::List->new(
    app => $blog,
    path => 'list.html',
    pages => [ $page{ document } ],
    next => 'page-0.html',
    prev => 'page-1.html',
);

$page{ feed } = Statocles::Page::Feed->new(
    app => $blog,
    path => 'feed.rss',
    page => $page{ list },
);

my %common_vars = (
    site => $site,
    content => 'Fake content',
    app => $blog,
);

my %app_vars = (
    blog => {
        'index.html.ep' => {
            %common_vars,
            self => $page{ list },
            pages => [ $page{ document } ],
        },
        'index.rss.ep' => {
            %common_vars,
            self => $page{ feed },
            pages => [ $page{ document } ],
        },
        'index.atom.ep' => {
            %common_vars,
            self => $page{ feed },
            pages => [ $page{ document } ],
        },
        'post.html.ep' => {
            %common_vars,
            self => $page{ document },
            doc => $store->documents->[0],
        },
    },
    site => {
        'layout.html.ep' => {
            %common_vars,
            self => $page{ document },
            app => $blog,
        },
    },
);

my $iter = $THEME_DIR->iterator({ recurse => 1 });
while ( my $path = $iter->() ) {
    next unless $path->is_file;
    next unless $path->basename =~ /[.]ep$/;
    my $tmpl = Statocles::Template->new(
        path => $path,
    );
    my $name = $path->basename;
    my $app = $path->parent->basename;
    my %args = %{ $app_vars{ $app }{ $name } };
    lives_ok {
        $tmpl->render( %args );
    } join " - ", $app, $name;
}

done_testing;

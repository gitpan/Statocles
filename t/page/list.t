
use Statocles::Test;
use Statocles::Page::Document;
use Statocles::Document;
use Statocles::Page::List;

my @pages = (
    Statocles::Page::Document->new(
        path => '/blog/2014/04/30/page.html',
        document => Statocles::Document->new(
            path => '/2014/04/30/page.yml',
            title => 'Second post',
            author => 'preaction',
            content => 'Better body content',
        ),
    ),
    Statocles::Page::Document->new(
        path => '/blog/2014/04/23/slug.html',
        document => Statocles::Document->new(
            path => '/2014/04/23/slug.yml',
            title => 'First post',
            author => 'preaction',
            content => 'Body content',
        ),
    ),
);

subtest 'simple list (default templates)' => sub {
    my $list = Statocles::Page::List->new(
        path => '/blog/index.html',
        pages => \@pages,
    );

    my $html =  join( "\n",
                map {
                    join( " ", $_->document->title, $_->document->author, $_->content ),
                }
                @pages
            ) . "\n\n";

    eq_or_diff $list->render, $html;
};

subtest 'extra args' => sub {
    my $list = Statocles::Page::List->new(
        path => '/blog/index.html',
        pages => \@pages,
        layout => '<%= $site %> <%= $content %>',
        template => <<'ENDTEMPLATE',
<%= $site %>
% for my $page ( @$pages ) {
<%= $page->{title} %> <%= $page->{author} %> <%= $page->{content} %>
% }
ENDTEMPLATE
    );

    my $html    = "hello hello\n"
                . join( "\n",
                    map { join( " ", $_->document->title, $_->document->author, $_->content ), }
                    @pages
                ) . "\n\n";

    my $output = $list->render( site => 'hello', title => 'DOES NOT OVERRIDE' );
    eq_or_diff $output, $html;
};

done_testing;

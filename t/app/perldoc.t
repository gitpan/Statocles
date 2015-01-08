
use Statocles::Base 'Test';
use Statocles::Site;
use Statocles::App::Perldoc;
use Mojo::DOM;

my $SHARE_DIR = path( __DIR__ )->parent->child( 'share' );
my $site = Statocles::Site->new(
    title => 'Test site',
    build_store => '.',
    deploy_store => '.',
);

subtest 'constructor' => sub {

    my %required = (
        url_root => '/pod',
        theme => $SHARE_DIR->child( 'theme' ),
        modules => [qw( My )],
        index_module => 'My',
    );

    test_constructor(
        "Statocles::App::Perldoc",
        required => \%required,
        default => {
            inc => [ map { Path::Tiny->new( $_ ) } @INC ],
            weave => 0,
            weave_config => Path::Tiny->new( './weaver.ini' ),
        },
    );

    subtest 'attribute types/coercions' => sub {
        subtest 'inc' => sub {

            subtest 'all strings' => sub {
                my $app;
                lives_ok {
                    $app = Statocles::App::Perldoc->new(
                        %required,
                        inc => [ 'test', 'two' ],
                    )
                };

                cmp_deeply $app->inc, array_each( isa( 'Path::Tiny' ) );
                is $app->inc->[0]->stringify, "test";
                is $app->inc->[1]->stringify, "two";
            };

            subtest 'some strings / some paths' => sub {
                my $app;
                lives_ok {
                    $app = Statocles::App::Perldoc->new(
                        %required,
                        inc => [ 'test', Path::Tiny->new( 'two' ) ],
                    )
                };

                cmp_deeply $app->inc, array_each( isa( 'Path::Tiny' ) );
                is $app->inc->[0]->stringify, "test";
                is $app->inc->[1]->stringify, "two";
            };
        };

        subtest 'weave_config' => sub {
            subtest 'string' => sub {
                my $app;
                lives_ok {
                    $app = Statocles::App::Perldoc->new(
                        %required,
                        weave_config => 'foo',
                    );
                };

                isa_ok $app->weave_config, 'Path::Tiny';
                is $app->weave_config->stringify, 'foo';
            };
        };

    };
};

subtest 'perldoc pages' => sub {

    my @page_tests = (
        '/pod/index.html' => sub {
            my ( $html, $dom ) = @_;
            # XXX: Find the layout and template
            my $node;

            if ( ok $node = $dom->at( 'h1#NAME' ) ) {
                is $node->text, 'NAME';
            }

            if ( ok $node = $dom->at( 'h1#NAME + p' ) ) {
                is $node->text, 'My - A sample for my perldoc app';
            }

            if ( ok $node = $dom->at( 'h1#SYNOPSIS + pre code' ) ) {
                like $node->text, qr{my \$my = My->new};
            }

            ok $dom->at( 'a[href="/pod/My/Internal.html"]' ), 'internal link exists';
            ok $dom->at( 'a[href="https://metacpan.org/pod/External"]' ), 'external link exists';
        },

        '/pod/My/Internal.html' => sub {
            my ( $html, $dom ) = @_;
            # XXX: Find the layout and template
            my $node;

            if ( ok $node = $dom->at( 'h1#NAME' ) ) {
                is $node->text, 'NAME';
            }

            if ( ok $node = $dom->at( 'h1#NAME + p' ) ) {
                is $node->text, 'My::Internal - An internal module to link to';
            }

            if ( ok $node = $dom->at( 'h1#SYNOPSIS + pre code' ) ) {
                like $node->text, qr{my \$int = My::Internal->new};
            }

            ok $dom->at( 'a[href="/pod/index.html"]' ), 'internal link to index page';
        },

    );

    subtest 'without Pod::Weaver' => sub {
        my $app = Statocles::App::Perldoc->new(
            url_root => '/pod',
            inc => [ $SHARE_DIR->child( qw( app perldoc lib ) ) ],
            modules => [qw( My My:: )],
            index_module => 'My',
            theme => $SHARE_DIR->child( 'theme' ),
        );

        test_pages( $site, $app, @page_tests );
    };

    subtest 'with Pod::Weaver' => sub {

        if ( !eval { require Pod::Weaver; 1 } ) {
            subtest 'missing Pod::Weaver throws error' => sub {
                my $app = Statocles::App::Perldoc->new(
                    url_root => '/pod',
                    inc => [ $SHARE_DIR->child( qw( app perldoc lib-weaver ) ) ],
                    modules => [qw( My My:: )],
                    index_module => 'My',
                    theme => $SHARE_DIR->child( 'theme' ),
                    weave => 1,
                    weave_config => $SHARE_DIR->child( qw( app perldoc weaver.ini ) ),
                );
                dies_ok { $app->pages };
            };
            return;
        }

        my $app = Statocles::App::Perldoc->new(
            url_root => '/pod',
            inc => [ $SHARE_DIR->child( qw( app perldoc lib-weaver ) ) ],
            modules => [qw( My My:: )],
            index_module => 'My',
            theme => $SHARE_DIR->child( 'theme' ),
            weave => 1,
            weave_config => $SHARE_DIR->child( qw( app perldoc weaver.ini ) ),
        );

        test_pages( $site, $app, @page_tests );
    };
};

done_testing;

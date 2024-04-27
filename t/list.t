
=head1 DESCRIPTION

This tests the list component

=cut

use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojolicious;

subtest 'Bootstrap4' => \&test_list,
    'Bootstrap4',
    wrapper_elem => 'div.list-group',
    ;

# subtest 'Bulma' => \&test_list,
#     'Bulma',
#     wrapper_elem => 'div',
#     ;

done_testing;

sub test_list {
    my ( $lib, %attr ) = @_;
    my ( @items, @columns );
    my $app = Mojolicious->new;
    $app->plugin( Moai => [ $lib ] );
    $app->routes->get( '/user/:id' )->name( 'user.profile' );
    $app->routes->get( '/' )->to( cb => sub {
        my ( $c ) = @_;
        $c->stash(
            items => \@items,
            column => 'name',
        );
        $c->render( 'moai/list' );
    } );
    $app->routes->get( '/linked' )->to( cb => sub {
        my ( $c ) = @_;
        $c->stash(
            items => \@items,
            column => 'name',
            link_to => 'user.profile',
        );
        $c->render( 'moai/list' );
    } );
    my $t = Test::Mojo->new( $app );

    @items = (
        { id => 1, name => 'Doug' },
        { id => 2, name => 'Jeff' },
        { id => 3, name => 'Katie' },
    );

    $t->get_ok( '/' )
      ->element_exists( $attr{ wrapper_elem }, 'list exists' )
      ->text_like( "$attr{ wrapper_elem } :nth-child(1)", qr/$items[0]{name}/, 'first item is correct' )
      ->text_like( "$attr{ wrapper_elem } :nth-child(2)", qr/$items[1]{name}/, 'second item is correct' )
      ->text_like( "$attr{ wrapper_elem } :nth-child(3)", qr/$items[2]{name}/, 'third item is correct' )
      ;

    $t->get_ok( '/linked' )
      ->element_exists( $attr{ wrapper_elem }, 'list exists' )
      ->text_like( "$attr{ wrapper_elem } a:nth-child(1)", qr/$items[0]{name}/, 'first item is correct' )
      ->attr_like( "$attr{ wrapper_elem } a:nth-child(1)", 'href', qr{/user/$items[0]{id}}, 'first item href is correct' )
      ->text_like( "$attr{ wrapper_elem } a:nth-child(2)", qr/$items[1]{name}/, 'second item is correct' )
      ->attr_like( "$attr{ wrapper_elem } a:nth-child(2)", 'href', qr{/user/$items[1]{id}}, 'second item href is correct' )
      ->text_like( "$attr{ wrapper_elem } a:nth-child(3)", qr/$items[2]{name}/, 'third item is correct' )
      ->attr_like( "$attr{ wrapper_elem } a:nth-child(3)", 'href', qr{/user/$items[2]{id}}, 'third item href is correct' )
      ;
}

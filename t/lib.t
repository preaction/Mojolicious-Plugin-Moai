
=head1 DESCRIPTION

This tests the CDN components

=cut

use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojolicious;

my $app = Mojolicious->new;
$app->plugin( Moai => [ 'Bootstrap4' ] );
$app->routes->get( '/*template' )->to( cb => sub {
    my ( $c ) = @_;
    $c->stash( map { $_ => $c->param( $_ ) } @{ $c->req->params->names } );
    $c->render;
} );
my $t = Test::Mojo->new( $app );

$t->get_ok( '/moai/lib/stylesheet', form => { version => '4.0.1' } )
  ->status_is( 200 )
  ->or( sub { diag 'Error: ', shift->tx->res->dom->at( '#error,#routes' ) } )
  ->element_exists( 'link[rel=stylesheet]', 'stylesheet exists' )
  ->element_exists( 'link[href^=//]', 'no protocol in front of the link' )
  ->or( sub { diag shift->tx->res->dom->find( 'link' )->map( 'to_string' )->each } )
  ->element_exists( 'link[href$=/bootstrap.min.css]', 'use minified bootstrap' )
  ->element_exists( 'link[href*=4.0.1]', 'version is in URL' )

  ->get_ok( '/moai/lib/javascript', form => { version => '4.0.1' } )
  ->element_exists( 'script', 'at least one script exists' )
  ->element_exists_not( 'script[src^=http]', 'no protocol in front of the src' )
  ->element_exists( 'script[src*=/jquery-]', 'jquery is loaded' )
  ->element_exists( 'script[src$=/popper.min.js]', 'popper is loaded' )
  ->element_exists( 'script[src$=/bootstrap.bundle.min.js]', 'bootstrap bundle is loaded' )
  ->element_exists( 'script[src*=/4.0.1/]', 'version is in URL' )

  ->get_ok( '/moai/lib', form => { version => '4.0.1' } )
  ->element_exists( 'link[rel=stylesheet]', 'stylesheet exists' )
  ->element_exists( 'link[href^=//]', 'no protocol in front of the link' )
  ->element_exists( 'link[href$=/bootstrap.min.css]', 'use minified bootstrap' )
  ->element_exists( 'link[href*=4.0.1]', 'version is in URL' )
  ->element_exists( 'script', 'at least one script exists' )
  ->element_exists_not( 'script[src^=http]', 'no protocol in front of the src' )
  ->element_exists( 'script[src*=/jquery-]', 'jquery is loaded' )
  ->element_exists( 'script[src$=/popper.min.js]', 'popper is loaded' )
  ->element_exists( 'script[src$=/bootstrap.bundle.min.js]', 'bootstrap bundle is loaded' )
  ->element_exists( 'script[src*=/4.0.1/]', 'version is in URL' )
  ;


done_testing;

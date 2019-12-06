
=head1 DESCRIPTION

This tests the pager components

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

$t->get_ok( '/moai/pager?id=mypager', form => { current_page => 3, total_pages => 5 } )
  ->status_is( 200 )
  ->or( sub { diag 'Error: ', shift->tx->res->dom->at( '#error,#routes' ) } )
  ->element_exists( 'ul.pagination', 'pagination ul exists' )
  ->element_exists( 'ul#mypager', 'pagination id is correct' )
  ->element_exists(
    'li:nth-child(1) a[href^=/moai/pager][href*=page=2]',
    'previous link exists and href is correct',
  )
  ->or( sub { diag shift->tx->res->dom->at( 'li:nth-child(1) :first-child' ) } )
  ->text_like( 'li:nth-child(1) a', qr{^\s*Previous\s*$}, 'previous link text correct' )
  ->element_exists(
    'li:nth-child(7) a[href^=/moai/pager][href*="page=4"]',
    'next link exists and href is correct',
  )
  ->or( sub { diag shift->tx->res->dom->at( 'li:nth-child(7) :first-child' ) } )
  ->text_like( 'li:nth-child(7) a', qr{^\s*Next\s*$}, 'next link text correct' )
  ->element_exists(
    'li:nth-child(2) a[href^=/moai/pager][href*="page=1"]',
    '1st page link exists and href is correct',
  )
  ->or( sub { diag shift->tx->res->dom->at( 'li:nth-child(2) :first-child' ) } )
  ->text_like( 'li:nth-child(2) a', qr{^\s*1\s*$}, '1st page link text correct' )
  ->element_exists(
    'li:nth-child(4).active > span',
    '3rd page (current) is disabled',
  )
  ->or( sub { diag shift->tx->res->dom->at( 'li:nth-child(4) :first-child' ) } )
  ->text_like( 'li:nth-child(4) > span', qr{^\s*3\s*$}, '3rd page link text correct' )

  ->get_ok( '/moai/pager', form => { current_page => 1, total_pages => 5 } )
  ->status_is( 200 )
  ->or( sub { diag 'Error: ', shift->tx->res->dom->at( '#error,#routes' ) } )
  ->element_exists(
    'li:nth-child(1) > span',
    'previous link is disabled',
  )
  ->or( sub { diag shift->tx->res->dom->at( 'li:nth-child(1) :first-child' ) } )
  ->text_like( 'li:nth-child(1) > span', qr{^\s*Previous\s*$}, 'previous link text correct' )

  ->get_ok( '/moai/pager', form => { current_page => 5, total_pages => 5 } )
  ->status_is( 200 )
  ->or( sub { diag 'Error: ', shift->tx->res->dom->at( '#error,#routes' ) } )
  ->element_exists(
    'li:nth-child(7) > span',
    'next link is disabled',
  )
  ->or( sub { diag shift->tx->res->dom->at( 'li:nth-child(7) :first-child' ) } )
  ->text_like( 'li:nth-child(7) > span', qr{^\s*Next\s*$}, 'next link text correct' )
  ;

$t->get_ok( '/moai/pager/mini?id=mypager', form => { current_page => 3, total_pages => 5 } )
  ->status_is( 200 )
  ->or( sub { diag 'Error: ', shift->tx->res->dom->at( '#error,#routes' ) } )
  ->element_exists( 'ul.pagination', 'pagination ul exists' )
  ->element_exists( 'ul#mypager', 'pagination id is correct' )
  ->element_exists(
    'li:nth-child(1) a[href^=/moai/pager][href*=page=2]',
    'previous link exists and href is correct',
  )
  ->or( sub { diag shift->tx->res->dom->at( 'li:nth-child(1) :first-child' ) } )
  ->text_like( 'li:nth-child(1) a', qr{^\s*Previous\s*$}, 'previous link text correct' )
  ->element_exists(
    'li:nth-child(2) a[href^=/moai/pager][href*="page=4"]',
    'next link exists and href is correct',
  )
  ->or( sub { diag shift->tx->res->dom->at( 'li:nth-child(2) :first-child' ) } )
  ->text_like( 'li:nth-child(2) a', qr{^\s*Next\s*$}, 'next link text correct' )
  ;

done_testing;

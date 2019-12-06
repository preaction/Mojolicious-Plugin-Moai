
=head1 DESCRIPTION

This tests the table component

=cut

use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojolicious;

my ( @items, @columns );
my $app = Mojolicious->new;
$app->plugin( Moai => [ 'Bootstrap4' ] );
$app->routes->get( '/user/:id' )->name( 'user.profile' );
$app->routes->get( '/' )->to( cb => sub {
    my ( $c ) = @_;
    $c->stash(
        items => \@items,
        columns => \@columns,
        class => { map { split /:/, $_ } @{ $c->every_param( 'class' ) || [] } },
        ( map { $_ => $c->param( $_ ) } qw( id ) ),
    );
    $c->render( 'moai/table' );
} );
my $t = Test::Mojo->new( $app );

@items = (
    { id => 1, name => 'Doug' },
    { id => 2, name => 'Jeff' },
    { id => 3, name => 'Katie' },
);
@columns = (
    { key => 'id', title => 'ID', class => { col => 'text-center' } },
    { key => 'name', title => 'Name', link_to => 'user.profile' },
);

$t->get_ok( '/', form => { class => [ 'table:table-striped' ], id => 'mytable' } )
  ->element_exists( 'table.table', 'table exists' )
  ->element_exists( 'table#mytable', 'table id is correct' )
  ->element_exists( 'table.table-striped', 'table-striped class added to table' )
  ->element_exists( 'thead', 'thead exists' )
  ->element_exists( 'thead tr:only-child', 'one thead row exists' )
  ->text_like( 'thead tr:nth-child(1) th:nth-child(1)', qr{^\s*$columns[0]{title}\s*$}, 'first column title' )
  ->element_exists(
      'thead tr:nth-child(1) th:nth-child(1).text-center',
      'first column title has text-center class',
  )
  ->text_like( 'thead tr:nth-child(1) th:nth-child(2)', qr{^\s*$columns[1]{title}\s*$}, 'second column title' )
  ->element_exists( 'tbody', 'tbody exists' )
  ->element_exists( 'tbody tr:nth-child(1)', 'first tbody row exists' )
  ->text_like(
      'tbody tr:nth-child(1) td:nth-child(1)', qr{^\s*$items[0]{id}\s*$},
      'first row first column data',
  )
  ->element_exists(
      'tbody tr:nth-child(1) td:nth-child(1).text-center',
      'first row first column has text-center class',
  )
  ->text_like(
      'tbody tr:nth-child(1) td:nth-child(2) > :first-child', qr{^\s*$items[0]{name}\s*$},
      'first row second column data',
  )
  ->element_exists(
      'tbody tr:nth-child(1) td:nth-child(2) a[href=/user/1]',
      'first row second column has correct link',
  )
  ->element_exists( 'tbody tr:nth-child(2)', 'second tbody row exists' )
  ->text_like(
      'tbody tr:nth-child(2) td:nth-child(1)', qr{^\s*$items[1]{id}\s*$},
      'second row first column data',
  )
  ->element_exists(
      'tbody tr:nth-child(2) td:nth-child(1).text-center',
      'second row first column has text-center class',
  )
  ->text_like(
      'tbody tr:nth-child(2) td:nth-child(2) > :first-child', qr{^\s*$items[1]{name}\s*$},
      'second row second column data',
  )
  ->element_exists(
      'tbody tr:nth-child(2) td:nth-child(2) a[href=/user/2]',
      'second row second column has correct link',
  )
  ->element_exists( 'tbody tr:nth-child(3)', 'third tbody row exists' )
  ->text_like(
      'tbody tr:nth-child(3) td:nth-child(1)', qr{^\s*$items[2]{id}\s*$},
      'third row first column data',
  )
  ->element_exists(
      'tbody tr:nth-child(3) td:nth-child(1).text-center',
      'third row first column has text-center class',
  )
  ->text_like(
      'tbody tr:nth-child(3) td:nth-child(2) > :first-child', qr{^\s*$items[2]{name}\s*$},
      'third row second column data',
  )
  ->element_exists(
      'tbody tr:nth-child(3) td:nth-child(2) a[href=/user/3]',
      'third row second column has correct link',
  )
  ;

$t->get_ok( '/?class=wrapper:table-responsive&class=table:table-hover&class=thead:thead-light' )
  ->element_exists( 'table.table-hover', 'table-hover class added to table' )
  ->element_exists( 'div > table', 'wrapper element added by wrapper class' )
  ->element_exists( 'div.table-responsive > table', 'table-responsive class added to wrapper' )
  ->element_exists( 'thead.thead-light', 'thead-light class added to thead' )
  ;

done_testing;

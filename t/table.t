
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
$app->routes->get( '/' )->to( cb => sub {
    my ( $c ) = @_;
    $c->stash(
        items => \@items,
        columns => \@columns,
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
    { key => 'id', title => 'ID' },
    { key => 'name', title => 'Name' },
);

$t->get_ok( '/' )
  ->element_exists( 'table', 'table exists' )
  ->element_exists( 'thead', 'thead exists' )
  ->element_exists( 'thead tr:only-child', 'one thead row exists' )
  ->text_like( 'thead tr:nth-child(1) th:nth-child(1)', qr{^\s*$columns[0]{title}\s*$}, 'first column title' )
  ->text_like( 'thead tr:nth-child(1) th:nth-child(2)', qr{^\s*$columns[1]{title}\s*$}, 'second column title' )
  ->element_exists( 'tbody', 'tbody exists' )
  ->element_exists( 'tbody tr:nth-child(1)', 'first tbody row exists' )
  ->text_like(
      'tbody tr:nth-child(1) td:nth-child(1)', qr{^\s*$items[0]{id}\s*$},
      'first row first column data',
  )
  ->text_like(
      'tbody tr:nth-child(1) td:nth-child(2)', qr{^\s*$items[0]{name}\s*$},
      'first row second column data',
  )
  ->element_exists( 'tbody tr:nth-child(2)', 'second tbody row exists' )
  ->text_like(
      'tbody tr:nth-child(2) td:nth-child(1)', qr{^\s*$items[1]{id}\s*$},
      'second row first column data',
  )
  ->text_like(
      'tbody tr:nth-child(2) td:nth-child(2)', qr{^\s*$items[1]{name}\s*$},
      'second row second column data',
  )
  ->element_exists( 'tbody tr:nth-child(3)', 'third tbody row exists' )
  ->text_like(
      'tbody tr:nth-child(3) td:nth-child(1)', qr{^\s*$items[2]{id}\s*$},
      'third row first column data',
  )
  ->text_like(
      'tbody tr:nth-child(3) td:nth-child(2)', qr{^\s*$items[2]{name}\s*$},
      'third row second column data',
  )
  ;


done_testing;

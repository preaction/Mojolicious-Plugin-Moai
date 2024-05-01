use Mojo::Base -strict, -signatures;

use Mojolicious;
use Mojo::Server::Daemon;
use Mojo::File qw(curfile);

my $daemon = Mojo::Server::Daemon->new(listen => ['http://*?fd=3']);

#
# Here you can customize the app further (database, fixtures...)
#
my @items = (
    { id => 1, name => 'Doug', grade => 'A', },
    { id => 2, name => 'Jeff', grade => 'B', },
    { id => 3, name => 'Katie', grade => 'C', },
    { id => 4, name => 'Brittany', grade => 'D', },
    { id => 5, name => 'Andrew', grade => 'A', },
    { id => 6, name => 'Bob', grade => 'B', },
    { id => 7, name => 'Linda', grade => 'C', },
    { id => 8, name => 'Tina', grade => 'D', },
    { id => 9, name => 'Gene', grade => 'A', },
    { id => 10, name => 'Louise', grade => 'B', },
    { id => 11, name => 'Rudy', grade => 'C', },
    { id => 12, name => 'Darryl', grade => 'D', },
    { id => 13, name => 'Jimmy Jr.', grade => 'A', },
);

my @columns = (
    { key => 'id', title => 'ID' },
    { key => 'name', title => 'Name', link_to => 'user.profile', filter => 'string' },
    { key => 'grade', title => 'Grade', filter => { enum => [qw( A B C D )], }, },
);

my $app = Mojolicious->new;
$app->plugin( Moai => [ $ARGV[0] || 'Bootstrap4' ] );
$app->routes->get( '/user/:id' )->name( 'user.profile' );
$app->routes->get( '/', [format => ['html', 'json']], { format => 'html' }, sub($c) {
  my $page = $c->param('$page') // 1;
  my $limit = $c->param('$limit') // 10;
  my $offset = ($page - 1) * $limit;
  my $start = $offset;
  my $end = $offset + $limit - 1;

  my @filtered_items = @items;
  if ( my $name = $c->param('name') ) {
    @filtered_items = grep { !$name || $_->{name} =~ /$name/i } @filtered_items;
  }
  if ( my $grade = $c->param('grade') ) {
    @filtered_items = grep { !$grade || $_->{grade} eq $grade } @filtered_items;
  }

  $c->stash(
    javascript => $c->param('javascript') // 1,
    items => [@filtered_items[$start..$end]],
    columns => \@columns,
    page_param => '$page',
    total_pages => int(scalar(@filtered_items) / $limit)+1,
  );
  $c->respond_to(
    json => {
      json => {
        items => [@filtered_items[$start..$end]],
        total_pages => int(scalar(@filtered_items) / $limit)+1,
      },
    },
    html => sub { $c->render('moai/datatable') },
  );
});
$daemon->app( $app );

$daemon->run;

#
# Here you can place cleanup code (drop database schema, delete files...)
#

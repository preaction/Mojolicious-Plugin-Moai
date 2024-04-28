use Mojo::Base -strict, -signatures;

use Mojolicious;
use Mojo::Server::Daemon;
use Mojo::File qw(curfile);

my $daemon = Mojo::Server::Daemon->new(listen => ['http://*?fd=3']);

#
# Here you can customize the app further (database, fixtures...)
#
my @items = (
    { id => 1, name => 'Doug' },
    { id => 2, name => 'Jeff' },
    { id => 3, name => 'Katie' },
    { id => 4, name => 'Brittany' },
    { id => 5, name => 'Andrew' },
    { id => 6, name => 'Bob' },
    { id => 7, name => 'Linda' },
    { id => 8, name => 'Tina' },
    { id => 9, name => 'Gene' },
    { id => 10, name => 'Louise' },
    { id => 11, name => 'Rudy' },
    { id => 12, name => 'Darryl' },
    { id => 13, name => 'Jimmy Jr.' },
);


my $app = Mojolicious->new;
$app->plugin( Moai => [ $ARGV[0] || 'Bootstrap4' ] );
$app->routes->get( '/user/:id' )->name( 'user.profile' );
$app->routes->get( '/', [format => ['html', 'json']], { format => 'html' }, sub($c) {
  my $offset = $c->param('$offset') // 0;
  my $limit = $c->param('$limit') // 10;
  my $start = $offset;
  my $end = $offset + $limit - 1;

  $c->stash(
    items => [@items[$start..$end]],
    column => 'name',
  );
  $c->respond_to(
    json => { json => [@items[$start..$end]] },
    html => sub { $c->render('moai/autolist') },
  );
}, 'autolist');
$app->routes->get( '/links', [format => ['html', 'json']], { format => 'html' }, sub($c) {
  my $offset = $c->param('$offset') // 0;
  my $limit = $c->param('$limit') // 10;
  my $start = $offset;
  my $end = $offset + $limit - 1;

  $c->stash(
    items => [@items[$start..$end]],
    column => 'name',
    link_to => 'user.profile',
  );
  $c->respond_to(
    json => { json => [@items[$start..$end]] },
    html => sub { $c->render('moai/autolist') },
  );
}, 'autolist');
$app->routes->get( '/content', [format => ['html', 'json']], { format => 'html' }, sub($c) {
  my $offset = $c->param('$offset') // 0;
  my $limit = $c->param('$limit') // 10;
  my $start = $offset;
  my $end = $offset + $limit - 1;

  $c->stash(
    items => [@items[$start..$end]],
    link_to => 'user.profile',
  );
  $c->respond_to(
    json => { json => [@items[$start..$end]] },
    html => sub { $c->render('content') },
  );
}, 'autolist');
$daemon->app( $app );

$daemon->run;

#
# Here you can place cleanup code (drop database schema, delete files...)
#
__DATA__

@@ content.html.ep
%= include 'moai/autolist', content => begin
  % my $item = shift;
  <%= $item->{name} %> (<%= $item->{id} %>)
% end

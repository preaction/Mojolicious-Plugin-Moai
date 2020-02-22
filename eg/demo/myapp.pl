
use Mojolicious::Lite;
use FindBin qw( $Bin );
use Mojo::File qw( path );
use lib path( $Bin, '..', '..', 'lib' )->to_string;
use lib path( $Bin, '..', '..', 't', 'lib' )->to_string;

plugin Config =>;
plugin Moai => app->config->{moai};
plugin AutoReload =>;

app->defaults({ layout => 'default' });

get '/' => 'index';
get '/elements' => 'elements';
get '/components' => 'components';
get '/elements/table' => 'table';
get '/components/pager' => 'pager';

app->start;

__DATA__
@@ layouts/default.html.ep
<!DOCTYPE html>
<!-- XXX This is until we get a default layout in Moai -->
<head>
%= include 'moai/lib'
<style>
    .example {
        border: 3px solid #f8f9fa;
        border-radius: 5px;
        margin-bottom: 2.5rem;
        padding: 2em 2em 0;
    }
    .example figure {
        background-color: #f8f9fa;
        margin: 0 -2em;
        padding: 2em;
    }
    .container {
        padding: 1em 3em 1em 0;
    }
</style>
</head>
<%= include 'moai/menu/navbar',
    class => {
        navbar => 'navbar-light bg-light',
    },
    brand => [ 'Moai' => '/' ],
    menu => [
        [ Elements => 'elements' ],
        [ Components => 'components' ],
        # [ Layout => 'layout' ],
        # [ Icons => 'icons' ],
    ],
%>
<%= include 'moai/container', class => 'mt-2', content => begin %>
%= content
<% end %>

@@ elements.html.ep
<h1>Moai Elements</h1>

<p>These elements allow for rapid development of pages.</p>
%= include 'element_list'

@@ components.html.ep
<h1>Moai Components</h1>

<p>These components provide a rich, intuitive UI for users.</p>
%= include 'component_list'

@@ moai/container.html.ep
<div class="container"><%= $content->() %></div>

@@ index.html.ep
<h1>Moai</h1>
<h2>Mojolicious UI Library</h1>

Moai is a library of templates for the <a
href="http://mojolicious.org">Mojolicious web framework</a>.

<ul>
    <li>Provides standard elements and components from popular CSS UI libraries</li>
    <li>Integrates with Mojolicious CMSes like <a href="http://preaction.me/yancy">Yancy</a>
        and plugins like <a href="http://metacpan.org/pod/Mojolicious::Plugin::DBIC">Mojolicious::Plugin::DBIC</a>
    <li>Allows templates to be shared even between sites using different UI libraries</li>
</ul>

<h2>Supported Libraries</h2>
<%= link_to 'Bulma', 'http://bulma.io' %>,
<%= link_to 'Bootstrap 4', 'http://getbootstrap.com' %>

<h2>Elements</h2>
%= include 'element_list'

<h2>Components</h2>
%= include 'component_list'

@@ element_list.html.ep
%= link_to 'Table', 'table'

@@ component_list.html.ep
%= link_to 'Pager', 'pager'

@@ table.html.ep
<h1>Table</h1>

<p>The table element provides easy display of tabular data. You can
define the columns and items that the table will display as stash values
to the template.</p>

<section class="example">
<%= include 'moai/table',
    columns => [
        { key => 'name' },
        { key => 'storage', title => 'Storage' },
        { key => 'transfer', title => 'Transfer' },
        { key => 'price', title => 'Price' },
    ],
    items => [
        {
            name => 'Tall',
            storage => '1 GB',
            transfer => '10 GB',
            price => '$5/mo',
        },
        {
            name => 'Venti',
            storage => '2 GB',
            transfer => '20 GB',
            price => '$10/mo',
        },
        {
            name => 'Grande',
            storage => '5 GB',
            transfer => '50 GB',
            price => '$20/mo',
        },
    ],
%>
<figure><pre><code><%%= include 'moai/table',
    columns => [
        { key => 'name' },
        { key => 'storage', title => 'Storage' },
        { key => 'transfer', title => 'Transfer' },
        { key => 'price', title => 'Price' },
    ],
    items => [
        {
            name => 'Tall',
            storage => '1 GB',
            transfer => '10 GB',
            price => '$5/mo',
        },
        {
            name => 'Venti',
            storage => '2 GB',
            transfer => '20 GB',
            price => '$10/mo',
        },
        {
            name => 'Grande',
            storage => '5 GB',
            transfer => '50 GB',
            price => '$20/mo',
        },
    ],
%%></pre></code></figure>
</section>

<p>Table values can be links to other pages using the <code>link_to</code> helper.</p>

<section class="example">
<%= include 'moai/table',
    columns => [
        { key => 'id' },
        { key => 'name', title => 'Username', link_to => 'user' },
    ],
    items => [
        {
            id => 1,
            name => 'Alice',
        },
        {
            id => 2,
            name => 'Bob',
        },
        {
            id => 3,
            name => 'Charlie',
        },
    ],
%>
<figure><pre><code><%%= include 'moai/table',
    columns => [
        { key => 'id' },
        { key => 'name', title => 'Username', link_to => 'user' },
    ],
    items => [
        {
            id => 1,
            name => 'Alice',
        },
        {
            id => 2,
            name => 'Bob',
        },
        {
            id => 3,
            name => 'Charlie',
        },
    ],
%%></pre></code></figure>
</section>

@@ pager.html.ep
<h1>Pager</h1>

<p>The default pager takes the current page from the <code>page</code> query parameter
and the total pages to produce a list of clickable page links</p>
<section class="example">
<p>Page <%= param( 'page' ) || 1 %></p>
<%= include 'moai/pager',
    total_pages => 5,
%>
<figure><pre><code><%%= include 'moai/pager', total_pages => 5 %></code></pre></figure>
</section>

<p>The mini pager shows only links to move to the next page or the previous page.</p>
<section class="example">
<p>Page <%= param( 'page' ) || 1 %></p>
<%= include 'moai/pager/mini',
    total_pages => 5,
%>
<figure><pre><code><%%= include 'moai/pager/mini', total_pages => 5 %></code></pre></figure>
</section>

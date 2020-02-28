package Mojolicious::Plugin::Moai;
our $VERSION = '0.010';
# ABSTRACT: Mojolicious UI components using modern UI libraries

=head1 SYNOPSIS

    use Mojolicious::Lite;
    plugin Moai => 'Bootstrap4', { version => '4.4.1' };
    app->start;
    __DATA__
    @@ list.html.ep
    %= include 'moai/lib'
    %= include 'moai/table', items => \@items, columns => [qw( id name )]
    %= include 'moai/pager', current_page => 1, total_pages => 5

=head1 DESCRIPTION

This plugin provides some common UI components using a couple different
popular UI libraries.

These components are designed to integrate seamlessly with L<Yancy>,
L<Mojolicious::Plugin::DBIC>, and L<Mojolicious::Plugin::SQL>.

=head2 Testing Components

The L<Test::Mojo::Role::Moai> library is provided to help test the Moai
components. It also works without Moai, allowing you to test any website.

=head1 SUPPORTED LIBRARIES

These libraries are not included and the desired version should be added
to your layout templates. To add your library using a CDN, see
L</moai/lib>, below.

=head2 Bootstrap4

L<http://getbootstrap.com>

=head2 Bulma

L<http://bulma.io>

=head1 GETTING STARTED

Add the Moai plugin to your Mojolicious application and specify which
UI library and version of that library you want to use.

    use Mojolicious::Lite;
    plugin Moai => 'Bootstrap4', {
        version => '4.4.1',
    };

Now you can add widgets. You will likely first want to add the C<moai/lib>
widget to your layout template to get the UI library.

    @@ layouts/default.html.ep
    <!DOCTYPE html>
    <head>
        %= include 'moai/lib'
    </head>
    <body><%= content %></body>

=head1 WIDGETS

Widgets are snippets that you can include in your templates using the
L<include helper|Mojolicious::Guides::Rendering/Partial templates>.

=head2 moai/pager

    <%= include 'moai/pager',
        current_page => param( 'page' ),
        total_pages => $total_pages,
    %>

A pagination control. Will display previous and next buttons along with
individual page buttons.

Also comes in a C<mini> variant in C<moai/pager/mini> that has just
previous/next buttons.

=head3 Stash

=over

=item current_page

The current page number. Defaults to the value of the C<page> parameter.

=item total_pages

The total number of pages. Required.

=item page_param

The name of the parameter to use for the current page. Defaults to C<page>.

=item id

An ID to add to the pager

=back

=head2 moai/table

    <%= include 'moai/table',
        items => [
            { id => 1, name => 'Doug' },
        ],
        columns => [
            { key => 'id', title => 'ID' },
            { key => 'name', title => 'Name' },
        ],
    %>

A table of items.

=head3 Stash

=over

=item items

The items to display in the table. An arrayref of hashrefs.

=item columns

The columns to display, in order. An arrayref of hashrefs with the following
keys:

=over

=item key

The hash key in the item to use.

=item title

The text to display in the column heading

=item link_to

Add a link to the given named route. The route will be filled in by the current
item, like C<< url_for $link_to => $item >>.

=item id

An ID to add to the table.

=item class

A hashref of additional classes to add to certain elements:

=over

=item * C<col> - Add these classes to every cell in the column

=back

=back

=item class

A hashref of additional classes to add to certain elements:

=over

=item * C<table>

=item * C<thead>

=item * C<wrapper> - Add a wrapper element with these classes

=back

=back

=head2 moai/menu/navbar

A horizontal navigation bar.

=head3 Stash

=over

=item menu

An arrayref of menu items. Menu items are arrayrefs with two elements:
label, and route name.

    $app->routes->get( '/' )->name( 'index' );
    $app->routes->get( '/blog' )->name( 'blog' );
    $app->routes->get( '/about' )->name( 'about' );

    <%= include 'moai/menu/navbar',
        menu => [
            [ Home => 'index' ],
            [ Blog => 'blog' ],
            [ 'About Us' => 'about' ],
        ],
    %>

=item brand

A menu item for the "brand" section. An arrayref with two elements:
a label, and a route name.

    <%= include 'moai/menu/navbar',
        brand => [ 'Zooniverse' => 'main' ],
    %>

=item position

Position the navbar. Can be either C<fixed-top> to affix the navbar to
the top of the viewport or C<fixed-bottom> for the bottom of the
viewport. If not set, the navbar will be a static element at the current
location.

=item id

An ID to add to the table.

=item class

A hashref of additional classes to add to certain elements:

=over

=item * C<navbar> - Add these classes to the C<< <nav> >> element

=back

=back

=head2 moai/lib

    %= include 'moai/lib', version => '4.1.0';

Add the required stylesheet and JavaScript links for the current library
using a CDN. The stylesheets and JavaScript can be added separately
using C<moai/lib/stylesheet> and C<moai/lib/javascript> respectively.

=head3 Stash

=over

=item version

The specific version of the library to use. Defaults to the C<version>
specified in the plugin (if any). Required.

=back

=head1 TODO

=over

=item Security

The CDN links should have full security hashes.

=item Accessibility Testing

Accessibility testing should be automated and applied to all supported
libraries.

=item Internationalization

This library should use Mojolicious's C<variant> feature to provide
translations for every widget in every library.

=item Add more widgets

There should be widgets for...

=over

=item * other menus (vertical lists, dropdown buttons)

=item * dropdown menus

=item * forms and other items in the navbar (move the Form plugin from Yancy?)

=item * switched panels (tabs, accordion, slider)

=item * alerts (error, warning, info)

=item * menus (dropdown button, menu bar)

=item * popups (modal dialogs, tooltips, notifications)

=item * grid (maybe...)

=back

=item Add more libraries

There should be support for...

=over

=item * Bootstrap 3

=item * Material

=back

Moai should support the same features for each library, allowing easy
switching between them.

=item Add progressive enhancement

Some examples of progressive enhancement:

=over

=item * The table widget could have sortable columns

=item * The table widget could use AJAX to to filter and paginate

=item * The pager widget could use AJAX to update a linked element

=item * The switched panel widgets could load their content lazily

=back

=item Themes

Built-in selection of CDN-based themes for each library

=item Layouts

A customizable layout with good defaults.

=item Default Colors

A default color scheme (light / dark) that responds to a user's
light/dark preferences (MacOS "dark mode"). The default should be settable from
the main config, and overridable for individual elements.

=item Extra Classes

A standard way of adding extra classes to individual tags inside components. In addition
to a string, we should also support a subref so that loops can apply classes to certain
elements based on input criteria.

=item Documentation Sheet

Each supported library should come with a single page that demonstrates the various
widgets and provides copy/paste code snippets to achieve that widget.

It would be amazing if there was a way to make one template apply to all
supported libraries.

=item Content section overrides

We cannot, should not, must not make every little thing customizable or
else our templates will be so complex as to be unmaintainable and
unusable. We should instead make content sections that can be extended,
like the C<moai/table> template could have a C<thead> section,
a C<tbody> section, and a C<tbody.tr> section.

A rule of thumb for adding a feature should be if it can be configured simply by a single
string. The more complex the configuration needs to be, the more likely it should be
customized using L<Mojolicious's template C<extends>|Mojolicious::Guides::Rendering/Template inheritance>

=back

=head1 SEE ALSO

L<Test::Mojo::Role::Moai>, L<Mojolicious::Guides::Rendering>

=cut

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::File qw( path );

has config =>;
sub register {
    my ( $self, $app, $config ) = @_;
    my $library = $config->[0];
    $self->config( $config->[1] || {} );
    $app->helper( moai => sub { $self } );
    my $libdir = path( __FILE__ )->sibling( 'Moai' )->child( 'resources', lc $library );
    push @{$app->renderer->paths}, $libdir->child( 'templates' );
    return;
}

1;

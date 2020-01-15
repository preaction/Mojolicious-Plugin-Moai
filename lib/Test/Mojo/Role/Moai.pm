package Test::Mojo::Role::Moai;
our $VERSION = '0.008';
# ABSTRACT: Test::Mojo role to test UI components

=head1 SYNOPSIS

    my $t = Test::Mojo->with_roles( '+Moai' )->new;
    $t->get_ok( '/' )
      ->table_is(
        '#mytable',
        [
            [ '1BDI' => 'Turanga Leela' ],
            [ 'TJAM' => 'URL' ],
        ],
        'NNY officers are listed',
      );

=head1 DESCRIPTION

This module provides component tests for web pages: Instead of selecting
individual elements and testing their parts, these methods test complete
components in a way that allows for cosmetic, non-material changes to be
made without editing the test.

These methods are designed for L<Mojolicious::Plugin::Moai> components, but
do not require Mojolicious::Plugin::Moai to function. Use them on any web
site you want!

=head1 TODO

=over

=item table_has

Test a table has the given data, ignoring extra data in the table that is
not in the test.

=item qr// for text

Element text and attribute values should allow regex matching in addition
to complete equality.

=item list_is / list_has

Test a list

=item dict_is / dict_has

Test a dictionary list

=item elem_is / elem_has

Test an individual element (using L<Mojo::DOM/at>).

=item all_elem_is / all_elem_has

Test a collection of elements (using L<Mojo::DOM/find>).

=item link_to named route

Elements should be able to test whether they are a link to a named route
with certain stash values set. This allows for the route's URL to change
without needing to change the test.

=item Methods for Moai components

Any Moai components that have special effects or contain multiple testable
elements should be given their own method, with C<_is> and C<_has> variants.

=back

=head1 SEE ALSO

L<Mojolicious::Plugin::Moai>, L<Mojolicious::Guides::Testing>

=cut

use Mojo::Base '-role';
use Mojo::Util qw( trim );
use Test::More;

=method table_is

    # <table>
    # <thead><tr><th>ID</th><th>Name</th></tr></thead>
    # <tbody><tr><td>1</td><td>Doug</td></tr></tbody>
    # </table>
    $t = $t->table_is( '#mytable', [ [ 1, 'Doug' ] ] );
    $t = $t->table_is( '#mytable', [ [ 1, 'Doug' ] ], 'user table' );
    $t = $t->table_is( '#mytable', [ { ID => 1, Name => 'Doug' } ] );

Check data in a table is complete and correct. Data can be tested as
arrays (ordered) or hashes (unordered).

If a table contains a C<< <tbody> >> element, this method will test the
data inside. If not, it will test all rows in the table.

    # <table><tr><td>1</td><td>Doug</td></tr></table>
    $t = $t->table_is( '#mytable', [ [ 1, 'Doug' ] ] );

To test attributes and elements inside the table cells, values can be
hashrefs with a C<text> attribute (for the cell text), an C<elem>
attribute to test descendant elements, and other keys for the cell's
attributes.

    # <table><tr>
    # <td class="center">1</td>
    # <td><a href="/user/doug">Doug</a> <em>(admin)</em></td>
    # </tr></table>
    $t = $t->table_is( '#mytable', [
        [
            { text => 1, class => 'center' },
            { elem => {
                'a' => {
                    text => 'Doug',
                    href => '/user/doug',
                },
                'em' => '(admin)',
            } },
        ],
    ] );

=cut

sub table_is {
    my ( $t, $selector, $rows, $name ) = @_;
    $name ||= 'table ' . $selector . ' data is correct';

    my $el = $t->tx->res->dom->at( $selector );
    if ( !$el ) {
        Test::More::fail( $name );
        Test::More::diag( 'Table ' . $selector . ' not found' );
        return $t->success( 0 );
    }

    my $thead = $el->at( 'thead' );
    my @columns;
    if ( my $thead = $el->at( 'thead' ) ) {
        @columns = $thead->at( 'tr' )->children( 'td,th' )
            ->map( 'all_text' )
            ->map( sub { trim( $_ ) } )
            ->each;
        #; say "Cols: " . join ', ', @columns;
    }

    my @fails;
    my $tbody = $el->at( 'tbody' ) // $el;
    # ; use Data::Dumper;
    # ; say Dumper $el;
    for my $i ( 0..$#$rows ) {
        my @row_data
            = ref $rows->[ $i ] eq 'HASH'
            ? ( map { $rows->[ $i ]{ $_ } } @columns )
            : @{ $rows->[ $i ] };
        my $row_el = $tbody->children->[ $i ];
        for my $c ( 0..$#row_data ) {
            my $expect_data = $row_data[ $c ];

            my $expect_text
                = ref $expect_data eq 'HASH'
                ? delete $expect_data->{text}
                : $expect_data;
            my $cell_el = $row_el->children->[ $c ];
            # ; say Dumper $cell_el;
            my $got_text = trim( $cell_el->all_text );
            if ( defined $expect_text && ( !defined $got_text || $expect_text ne $got_text ) ) {
                #; say sprintf "%s,%s: Exp: %s; Got: %s", $i, $c, $expect_text, $got_text;
                $got_text //= '<undef>';
                push @fails, {
                    row => $i + 1,
                    col => $c + 1,
                    got => qq{"$got_text"},
                    expect => qq{"$expect_text"},
                };
            }

            if ( ref $expect_data eq 'HASH' ) {
                # We've got more tests to run!
                if ( my $elem_test = delete $expect_data->{elem} ) {
                    for my $selector ( sort keys %$elem_test ) {
                        my $el = $cell_el->at( $selector );
                        if ( !$el ) {
                            push @fails, {
                                row => $i + 1,
                                col => $c + 1,
                                got => '<undef>',
                                expect => qq{elem "$selector"},
                            };
                            next;
                        }

                        my $expect_data = $elem_test->{ $selector };
                        my $expect_text
                            = ref $expect_data eq 'HASH'
                            ? delete $expect_data->{text}
                            : $expect_data;
                        my $got_text = trim( $el->all_text );
                        if ( defined $expect_text && ( !defined $got_text || $expect_text ne $got_text ) ) {
                            #; say sprintf "%s,%s: Exp: %s; Got: %s", $i, $c, $expect_text, $got_text;
                            $got_text //= '<undef>';
                            push @fails, {
                                row => $i + 1,
                                col => $c + 1,
                                got => qq{$selector: "$got_text"},
                                expect => qq{$selector: "$expect_text"},
                            };
                        }

                        # Everything that remains is an attribute
                        if ( ref $expect_data eq 'HASH' ) {
                            for my $attr_name ( sort keys %$expect_data ) {
                                my $expect_attr = $expect_data->{ $attr_name };
                                my $got_attr = $el->attr( $attr_name );
                                if ( !defined $got_attr || $expect_attr ne $got_attr ) {
                                    $got_attr //= '<undef>';
                                    #; say sprintf "%s,%s: Exp: %s: %s = %s; Got: %s: %s = %s", $i, $c, $selector, $attr_name, $expect_attr, $selector, $attr_name, $got_attr;
                                    push @fails, {
                                        row => $i + 1,
                                        col => $c + 1,
                                        got => "$selector: $attr_name = $got_attr",
                                        expect => "$selector: $attr_name = $expect_attr",
                                    };
                                }
                            }
                        }
                    }
                }

                # Everything that remains is an attribute
                for my $attr_name ( sort keys %$expect_data ) {
                    my $expect_attr = $expect_data->{ $attr_name };
                    my $got_attr = $cell_el->attr( $attr_name );
                    if ( !defined $got_attr || $expect_attr ne $got_attr ) {
                        $got_attr //= '<undef>';
                        #; say sprintf "%s,%s: Exp: %s = %s; Got: %s = %s", $i, $c, $attr_name, $expect_attr, $attr_name, $got_attr;
                        push @fails, {
                            row => $i + 1,
                            col => $c + 1,
                            got => "$attr_name = $got_attr",
                            expect => "$attr_name = $expect_attr",
                        };
                    }
                }
            }
        }
    }

    if ( @fails ) {
        Test::More::fail( $name );
        Test::More::diag(
            join "\n",
            map {
                sprintf qq{Row: %d - Col: %d\nExpected: %s\nGot: %s},
                    @{$_}{qw( row col expect got )},
            }
            @fails
        );
        return $t->success( 0 );
    }

    Test::More::pass( $name );
    return $t->success( 1 );
}

1;

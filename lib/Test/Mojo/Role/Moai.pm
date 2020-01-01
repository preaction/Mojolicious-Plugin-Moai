package Test::Mojo::Role::Moai;
our $VERSION = '0.006';
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

=back

=head1 SEE ALSO

L<Mojolicious::Plugin::Moai>, L<Mojolicious::Guides::Testing>

=cut

use Mojo::Base '-role';
use Mojo::Util qw( trim );
use Test::More;

=method table_is

    # <table><tr><td>1</td><td>Doug</td></tr></table>
    $t = $t->table_is( '#mytable', [ [ 1, 'Doug' ] ] );
    $t = $t->table_is( '#mytable', [ [ 1, 'Doug' ] ], 'user table' );

Check data in a table is complete and correct. If a table contains a
C<< <tbody> >> element, this method will test the data inside. If not,
it will test all rows in the table.

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

    my @fails;
    my $tbody = $el->at( 'tbody' ) // $el;
    # ; use Data::Dumper;
    # ; say Dumper $el;
    for my $i ( 0..$#$rows ) {
        my $row_data = $rows->[ $i ];
        my $row_el = $tbody->children->[ $i ];
        for my $c ( 0..$#$row_data ) {
            my $expect_data = $row_data->[ $c ];
            my $cell_el = $row_el->children->[ $c ];
            # ; say Dumper $cell_el;
            my $got_data = trim( $cell_el->all_text );
            if ( $expect_data ne $got_data ) {
                push @fails, {
                    row => $i + 1,
                    col => $c + 1,
                    got => $got_data,
                    expect => $expect_data,
                };
            }
        }
    }

    if ( @fails ) {
        Test::More::fail( $name );
        Test::More::diag(
            join "\n",
            map {
                sprintf qq{Row: %d - Col: %d\nExpected: "%s"\nGot: "%s"},
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

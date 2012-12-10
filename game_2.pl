use strict;
use warnings;

use lib './';
require TicTacToe;

no indirect;
no autovivification;

use Data::Dumper;

my $game = TicTacToe->new(3);

while ($game->in_play) {
	$game->print_board;

	$game->make_intelligent_move(player => 1);
	sleep 1;
	$game->make_intelligent_move(player => 2);
}

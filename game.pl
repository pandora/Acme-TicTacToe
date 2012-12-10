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

	print "You are player X. Enter your move e.g. A1 : ";
	my $move = <STDIN>; 
	chomp $move;

	die 'Valid moves constitute the range: A1,A2,A3,B1...C3' 
		unless $move =~ m|\A [ABC] [123] \z|xmso;

	my ($x, $y) = split '', $move;
	$x = (ord $x) - (ord('A') - 1); 

	$game->make_specific_move(
		player => 1,
		move   => {
			x => $x,
			y => $y,
		},
	);

	$game->make_intelligent_move(player => 2);
}

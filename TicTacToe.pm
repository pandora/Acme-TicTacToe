package TicTacToe;

use strict;
use warnings;

use Readonly;
use Data::Dumper;
use Carp qw/confess cluck/;

no autovivification;

Readonly::Hash my %PLAYER_SYMBOL => {1 => 'X', 2 => 'O'};

sub new {
	my ($class, $size) = @_;
	confess 'size of board has not been specified' unless $size;
	my $board = [map {
		[map {undef} (1..$size)]
	} (1..$size)];

	return bless {
		_board => $board, 
		_size => $size,
		_complete => 0,
	}, $class;
}

sub get {
	my ($self, $x, $y) = @_;
	return $self->{_board}->[$y-1]->[$x-1];
}

sub set {
	my ($self, $x, $y, $value) = @_;
	confess 'Attempt to place mark on occupied cell !' 
		if defined $self->get($x, $y);
	$self->{_board}->[$y-1]->[$x-1] = $value;
}

sub in_play {
	my $self = shift;
	return $self->{_complete} ? 0 : 1;	
}

sub announce_winner {
	my ($self, %total) = @_;
	while(my ($symbol, $value) = each %total) {
		if( $value == $self->{_size} ) {
			$self->print_board;
			print "Player $symbol wins !!\n";
			exit 0;
		}
	}
}

sub _traverse_rows {
	my ($self, $total) = @_;
	foreach my $y (1..$self->{_size}) {
		$total->();
		foreach my $x (1..$self->{_size}) {
			$total->($x, $y) if defined $self->get($x, $y);
		}
	}
}

sub _traverse_columns {
	my ($self, $total) = @_;
	foreach my $x (1..$self->{_size}) {
		$total->();
		foreach my $y (1..$self->{_size}) {
			$total->($x, $y) if defined $self->get($x, $y);
		}
	}
}

sub _traverse_diagonal {
	my ($self, $total) = @_;
	$total->();
	foreach my $x (1..$self->{_size}) {
		$total->($x, $x) if defined $self->get($x, $x);
	}
	$total->();

	# Checking diagonal from top right to bottom left *not* implemented correctly:
	for(my $y=$self->{_size}-1; $y>=0; $y--) {
		my $x = $self->{_size} - $y - 1;
		# $total->($x, $y) if defined $self->get($x+1, $y+1);
	}
	$total->();
}

sub update_in_play_status {
	my $self = shift;

	my %total;
	my $total = sub {
		my ($x, $y) = @_;
		if(defined $x && defined $y) {
			$total{ $self->get($_[0], $_[1]) }++;
		}
		else {
			$self->announce_winner(%total);
			%total = ();
		}
	};

	$self->_traverse_rows($total);	
	$self->_traverse_columns($total);
	$self->_traverse_diagonal($total);

	$self->{_complete} = do {
		my $is_complete = 1;
		foreach my $y (1..$self->{_size}) {
			foreach my $x (1..$self->{_size}) {
				$is_complete = 0 unless defined $self->get($x, $y);
			}
		}
		$is_complete;
	};
}

sub make_specific_move {
	my ($self, %p) = @_;
	my $symbol = $PLAYER_SYMBOL{ $p{player} };
	$self->set($p{move}->{x}, $p{move}->{y}, $symbol);
	$self->update_in_play_status;
}

sub make_intelligent_move {
	my ($self, %p) = @_;
	my $symbol = $PLAYER_SYMBOL{ $p{player} };

    # MinMax implementation would make sense here...

	# Currently fills the first available cell,
	# but should rather pass appropriate callbacks into the 
	# traversing methods to 
	# a) block the opponent 
	# b) try and win if two adjacent cells are marked by the player.

	foreach my $y (1..$self->{_size}) {
		foreach my $x (1..$self->{_size}) {
			if(!defined $self->get($x, $y)) {
				$self->set($x, $y, $symbol);
				$self->update_in_play_status;
				return;
			}
		}
	}	
}

sub print_board {
	my $self = shift;

	system 'clear';
	print "    A   B   C\n\n";
	foreach my $y (1..$self->{_size}) {
		print "$y   ";
		foreach my $x (1..$self->{_size}) {
			my $cell;
			eval {
				$cell = defined $self->get($x, $y) ? $self->get($x, $y) : q{-}
			};
			$x == 3 ? print $cell : print "$cell | ";
		}
		print "\n";
	}
	print "\n\n";
}

1;

package Unicode::Block::Ascii;

# Pragmas.
use base qw(Unicode::Block);
use strict;
use warnings;

# Modules.
use Error::Pure qw(err);
use Readonly;
use Text::UnicodeBox;
use Text::UnicodeBox::Control qw(:all);

# Constants.
Readonly::Scalar our $SPACE => q{ };

# Version.
our $VERSION = 0.01;

# Get output.
sub get {
	my $self = shift;

	# Get width.
	$self->_get_chars;
	$self->{'_width'} = 16 + $self->{'_base_width'}
		+ (16 * $self->{'_char_width'});

	# Check width.
	if (defined $self->{'title'}
		&& (length $self->{'title'}) > $self->{'_width'}) {

		err 'Long title.';
	}

	# Box objext.
	my $box = Text::UnicodeBox->new;

	# Title.
	if (defined $self->{'title'}) {

		# Compute title.
		my $spaces = $self->{'_width'} - length $self->{'title'};
		my $left = int($spaces / 2);
		my $right = $self->{'_width'} - $left - length $self->{'title'};
		my $title = ($SPACE x $left).$self->{'title'}.($SPACE x $right);

		# Add title.
		$box->add_line(
			BOX_START('top' => 'light', 'bottom' => 'light'),
			$title,
			BOX_END(),
		);
	}

	# Header.
	my @headers = $SPACE x $self->{'_base_width'}, BOX_RULE;
	foreach my $header_char (0 .. 9, 'A' .. 'F') {
		if (@headers) {
			push @headers, BOX_RULE;
		}
		my $table_header_char = $header_char;
		if ($self->{'_char_width'} > 1) {
			$table_header_char
				= ($SPACE x ($self->{'_char_width'} - 1)).
				$header_char;
		}
		push @headers, $table_header_char;
	}
	my @title;
	if (! defined $self->{'title'}) {
		@title = ('top' => 'light');
	}
	$box->add_line(
		BOX_START(@title, 'bottom' => 'light'), @headers, BOX_END(),
	);

	# Columns.
	my @cols;
	foreach my $item (@{$self->{'_chars'}}) {
		if (@cols) {
			push @cols, BOX_RULE;
		} else {
			push @cols, $SPACE.$item->base.$SPACE, BOX_RULE;
			my $last_num = hex $item->last_hex;
			if ($last_num > 0) {
				push @cols, ($SPACE, BOX_RULE) x $last_num;
			}
		}
		my $char = $item->char;
		if ($item->width < $self->{'_char_width'}) {
			$char = ($SPACE x ($self->{'_char_width'}
				- $item->width)).$char;
		}
		push @cols, $char;
		if ($item->last_hex eq 'f') {
			$box->add_line(
				BOX_START('bottom' => 'light'),
				@cols,
				BOX_END(),
			);
			@cols = ();
		}
	}
	if (@cols) {
		my $spaces = @cols / 2;
		$box->add_line(
			BOX_START('bottom' => 'light'),
			@cols, BOX_RULE,
			($SPACE, BOX_RULE) x (16 - $spaces),
			$SPACE,
			BOX_END,
		);
	}
	return $box->render;
}

# Get chars and compute char width.
sub _get_chars {
	my $self = shift;
	$self->{'_chars'} = [];
	$self->{'_char_width'} = 1;
	$self->{'_base_width'} = 0;
	while (my $item = $self->next) {

		# Look for maximal character width in table.
		if ($item->width > $self->{'_char_width'}) {
			$self->{'_char_width'} = $item->width;
		}

		# Look for maximal base length in table.
		if ((length $item->base) + 2 > $self->{'_base_width'}) {
			$self->{'_base_width'} = (length $item->base) + 2;
		}

		# Add character.
		push @{$self->{'_chars'}}, $item;
	}
	return;
}

1;

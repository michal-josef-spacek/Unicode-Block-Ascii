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
Readonly::Scalar our $WIDTH => 40;

# Version.
our $VERSION = 0.01;

# Get output.
sub get {
	my $self = shift;

	# Check width.
	if (defined $self->{'title'} && (length $self->{'title'}) > $WIDTH) {
		err 'Long title.';
	}

	# Box objext.
	my $box = Text::UnicodeBox->new;

	# Title.
	if (defined $self->{'title'}) {

		# Compute title.
		my $spaces = $WIDTH - length $self->{'title'};
		my $left = int($spaces / 2);
		my $right = $WIDTH - $left - length $self->{'title'};
		my $title = ($SPACE x $left).$self->{'title'}.($SPACE x $right);

		# Add title.
		$box->add_line(
			BOX_START('top' => 'light', 'bottom' => 'light'),
			$title,
			BOX_END(),
		);
	}

	# Header.
	my @headers;
	foreach my $header_char ($SPACE x 8, 0 .. 9, 'A' .. 'F') {
		if (@headers) {
			push @headers, BOX_RULE;
		}
		push @headers, $header_char;
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
	while (my $item = $self->next) {
		if (@cols) {
			push @cols, BOX_RULE;
		} else {
			push @cols, $SPACE.$item->base.$SPACE, BOX_RULE;
			my $last_num = hex $item->last_hex;
			if ($last_num > 0) {
				push @cols, ($SPACE, BOX_RULE) x $last_num;
			}
		}
		push @cols, $item->char;
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

1;

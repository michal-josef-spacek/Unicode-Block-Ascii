package Unicode::Block::Ascii;

# Pragmas.
use base qw(Unicode::Block);
use strict;
use warnings;

# Modules.
use Class::Utils qw(set_params split_params);
use Error::Pure qw(err);
use Readonly;
use Text::UnicodeBox;
use Text::UnicodeBox::Control qw(:all);

# Constants.
Readonly::Scalar our $SPACE => q{ };
Readonly::Scalar our $WIDTH => 40;

# Version.
our $VERSION = 0.01;

# Constructor.
sub new {
	my ($class, @params) = @_;

	# Object.
	my ($object_params_ar, $other_params_ar) = split_params(
		['title'], @params);
	my $self = $class->SUPER::new(@{$other_params_ar});

	# Title.
	$self->{'title'} = undef;

	# Process.
	set_params($self, @{$object_params_ar});

	# Check width.
	if (defined $self->{'title'} && (length $self->{'title'}) > $WIDTH) {
		err 'Long title.';
	}

	# Compute title.
	if (defined $self->{'title'}) {
		my $spaces = $WIDTH - length $self->{'title'};
		my $left = int($spaces / 2);
		my $right = $WIDTH - $left - length $self->{'title'};
		$self->{'_title'} = ($SPACE x $left).$self->{'title'}.($SPACE x $right);
	}

	# Object.
	return $self;
}

# Get output.
sub get {
	my $self = shift;

	# Box objext.
	my $box = Text::UnicodeBox->new;

	# Title.
	if (defined $self->{'title'}) {
		$box->add_line(
			BOX_START('top' => 'light', 'bottom' => 'light'),
			$self->{'_title'},
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

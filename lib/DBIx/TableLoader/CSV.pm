#
# This file is part of DBIx-TableLoader-CSV
#
# This software is copyright (c) 2011 by Randy Stauner.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
package DBIx::TableLoader::CSV;
BEGIN {
  $DBIx::TableLoader::CSV::VERSION = '1.002';
}
BEGIN {
  $DBIx::TableLoader::CSV::AUTHORITY = 'cpan:RWSTAUNER';
}
# ABSTRACT: Easily load a CSV into a database table


use strict;
use warnings;
use parent 'DBIx::TableLoader';
use Carp qw(croak carp);
use Module::Load ();
use Text::CSV 1.21 ();


# 'new' inherited

sub defaults {
	my ($self) = @_;
	return {
		csv             => undef,
		csv_class       => 'Text::CSV',
		csv_defaults    => {
			# Text::CSV encourages setting { binary => 1 }
			binary => 1,
		},
		csv_opts        => {},
		file            => undef,
		io              => undef,
		no_header       => 0,
	};
}


sub get_raw_row {
	my ($self) = @_;
	return $self->{csv}->getline($self->{io});
}


sub default_name {
	my ($self) = @_;
	# guess name if not provided
	return $self->{name} ||=
		$self->{file}
			? do {
				require File::Basename; # core
				File::Basename::fileparse($self->{file}, qr/\.[^.]*/);
			}
			: 'csv';
}


sub prepare_data {
	my ($self) = @_;

	Module::Load::load($self->{csv_class});

	# if an object is not passed in via 'csv', create one from 'csv_opts'
	$self->{csv} ||= $self->{csv_class}->new({
		%{ $self->{csv_defaults} },
		%{ $self->{csv_opts} }
	});

	# if 'io' not provided set it to the handle returned from opening 'file'
	$self->{io} ||= do {
		croak("Cannot proceed without a 'file' or 'io' attribute")
			unless my $file = $self->{file};
		open(my $fh, '<', $file)
			or croak("Failed to open '$file': $!");
		binmode($fh);
		$fh;
	};

	# discard first row if columns given (see POD for 'no_header' option)
	$self->{first_row} = $self->get_raw_row()
		if $self->{columns} && !$self->{no_header};
}

1;


__END__
=pod

=for :stopwords Randy Stauner csv cpan testmatrix url annocpan anno bugtracker rt cpants
kwalitee diff irc mailto metadata placeholders

=head1 NAME

DBIx::TableLoader::CSV - Easily load a CSV into a database table

=head1 VERSION

version 1.002

=head1 SYNOPSIS

	my $dbh = DBI->connect(@connection_args);

	DBIx::TableLoader::CSV->new(dbh => $dbh, file => $path_to_csv)->load();

	# interact with new database table full of data in $dbh

In most cases simply calling C<load()> is sufficient,
but all methods are documented below in case you are curious
or want to do something a little trickier.

There are many options available for configuration.
See L</OPTIONS> for those specific to this module
and also L<DBIx::TableLoader/OPTIONS> for options from the base module.

=head1 DESCRIPTION

This is a subclass of L<DBIx::TableLoader> that handles
the common operations of reading a CSV file
(using the powerful L<Text::CSV> (which uses L<Text::CSV_XS> if available)).

This module simplifies the task of transforming a CSV file
into a database table.
This functionality was the impetus for the parent module (L<DBIx::TableLoader>).

=head1 METHODS

=head2 new

Accepts all options described in L<DBIx::TableLoader/OPTIONS>
plus some CSV specific options.

See L</OPTIONS>.

=head1 get_raw_row

Returns C<< $csv->getline($io) >>.

=head1 default_name

If the C<name> option is not provided,
and the C<file> option is,
returns the file basename.

Falls back to C<'csv'>.

=head1 prepare_data

This is called automatically from the constructor
to make things as simple and automatic as possible.

=over 4

=item *

Load C<csv_class> if it is not.

=item *

Instantiate C<csv_class> with C<csv_defaults> and C<csv_opts>.

=item *

Open the C<file> provided unless C<io> is passed instead.

=item *

Discard the first row if C<columns> is provided and C<no_header> is not.

=back

=head1 OPTIONS

The most common usage might include these options:

=over 4

=item *

C<csv_opts> - Hashref of options to pass to the C<new> method of C<csv_class>

See L<Text::CSV> for its list of accepted options.

=item *

C<file> - Path to a csv file

The file will be opened (unless C<io> is provided)
and its basename will be the default table name
(which can be overwritten with the C<name> option).

=back

If you need more customization or are using this inside of
a larger application you may find some of these useful:

=over 4

=item *

C<csv> - A L<Text::CSV> compatible object instance

If not supplied an instance will be created
using C<< $csv_class->new(\%csv_opts) >>.

=item *

C<csv_class> - The class to instantiate if C<csv> is not supplied

Defaults to C<Text::CSV>
(which will attempt to load L<Text::CSV_XS> and fall back to L<Text::CSV_PP>).

=item *

C<csv_defaults> - Hashref of default options for C<csv_class> constructor

Includes C<< { binary => 1 } >> (as encouraged by L<Text::CSV>);
To turn off the C<binary> option
you can pass C<< { binary => 0 } >> to C<csv_opts>.
If you are using a different C<csv_class> that does not accept
the C<binary> option you may need to overwrite this with an empty hash.

=item *

C<io> - A filehandle or IO-like object from which to read CSV lines

This will be used as C<< $csv->getline($io) >>.
When providing this option you can still provide C<file>
if you want the table name to be determined automatically
(but no attempt will be made to open C<file>).

=item *

C<name> - Table name

If not given the table name will be set to the file basename
or C<'csv'> if C<file> is not provided.

=item *

C<no_header> - Boolean

Usually the first row [header] of a CSV is the column names.
If you specify C<columns> this module assumes you are overwriting
the usual header row so the first row of the CSV will be discarded.
If there is no header row on the CSV (the first row is data),
you must set C<no_header> to true in order to preserve the first row of the CSV.

=back

=head1 SEE ALSO

=over 4

=item *

L<DBIx::TableLoader>

=item *

L<Text::CSV>

=back

=head1 SUPPORT

=head2 Perldoc

You can find documentation for this module with the perldoc command.

  perldoc DBIx::TableLoader::CSV

=head2 Websites

The following websites have more information about this module, and may be of help to you. As always,
in addition to those websites please use your favorite search engine to discover more resources.

=over 4

=item *

Search CPAN

L<http://search.cpan.org/dist/DBIx-TableLoader-CSV>

=item *

RT: CPAN's Bug Tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=DBIx-TableLoader-CSV>

=item *

AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/DBIx-TableLoader-CSV>

=item *

CPAN Ratings

L<http://cpanratings.perl.org/d/DBIx-TableLoader-CSV>

=item *

CPAN Forum

L<http://cpanforum.com/dist/DBIx-TableLoader-CSV>

=item *

CPANTS Kwalitee

L<http://cpants.perl.org/dist/overview/DBIx-TableLoader-CSV>

=item *

CPAN Testers Results

L<http://cpantesters.org/distro/D/DBIx-TableLoader-CSV.html>

=item *

CPAN Testers Matrix

L<http://matrix.cpantesters.org/?dist=DBIx-TableLoader-CSV>

=back

=head2 Bugs / Feature Requests

Please report any bugs or feature requests by email to C<bug-dbix-tableloader-csv at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=DBIx-TableLoader-CSV>. You will be automatically notified of any
progress on the request by the system.

=head2 Source Code


L<http://github.com/magnificent-tears/DBIx-TableLoader-CSV/tree>

  git clone git://github.com/magnificent-tears/DBIx-TableLoader-CSV.git

=head1 AUTHOR

Randy Stauner <rwstauner@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Randy Stauner.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


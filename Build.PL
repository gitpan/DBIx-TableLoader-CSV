
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  'build_requires' => {
    'File::Find' => '0',
    'File::Temp' => '0',
    'FindBin' => '0',
    'Module::Build' => '0.3601',
    'Symbol' => '0',
    'Test::MockObject' => '1.09',
    'Test::More' => '0.96'
  },
  'configure_requires' => {
    'Module::Build' => '0.3601'
  },
  'dist_abstract' => 'Easily load a CSV into a database table',
  'dist_author' => [
    'Randy Stauner <rwstauner@cpan.org>'
  ],
  'dist_name' => 'DBIx-TableLoader-CSV',
  'dist_version' => '1.001',
  'license' => 'perl',
  'module_name' => 'DBIx::TableLoader::CSV',
  'recommends' => {
    'Text::CSV_XS' => '0.80'
  },
  'recursive_test_files' => 1,
  'requires' => {
    'Carp' => '0',
    'DBIx::TableLoader' => '0',
    'File::Basename' => '0',
    'Module::Load' => '0',
    'Text::CSV' => '1.21',
    'parent' => '0',
    'perl' => '5.006'
  },
  'script_files' => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;

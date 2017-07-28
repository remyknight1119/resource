#!/usr/bin/perl -w

use warnings;
use strict;
use Getopt::Std;
use Tie::File;

use vars qw($opt_f $opt_s);

sub usage  {
    print ("usage: $0 -f [/path/to/file] -s [split_string]\n");
}

getopts('f:s:');
if (! $opt_f || ! $opt_s) {
    &usage();
    exit(1);
}
my $file = $opt_f;
my $string = $opt_s;

tie my @file_array, 'Tie::File', "$file" || die("Tie $file failure!\n");
for (my $line = 0; $line < @file_array; $line++) {
    my $line_data = $file_array[$line];
    if ($line_data !~ $string) {
        print("This line(line $line) have no key $string!");
        next;
    }
    my @data = split /$string/, $file_array[$line];
    $file_array[$line] = $data[0];
    $file_array[$line] = "$file_array[$line] $string";
    my @unsorted = split / /, $data[1];
    my @sort = sort @unsorted;
    my $sorted = "@sort";
    $file_array[$line] = "$file_array[$line] $sorted";
}
untie @file_array;


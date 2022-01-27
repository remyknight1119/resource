#!/usr/bin/perl
#
use Getopt::Std;

use vars qw($opt_d $opt_a, $opt_h);
getopts('d:a:h');

sub usage 
{
	print ("usage: $0 -d [dir name] -a []\n");
}

if ($opt_h) {
	&usage;
	exit(1);
}

if (! $opt_d) {
	print "-d not set!\n";
	&usage;
	exit(1);
}

sub count_file
{
    my $file = $_[0];
    my $line_count = 0;
    my $comment = 0;

    open(INFILE, "$file") || die("couldn't open $file");;

    while (<INFILE>) {
        if ($_ =~ /\/\*/) {
            $comment = 1;
        }

        if ($comment == 0 && !($_ =~ /^\s*$/) && !($_ =~ /\/\//)) {
            $line_count++;
        }

        if ($_ =~ /\*\//) {
            $comment = 0;
        }
    }

    return $line_count;
}

sub count_dir
{
    my $dir = $_[0];
    my $count = 0;

    opendir DIR, $dir or die "Can not open $dir/n";
    my @filelist = readdir DIR;

    print "dir: ".$dir,"\n";
    foreach (@filelist) {
        my $path = "$dir/$_";
        if (-d $path) {
            if ($_ ne "." && $_ ne "..") {
                $count += count_dir($path);
            }
        } elsif ($path =~ /(\.c|\.h)$/) {
            $count += count_file($path);
        }
    }

    return $count;
}

$count = count_dir($opt_d);
print "Code Count is $count\n";


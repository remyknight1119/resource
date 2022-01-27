#!/usr/bin/perl
#
use Getopt::Std;

sub usage 
{
	print ("usage: $0 [dir-1] [dir-2] [dir-3]..[dir-n]\n");
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

$count = 0;

foreach(@ARGV){
    if ($_ eq "-h") {
        usage();
        exit(0);
    }
    $count += count_dir($_);
}

print "Code Count is $count\n";


#!/usr/bin/perl

use strict;
use warnings;
use Tie::File;
use Getopt::Std;

use vars qw($opt_f $opt_K $opt_B $opt_c $opt_s $opt_r $opt_h);
getopts('f:BKcsrh');

sub usage {
    print ("usage: $0 -f [file path] -B (print binary) -K (key) -c (convert)\n");
    print ("\t\t\t\t-s (string mode for -B, default is hex mode)\n");
    print ("\t\t\t\t-r (reverse seq for -K and -c)\n");
    print ("\t\t\t\t-h (no args, help)\n");
}

if ($opt_h) {
    &usage;
    exit(0);
}

my $file = $opt_f;
my $bin = $opt_B;
my $string = $opt_s;
my $key = $opt_K;
my $convert = $opt_c;
my $reverse = $opt_r;

if (! $file) {
    print ("Please input file with -f!\n");
    exit(1);
}

if (! -f $file) {
    print ("$file not exist!\n");
    exit(1);
}

sub rsa_parse_pem_private_key {
    my $file_array = shift(@_);
    my $nl;
    my $count = 0;
    my $end;

    foreach my $l (@$file_array) {
        if ($l =~ /^\S/) {
            if ($l =~ /BEGIN/) {
                last;
            }
            print("$l\n");
            $count = 0;
            next;
        }
        $nl = $l;
        $nl =~ s/ //g;
        if ($nl =~ /:$/) {
            chop($nl);
            $end = 0;
        } else {
            $end = 1;
        }
        $count += $nl =~ s/:/\\x/g;
        $count++;
        print("\"\\x$nl\"\n");
        if ($end eq 1) {
            print("count is $count\n");
        }
    }
}

sub bin_print {
    my $file_array = shift(@_);
    my $s = shift(@_);
    my $count = 0;
    my $nl;

    print("\"");
    for (my $i = 0; $i < @$file_array; $i++) {
        my $l = $$file_array[$i];
        my $strLength = length $l;
        for ( my $i = 0 ; $i < $strLength ; $i++) {
            $count++;
            if ($s) {
                $nl = unpack("A2", substr($l, $i));
                $i++;
            } else {
                $nl = unpack("H2", substr($l, $i));
            }
            print("\\x$nl");
        }
        if ($i + 1 ne @$file_array) {
            $count++;
            print("\\x0a");
        }
    }
    print("\"\n");
    print("count = $count\n");
}

sub key_convert {
    my $file_array = shift(@_);
    my $re = shift(@_);
    my $count = 0;
    my $nl;
    my @a = ();
    my @b = ();

    foreach my $l (@$file_array) {
        $nl = $l;
        $nl =~ s/ //g;
        if ($nl =~ /^$/) {
            last;
        }
        if ($nl =~ /:$/) {
            chop($nl);
        }
        @a = split(/:/, $nl);
    }

    for ($count = 0; $count < @a; $count++) {
        if ($re) {
            unshift(@b, $a[$count]);
        } else {
            push(@b, $a[$count]);
        }
        if (($count + 1) % 4 == 0) {
            foreach my $bc (@b) {
                print("$bc");
            }
            print("\n");
            @b = ();
        }
    }
    print("count is $count\n");
}

my @file_array;

tie(@file_array,'Tie::File', $file) or die("Tile $file failed!\n");

if ($bin) {
    &bin_print(\@file_array, $string);
}

if ($key) {
    if ($convert) {
        &key_convert(\@file_array, $reverse);
    } else {
        &rsa_parse_pem_private_key(\@file_array);
    }
}

untie(@file_array);

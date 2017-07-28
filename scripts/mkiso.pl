#!/usr/bin/perl -w
#use strict;
use Getopt::Std;

use vars qw($opt_d $opt_o);
getopts('d:o:p:n:');

sub usage 
{
    print ("usage: $0 -d [rpm_dir] -o [iso_dir] -p [output_dir] -n [iso_file_name]\n");
}

sub write_ks 
{
    my $ks_file = $_[0];
    my $rpm_key = $_[1];
    my $start_match = 0;
    my $matched = 0;

    open(KSFILE, "+<$ks_file") || die("couldn't open $ks_file");
    while (<KSFILE>) {
        if ($_ =~ /^%packages$/) {
            $start_match = 1;
        }

        if ($start_match && $_ =~ /^$rpm_key$/) {
            $matched = 1;
            last
        }

        last if ($_ =~ /^%end$/);
    }

    close(KSFILE);

    if ($matched) {
        print "$rpm_key exist!\n";
        return;
    }

    $ret = `sed -i "/%end/ i $rpm_key" $ks_file`;
    if ($ret) {
        die("Modify $ks_file failed!");
    }
}

if (! $opt_d) {
    print "-d not set!\n";
    usage;
    exit(1);
}

if (! $opt_o) {
    print "-o not set!\n";
    usage;
    exit(1);
}

if (! $opt_p) {
    print "-p not set!\n";
    usage;
    exit(1);
}

if (! $opt_n) {
    print "-n not set!\n";
    usage;
    exit(1);
}

$rpms_dir = $opt_d;
$iso_dir = $opt_o;
$output_dir = $opt_p;
$iso_name = $opt_n;

if (! -d $rpms_dir) {
    print ("$rpms_dir not exist!\n");
    usage;
    exit(1);
}

if (! -d $iso_dir) {
    print ("$iso_dir not exist!\n");
    usage;
    exit(1);
}

@rpms = `ls $rpms_dir/*.rpm`;
$len = @rpms;
if ($len == 0) {
    print ("directory $rpms_dir have no rpm\n");
    exit(0);
}

if ($rpms[0] =~ /x86_64/) {
    $os_dir = 64;
} else {
    $os_dir = 32;
}

$ret = system("cp $rpms_dir/*.rpm $iso_dir/$os_dir/Packages/");
if ($ret) {
    die("Copy rpms failed!");
}

$cfg_file = $iso_dir . '/' . "$os_dir" . '/'. 'isolinux/'. 'ks.cfg';
foreach $rpm (@rpms) {
    @full_name = split('/', $rpm);
    $base_name = $full_name[-1];
    @frag = split('-', $base_name);
    $rpm_key = $frag[0];
    $frag_len = @frag;
    for ($count = 1; $count < $frag_len; $count++){
        if ($frag[$count] =~ /^[0-9]/) {
            last;
        }
        $rpm_key .= "-$frag[$count]";
    }
    write_ks($cfg_file, $rpm_key);
}

$src_dir = "$iso_dir/$os_dir";
$ret = system("$iso_dir/scripts/create-iso.sh $src_dir $output_dir $iso_name");
if ($ret) {
    print("mkiso failed!\n");
    exit(1);
}



#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Std;
use File::Find;
use Tie::File;
use Cwd;

use vars qw($opt_v $opt_h);
getopts('v:h');

my $curr_dir = getcwd();
my $spec_dir = "$curr_dir/package";

sub usage {
    print ("usage: $0 -v [package version num, format: x.x.x]\n");
    print ("\t\t\t\t-h (no args, help)\n");
}

my @rpm_spec_files;
sub _get_spec_files {
    if (! -d $File::Find::name && $File::Find::name =~/^.*\.spec$/) {
        push(@rpm_spec_files, $File::Find::name);
    }
}

sub get_spec_files {
    my $dir = shift(@_);

    @rpm_spec_files = ();
    find(\&_get_spec_files, $dir);

    return @rpm_spec_files;
}

sub check_version_num {
    my $ver_num = shift(@_);

    if (! $ver_num) {
        return 1;
    }

    if ($ver_num =~ /^\d+\.\d+\.\d+$/) {
        return 0
    }

    return 1;
}

sub get_config {
    my $input = shift(@_);
    my $key = shift(@_);
    my @sp;

    if ($input =~ /^$key/) {
        @sp = split(/ /, $input);
        if (!$sp[1]) {
            die("parse $input error!\n");
        }
        return $sp[1];
    }
}

sub modify_spec {
    my $spec = shift(@_);
    my $ver_num = shift(@_);
    my $old_ver;
    my $pkg_name;
    my $index = 0;
    my @file_array;
    my @sp;

    tie(@file_array,'Tie::File', $spec) or 
    die("Tile $spec failed!\n");
    foreach my $content (@file_array) {
        if ($content =~ /^Name:/) {
            @sp = split(/:/, $content);
            $sp[1] =~ s/^(\s+)|(\s+)$//g;
            if (!$sp[1]) {
                die("parse $content error!\n");
            }
            $pkg_name = $sp[1];
        } elsif ($content =~ /^Version:/) {
            @sp = split(/:/, $content);
            $sp[1] =~ s/^(\s+)|(\s+)$//g;
            if (!$sp[1]) {
                die("parse $content error!\n");
            }
            $old_ver = $sp[1];
            $file_array[$index] =~ s/$old_ver/$ver_num/g;
        }
        $index++;
    }

    untie(@file_array);

    return $pkg_name;
}

sub run_cmd {
    my $cmd = shift(@_);
    my $ret;

    $ret = system($cmd);
    if ($ret ne 0) {
        die("$cmd failed!\n");
    }
}

sub build_rpms {
    my $spec = shift(@_);
    my $ver_num = shift(@_);
    my $pkg_cmd;
    my $pkg_name;
    my $git_tag;
    my $ret;

    $pkg_name = &modify_spec($spec, $ver_num); 
    if (!$pkg_name) {
        die("modify $spec failed\n");
    }
    $git_tag = "v$ver_num";
    $pkg_name .= "-$ver_num-1";
    $pkg_cmd = "git archive --format tar --o $pkg_name.tar --prefix $pkg_name/";
    &run_cmd("$pkg_cmd $git_tag");
    &run_cmd("gzip $pkg_name.tar");
    &run_cmd("mv $pkg_name.tar.gz ~/rpmbuild/SOURCES/");
    &run_cmd("rpmbuild -bb $spec");
    &run_cmd("git checkout $spec");
}

if ($opt_h) {
    &usage;
    exit(0);
}

my $version = $opt_v;
if (! $version) {
    &usage;
    exit(0);
}

my $ret = &check_version_num($version);
if ($ret ne 0) {
    die("Versin num $version not valid!\n");
}

if (! -d $spec_dir) {
    print("$spec_dir not exist!\n");
    exit(0);
}

my @pkg_spec_files = &get_spec_files($spec_dir);
foreach my $spec (@pkg_spec_files) {
     &build_rpms($spec, $version);
}


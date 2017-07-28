#!/usr/bin/perl

use Getopt::Std;

use vars qw($opt_n $opt_a, $opt_h);
getopts('n:a:h');

sub usage 
{
	print ("usage: $0 -n [vm name] -a [action: start|stop]\n");
}

if ($opt_h) {
	&usage;
	exit(1);
}

if (! $opt_n) {
	print "-n not set!\n";
	&usage;
	exit(1);
}

if (! $opt_a) {
	print "-a not set!\n";
	&usage;
	exit(1);
}

if ($opt_a eq "start") {
	@conf_file = `ls kvm*.conf`;
	foreach $conf (@conf_file) {
		chomp($conf);
		$vmname = `grep ^name $conf | cut -d ':' -f 2 | awk '{print \$1}'`; 
		chomp($vmname);
		if ($vmname eq $opt_n) {
			$mac = `tail -n 1 $conf | sed 's/://g'`;
			print "$mac";
			$ret = system "sudo kvm_safe_cmd -A -n $vmname -m $mac";
			if ($ret != 0) {
				print "Add vm $vmname failed!\n";
				exit(1);
			}
			$ret = system "sudo ./kvm_start.pl -c $conf &";
			if ($ret != 0) {
				print "Start vm $vmname failed!\n";
				system "sudo kvm_safe_cmd -D -n $vmname";
				exit(1);
			}
		}
	}
} elsif ($opt_a eq "stop") {
	system "sudo kvm_safe_cmd -D -n $opt_n";
	$qemu_pid = `ps ax | grep $opt_n | head -n 1 | awk '{print \$1}'`; 
	system "sudo kill -9 $qemu_pid";
} else {
	print "unkonw action $opt_a \n";
	&usage;
	exit(1);
} 

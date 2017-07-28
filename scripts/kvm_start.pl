#!/usr/bin/perl -w

use Getopt::Std;

use vars qw($opt_c $opt_h);
getopts('c:h');

$cpu_num = 'cpu_num';
$hard_disk = 'hard_disk';
$disk_size = 'disk_size';
$memory = 'memory';
$nic_num = 'nic_num';
$cdrom = 'cdrom';
$script = 'script';
$down_script = 'down_script';
$qemu_conf = 'qemu_conf';
$serial = 'serial';
$name = 'name';

sub usage 
{
    print ("usage: $0 -c [config file]\n");
    print ("configuration file example:\n");
    print ("$cpu_num: 1\n");
    print ("$hard_disk: /path/to/hard_disk\n");
    print ("$disk_size: 5G\n");
    print ("$memory: 512\n");
    print ("$nic_num: 1\n");
    print ("$script: /path/to/script\n");
    print ("$down_script: /path/to/down_script\n");
    print ("$cdrom: /path/to/iso\n");
    print ("$qemu_conf: /path/to/qemu_conf\n");
    print ("$serial: /path/to/unix_file\n");
    print ("$name: vm_name\n");
}

if ($opt_h) {
    &usage;
    exit(1);
}

if (! $opt_c) {
    print "-c not set!\n";
    &usage;
    exit(1);
}

$config_file = $opt_c;

if (! -e $config_file ) {
    print ("$config_file not exist!\n");
    &usage;
    exit(1);
}

my $kvm_x86_cmd = 'kvm';
my $kvm_cmd = $kvm_x86_cmd;

#Parse configuration file
my $def_conf;
my $cpu_num_value;
my $disk_file;
my $disk_file_size = '5G';
my $netdev_num = 0;
my $script_path = 'no';
my $down_script_path = 'no';
my $mac_start = 'DE:AD:BE:EF:';
my @mac_array;
my $vm_name;
my $mac_index = 0;
my $serial_file;

open(CONF, "+<$config_file") || die("couldn't open $config_file");
while (<CONF>) {
    next if ($_ =~ /^#/);

    if ($_ =~ /^$cpu_num:/) {
        @content = split / /, $_;
        $cpu_num_value = $content[1];
        chomp($cpu_num_value);
        $kvm_cmd = "$kvm_cmd -smp $cpu_num_value";
    } elsif ($_ =~ /^$qemu_conf:/) {
        @content = split / /, $_;
        $def_conf = $content[1];
        chomp($def_conf);
    } elsif ($_ =~ /^$hard_disk:/) {
        @content = split / /, $_;
        $disk_file = $content[1];
        chomp($disk_file);
        $kvm_cmd = "$kvm_cmd -hda $disk_file";
    } elsif ($_ =~ /^$disk_size:/) {
        @content = split / /, $_;
        $disk_file_size = $content[1];
        chomp($disk_file_size);
    } elsif ($_ =~ /^$memory:/) {
        @content = split / /, $_;
        $mem_size = $content[1];
        chomp($mem_size);
        $kvm_cmd = "$kvm_cmd -m $mem_size";
    } elsif ($_ =~ /^$cdrom:/) {
        @content = split / /, $_;
        $iso_file = $content[1];
        chomp($iso_file);
        $kvm_cmd = "$kvm_cmd -cdrom $iso_file";
    } elsif ($_ =~ /^$nic_num:/) {
        @content = split / /, $_;
        $netdev_num = $content[1];
        chomp($netdev_num);
    } elsif ($_ =~ /^$script:/) {
        @content = split / /, $_;
        $script_path = $content[1];
        chomp($script_path);
    } elsif ($_ =~ /^$down_script:/) {
        @content = split / /, $_;
        $down_script_path = $content[1];
        chomp($down_script_path);
    } elsif ($_ =~ /^$name:/) {
        @content = split / /, $_;
        $vm_name = $content[1];
        chomp($vm_name);
        $kvm_cmd = "$kvm_cmd -name $vm_name";
    } elsif ($_ =~ /^$mac_start/) {
        $mac_array[$mac_index] = $_;
        $mac_index++;
    } elsif ($_ =~ /^$serial/) {
        @content = split / /, $_;
        $serial_file = $content[1];
        chomp($serial_file);
        $kvm_cmd = "$kvm_cmd -serial unix:$serial_file,server";
    }
}

if ($def_conf && -e $def_conf) {
    $ret = `$kvm_x86_cmd -readconfig $def_conf`;
    exit(0);
}

for ($num = 0; $num < $netdev_num; $num++) {
    if ($mac_array[$num]) {
        $macaddress = $mac_array[$num];
    } else {
        $macaddress = sprintf "$mac_start%x:%x", int(rand(238) + 16), int(rand(238) + 16);
        print CONF ("$macaddress\n");
    }
    chomp($macaddress);
    $kvm_cmd = "$kvm_cmd -device e1000,netdev=net$num,mac=$macaddress -netdev tap,id=net$num,script=$script_path,downscript=$down_script_path";
}

close(CONF);

if ($def_conf) {
    $kvm_cmd = "$kvm_cmd -writeconfig $def_conf";
}

#Create img if img file not exist
if ($disk_file && ! -e $disk_file) {
    $ret = `qemu-img create -f qcow2 $disk_file $disk_file_size`;
    if ($ret) {
        print ("$ret\n");
    }
}

print("$kvm_cmd\n");
$ret = `$kvm_cmd -enable-kvm -localtime`;
if ($ret) {
    die("kvm exited!\n");
}


#!/usr/bin/perl

use Proc::Daemon;

my $action = $ARGV[0];
if (! $action) {
    die("Please input action!\n");
}

my $pid_file = "/tmp/google-proxy.pid";
if ($action eq "start") {
    my $cmd = 'python proxy.py';
    my $daemon = Proc::Daemon->new(
        work_dir     => '/home/jason/goagent/local',
        pid_file     => "$pid_file",
        exec_command => "$cmd"
    );

    my $dpid = $daemon->Init;
    print("PID = $dpid\n");
} elsif ($action eq "stop") {
    open(PIDFILE, "<$pid_file") || die("Can't open $pid_file\n");
    my $deamon_pid = <PIDFILE>;
    close(PIDFILE);
    kill(9, $deamon_pid);
} else {
    die("Unknow action $action!\n");
}

#!/usr/bin/perl -w
use IO::Socket;
use IO::Select;

# hash to install IP Port
%ser_info = (
    "ser_ip" => "0.0.0.0",
    "ser_port" => "8888",
);

%dest_info = (
    "ser_ip" => "127.0.0.1",
    "ser_port" => "80",
);

my $dest_addr = $dest_info{"ser_ip"};
my $dest_port = $dest_info{"ser_port"};

my $ser_addr = $ser_info{"ser_ip"};
my $ser_port = $ser_info{"ser_port"};
my $socket = IO::Socket::INET->new(
    LocalAddr => "$ser_addr",  #本机IP地址
    LocalPort => "$ser_port",   #定义本机的Port，然后进行bind
    Type => SOCK_STREAM,  #套接字类型
    Proto => "tcp", #协议名
    Listen => 20,  #定义listen的最大数
)
    or die "Can not create socket connect.$@";

$i = 0;
@array = ();
while (1) {
    my $new = $socket->accept();
    print "New connection!\n";
    $new->recv($buffer, 1024, 0);
    print "buffer = $buffer \n";
    if (!$buffer) {
        print "No data\n";
        $new->close();
        next;
    }
    $i++;
    if ($i <= 1) {
        $array[$i] = $new;
  #      next;
    }
    sleep 2;
    my $dest = IO::Socket::INET->new(
        PeerAddr => "$dest_addr",
        PeerPort => "$dest_port",
        Type => SOCK_STREAM,
        Proto => "tcp",
    )
    or die "Can not create socket connect.$@";
    $dest->send($buffer, 0);
    $dest->recv($buffer, 1024, 0);
    print "$buffer \n";
    $new->send($buffer, 0);
    $new->close();
    $dest->close();
}

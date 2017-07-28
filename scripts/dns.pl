#!/usr/bin/perl

use strict;
use warnings;
use Net::DNS::Nameserver;

sub reply_handler {
    my ($qname, $qclass, $qtype, $peerhost,$query,$conn) = @_;
    my ($rcode, $rr, $ttl, $rdata, @ans, @auth, @add,);

    print "Received query from $peerhost to ". $conn->{sockhost}. "\n";
    $query->print;

    if ($qtype eq "A" && $qname eq "foo.example.com" ) {
        my @ip_address = ("10.5.1.80", "10.5.1.81", "10.5.1.82");
        foreach my $ip (@ip_address) {
            ($ttl, $rdata) = (3600, $ip);
            $rr = new Net::DNS::RR("$qname $ttl $qclass $qtype $rdata");
            push @ans, $rr;
        }
        $rcode = "NOERROR";
    }elsif( $qname eq "foo.example.com" ) {
        $rcode = "NOERROR";
    } elsif ($qtype eq "PTR" && $qname eq "22.1.5.10.in-addr.arpa") {
        print "==================Received query name = $qname\n";
        ($ttl, $rdata) = (3600, "senginx-test.com");
        $rr = new Net::DNS::RR("$qname $ttl $qclass $qtype $rdata");
        push @ans, $rr;
        $rcode = "NOERROR";
    }else{
        $rcode = "NXDOMAIN";
    }

# mark the answer as authoritive (by setting the 'aa' flag
    return ($rcode, \@ans, \@auth, \@add, { aa => 1 });
}

my $ns = new Net::DNS::Nameserver(
    LocalPort    => 53,
    ReplyHandler => \&reply_handler,
    Verbose      => 1
) || die "couldn't create nameserver object\n";

$ns->main_loop;

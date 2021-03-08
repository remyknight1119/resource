#include <arpa/inet.h>
#include <stdio.h>

int is_valid_ipv4(const char *ipv4)
{
	struct in_addr addr;
	if(ipv4 == NULL)
		return 0;
	if(inet_pton(AF_INET, ipv4, (void *)&addr) == 1)
		return 1;
	return 0;
}

int is_valid_ipv6(const char *ipv6)
{
	struct in6_addr addr6;
	if(ipv6 == NULL)
		return 0;
	if(inet_pton(AF_INET6, ipv6, (void *)&addr6) == 1)
		return 1;
	return 0;
}

int main(void)
{
	printf("%d\n", is_valid_ipv4(""));
	printf("%d\n", is_valid_ipv4("122"));
	printf("%d\n", is_valid_ipv4("122.1.1.1"));
	printf("%d\n", is_valid_ipv6("fec0::da24:bdff:fe76:cea2"));
	printf("%d\n", is_valid_ipv6("192.168.111.11"));
	return 0;
}

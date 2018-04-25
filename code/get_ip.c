#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <errno.h>
#include <arpa/inet.h>
#include <string.h>
 
unsigned char get_netmask_prefix(unsigned char *mask, int len)
{
    int                 i;
    int                 j;
    unsigned char       prefix = 0;

    for (i = 0 ; i < len; i++) {
        for (j = 7;  j >= 0; j--) {
            if ((mask[i] & (1 << j)) == 0) {
                return prefix;
            }
            prefix++;
        }
    }
    return prefix;
}

int get_if_addr_info(char *ifname)
{
    struct ifaddrs* ifaddr = NULL;
    struct sockaddr_in *in;
    struct sockaddr_in *m;
    struct sockaddr_in6 *in6;
    struct sockaddr_in6 *m6;
    char ip[256];
    unsigned char mask;
    int ret = getifaddrs(&ifaddr);
    struct ifaddrs* ifp = ifaddr;

    if (ret) {
        printf("getifaddrs failed, errno:%d\n", errno);
        return 1;
    }

    for (; ifp != NULL; ifp = ifp->ifa_next) {
        if (ifp->ifa_addr == NULL || ifp->ifa_netmask == NULL) {
            continue;
        }

        if (strcmp(ifname, ifp->ifa_name) != 0) {
            continue;
        }

        if (ifp->ifa_addr->sa_family == AF_INET) {
            in = (struct sockaddr_in*)ifp->ifa_addr;
            m = (struct sockaddr_in*)ifp->ifa_netmask;
            inet_ntop(AF_INET, &in->sin_addr, ip, sizeof(ip));
            mask = get_netmask_prefix((unsigned char *)&m->sin_addr, sizeof(m->sin_addr));
            printf("dev:%s, ip:%s/%u\n", ifp->ifa_name, ip, mask);
        } else {
            in6 = (struct sockaddr_in6*)ifp->ifa_addr;
            m6 = (struct sockaddr_in6*)ifp->ifa_netmask;
            inet_ntop(AF_INET6, &in6->sin6_addr, ip, sizeof(ip));
            mask = get_netmask_prefix((unsigned char *)&m6->sin6_addr, sizeof(m6->sin6_addr));
            printf("dev:%s, ip:%s/%u\n", ifp->ifa_name, ip, mask);
        }
    }

    freeifaddrs(ifaddr);
    return 0;
}

int main(void)
{
    return get_if_addr_info("enp5s0");
}

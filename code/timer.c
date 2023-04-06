#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <setjmp.h>
#include <unistd.h>
#include <sys/time.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define PORT 8889
#define BUFFER_SIZE 1024


sigjmp_buf jump_buffer;

void handler(int signum) {
    printf("Received signal %d\n", signum);
    siglongjmp(jump_buffer, 1);
}

int main() {
    int sockfd;
    struct sockaddr_in server_addr, client_addr;
    char buffer[BUFFER_SIZE];
    struct itimerval timer;
    struct timeval time_interval;
    int is_timeout = 0;

    signal(SIGALRM, handler);

    // Set timer to expire after 2 seconds
    time_interval.tv_sec = 2;
    time_interval.tv_usec = 0;
    timer.it_interval = time_interval;
    timer.it_value = time_interval;
    setitimer(ITIMER_REAL, &timer, NULL);


    // 创建 UDP 套接字
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) {
        perror("socket");
        exit(EXIT_FAILURE);
    }

    // 绑定本地端口
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(PORT);
    if (bind(sockfd, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0) {
        perror("bind");
        exit(EXIT_FAILURE);
    }

    printf("Listening on port %d...\n", PORT);

    // 接收数据
    while (1) {
        socklen_t client_addr_len = sizeof(client_addr);
        sigsetjmp(jump_buffer, 1);
        is_timeout++;
        if (is_timeout < 5) {
            setitimer(ITIMER_REAL, &timer, NULL);
        } else {
            printf("timeout\n");
            exit(0);
        }
        printf("before recv\n");
        ssize_t num_bytes = recvfrom(sockfd, buffer, BUFFER_SIZE - 1, 0, (struct sockaddr*)&client_addr, &client_addr_len);
        if (num_bytes < 0) {
            perror("recvfrom");
            continue;
        }

        buffer[num_bytes] = '\0';
        printf("Received %ld bytes from %s:%d: %s\n", (long)num_bytes, inet_ntoa(client_addr.sin_addr), ntohs(client_addr.sin_port), buffer);
    }

    // 关闭套接字
    close(sockfd);

    return 0;
}


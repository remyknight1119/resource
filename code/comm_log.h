#ifndef __HAPROXY_LOG_H__
#define __HAPROXY_LOG_H__

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

static inline unsigned int
comm_log_get_time_smec(void)
{
	struct timeval  t = {};

	gettimeofday(&t, NULL);

	return (t.tv_sec*1000 + t.tv_usec/1000);
}

static inline char *
comm_log_get_time_str(void)
{
    static char t[1024];
    char *ct  = NULL;
    time_t timep;

    time(&timep);

	ct = ctime(&timep);
    snprintf(&t[0], strlen(ct), ct);

    return &t[0];
}


#define COMM_LOG_FILE 	"/home/h.log"
#define COMM_LOG(format, ...) \
    do { \
        FILE *fp = NULL; \
        char *curr_time = NULL; \
		unsigned int 	ms = 0; \
        fp = fopen(COMM_LOG_FILE, "a"); \
        if (fp == NULL) { \
            fprintf(stderr, "open %s failed(%s)\n", COMM_LOG_FILE, strerror(errno)); \
            break; \
        } \
        curr_time =  comm_log_get_time_str(); \
		ms = comm_log_get_time_smec(); \
        fprintf(fp, "\n<%d>[%s][%u][%s, %d]: "format, getpid(), curr_time, \
                ms, __FUNCTION__, __LINE__, ##__VA_ARGS__); \
        fclose(fp); \
    } while (0)

#define COMM_PRINT(data, len) \
    do { \
        FILE *fp = NULL; \
		unsigned char *d = (unsigned char *)data; \
		int i = 0; \
        fp = fopen(COMM_LOG_FILE, "a"); \
        if (fp == NULL) { \
            fprintf(stderr, "open %s failed(%s)\n", COMM_LOG_FILE, strerror(errno)); \
            break; \
        } \
		for (i = 0; i < len; i++) { \
			fprintf(fp, "%02x ", d[i]); \
		} \
		fprintf(fp, "<%d>\n", getpid()); \
		fclose(fp); \
		COMM_LOG("\nlen = %d\n", len); \
    } while (0)


#if 1
#include <execinfo.h>
#include <stdio.h>
#include <stdlib.h>
 
static inline void print_stacktrace(void)
{
    int size = 16;
    void * array[16];
    int     i;
    int stack_num = backtrace(array, size);
    char ** stacktrace = backtrace_symbols(array, stack_num);
    FILE *fp = NULL;
    fp = fopen(COMM_LOG_FILE, "a");
    if (fp == NULL) {
        return;
    }
    for (i = 0; i < stack_num; ++i)
    {
        fprintf(fp, "%s\n", stacktrace[i]);
    }
    fclose(fp);
    free(stacktrace);
}

#endif
#endif

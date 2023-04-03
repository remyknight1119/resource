#include <stdio.h>
#include <getopt.h>
#include <unistd.h>
#include <string.h>

#include <curl/curl.h>

static const char *program_version = "1.0.0";//PACKAGE_STRING;
static const struct option long_opts[] = {
    {"help", 0, 0, 'H'},
    {"u", 0, 0, 'u'},
    {"a", 0, 0, 'a'},
    {0, 0, 0, 0}
};

static const char *options[] = {
    "--url              -u	URL\n",
    "--ca               -a	path to CA cert\n",
    "--help             -H	Print help information\n",
};

static void help(void)
{
    int     index;

    fprintf(stdout, "Version: %s\n", program_version);

    fprintf(stdout, "\nOptions:\n");
    for (index = 0; index < sizeof(options)/sizeof(options[0]); index++) {
        fprintf(stdout, "  %s", options[index]);
    }
}

static const char *optstring = "Hu:a:";

int main(int argc, char **argv)  
{
    CURL *curl = NULL;
    char *url = NULL;
    char *ca = NULL;
    CURLcode res;
    int c = 0;

    while ((c = getopt_long(argc, argv, optstring, long_opts, NULL)) != -1) {
        switch (c) {
            case 'H':
                help();
                return 0;
            case 'u':
                url = optarg;
                break;
            case 'a':
                ca = optarg;
                break;
             default:
                help();
                return -1;
        }
    }

    if (url == NULL) {
        fprintf(stderr, "Please input URL\n");
        return -1;
    }

    curl_global_init(CURL_GLOBAL_DEFAULT);
    curl = curl_easy_init();
    if (curl == NULL) {
        goto out;
    }
    curl_easy_setopt(curl, CURLOPT_URL, url);
    /* Follow any redirects */
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
    /* Verify peer's SSL certificate */
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 1L);
    /* Verify peer's hostname matches certificate CN or SAN */
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 2L);
    if (ca != NULL) {
        curl_easy_setopt(curl, CURLOPT_CAINFO, ca);
    }
    res = curl_easy_perform(curl);
    if (res != CURLE_OK) {
        fprintf(stderr, "curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
    }
    curl_easy_cleanup(curl);
out:
    curl_global_cleanup();
    return 0;
}


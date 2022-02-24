
X509 *get_cert_x509(char *cert, const int type)
{
    STACK_OF (X509_INFO) *inf = NULL;
    X509_INFO *xi = NULL;
    BIO *b = NULL;
    X509 *x = NULL;
    char filename[PATHLEN] = {0};
    size_t i = 0;

    cert_form_file_name(filename, PATHLEN, cert, type);

    if ((b = BIO_new_file(filename, "r")) == NULL) {
        return NULL;
    }

    inf = PEM_X509_INFO_read_bio(b, NULL, NULL, NULL);
    BIO_free(b);
    if (inf == NULL) {
        return NULL;
    }

    for (i = 0; i < sk_X509_INFO_num(inf); i++) {
        xi = sk_X509_INFO_value(inf, i);
        if (xi == NULL || xi->x509 == NULL) {
            continue;
        }

        if (!X509_check_ca(xi->x509)) {
            x = xi->x509;
            X509_up_ref(x);
            break;
        }
    }

    sk_X509_INFO_pop_free(inf, X509_INFO_free);
    return x;
}

int get_cert_cn(char *cert, const int type, char *cn, size_t len)
{
    X509 *x = NULL;
    X509_NAME *nm = NULL;
    char subject[X509_SUBJECT_MAX_LEN] = {};
    int ret = -1;

    x = get_cert_x509(cert, type);
    if (x == NULL) {
        return -1;
    }

    nm = X509_get_issuer_name(x);
    if (nm == NULL) {
        goto err;
    }

    X509_NAME_oneline(nm, subject, sizeof(subject));

err:
    X509_free(x);
    return ret;
}


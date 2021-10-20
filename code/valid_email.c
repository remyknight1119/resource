#include <stdio.h>
#include <stdbool.h>
#include <time.h>
#include <stddef.h>
#include <string.h>
#include <pthread.h>
#include <openssl/rsa.h>
#include <openssl/pem.h>
#include <openssl/ssl.h>

bool is_valid_char(char ch)
{
	if ((ch >= 'a') && (ch <= 'z')) {
		return true;
	}

	if ((ch >= 'A') && (ch <= 'Z')) {
		return true;
	}
	if ((ch >= '0') && (ch <= '9')) {
		return true;
	}

	if (ch == '_' || ch == '-' || ch == '.' || ch == '@') {
		return true;
	}

	return false;
}

bool is_valid_email(char *email)
{
	int 	i = 0;
	size_t 	len = 0;

	len = strlen(email);
	if (len < 5 ) {
		return false;
	}

	char ch = email[0];
	if (!(((ch >= 'a') && (ch <= 'z')) || ((ch >= 'A') && (ch <= 'Z')))) {
		return false;
	}

	int atCount =0;
	int atPos = 0;
	int dotCount = 0;
	for (i = 1; i < len; i++) {//0已经判断过了，从1开始
		ch = email[i];
		if (!is_valid_char(ch)) {
			return false;
		}

		if (ch == '@') {
			atCount++;
			atPos = i;
		} else if ((atCount > 0) && (ch == '.')) {//@符号后的"."号
			dotCount++;
		}
	}

	//结尾不得是字符“@”或者“.”
	if (ch == '.') {
		return false;
	}
	//必须包含一个并且只有一个符号“@”
	//@后必须包含至少一个至多三个符号“.”
	if ((atCount != 1) || (dotCount < 1) || (dotCount > 3)) {
		return false;
	}
	//5. 不允许出现“@.”或者.@
	if (strstr(email, "@.") != NULL) {
		return false;
	}
	if (strstr(email, ".@") != NULL) {
		return false;
	}

	return true;
}

int main(void)
{
	char *email = "a@a";
	printf("%s is valid Email? %d\n", email, is_valid_email(email));
	email = "a@163.com";
	printf("%s is valid Email? %d\n", email, is_valid_email(email));
	email = "a@@163.com";
	printf("%s is valid Email? %d\n", email, is_valid_email(email));
	email = "a@1635";
	printf("%s is valid Email? %d\n", email, is_valid_email(email));
	email = "1@163.com";
	printf("%s is valid Email? %d\n", email, is_valid_email(email));
	email = "a@.163.com";
	printf("%s is valid Email? %d\n", email, is_valid_email(email));

    return 0;
}

LIBS = -lpthread 

TARGET = test	
CC = gcc -g
#CFLAGS = -O2 -DQE_DEBUG 
CFLAGS = -DQE_DEBUG 

C_SOURCES = test.c

C_OBJS = $(C_SOURCES:.c=.o)

$(TARGET): $(C_OBJS)
	$(CC) $(C_OBJS) $(LIBS) -Wl,-rpath,../../lib -o $@

%.o:%.c
	$(CC) $(CFLAGS) $(INCLUDE) -c $<

clean:
	rm -f ${TARGET} *.o
install:
	cp ogrpe /usr/sbin
	

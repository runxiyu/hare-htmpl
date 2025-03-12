CC = cc
YACC = yacc
CFLAGS = -Wall -Werror -O2
YFLAGS = -d
LDFLAGS =

TARGET = chtmpl

PREFIX ?= /usr/local

SRCS = chtmpl.c parse.y
OBJS = chtmpl.o parse.o

all: $(TARGET)

parse.c parse.h: parse.y
	$(YACC) $(YFLAGS) -o parse.c $<

chtmpl.o: chtmpl.c parse.h
	$(CC) $(CFLAGS) -c -o $@ $<

parse.o: parse.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

clean:
	rm -f $(TARGET) $(OBJS) parse.c parse.h *~

install: $(TARGET)
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 755 $(TARGET) $(DESTDIR)$(PREFIX)/bin/

.PHONY: all clean install

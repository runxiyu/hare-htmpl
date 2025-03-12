CC = cc
YACC = yacc
CFLAGS = -Wall -Werror -O2 -fPIC
YFLAGS = -d
LDFLAGS =

VERSION = 1
SONAME = libchtmplr.so.$(VERSION)

TARGET = chtmpl
STATIC_LIB = libchtmplr.a
SHARED_LIB = libchtmplr.so.$(VERSION)
SHARED_LINK = libchtmplr.so

SRCS = chtmpl.c parse.y
OBJS = chtmpl.o parse.o

LIB_SRCS = chtmplr.c
LIB_OBJS = chtmplr.o

all: $(TARGET) $(STATIC_LIB) $(SHARED_LIB)

parse.c parse.h: parse.y
	$(YACC) $(YFLAGS) -o parse.c $<

chtmpl.o: chtmpl.c parse.h
	$(CC) $(CFLAGS) -c -o $@ $<

parse.o: parse.c
	$(CC) $(CFLAGS) -c -o $@ $<

chtmplr.o: chtmplr.c chtmplr.h
	$(CC) $(CFLAGS) -c -o $@ $<

$(STATIC_LIB): $(LIB_OBJS)
	ar rcs $@ $<

$(SHARED_LIB): $(LIB_OBJS)
	$(CC) -shared -Wl,-soname,$(SONAME) -o $@ $< $(LDFLAGS)
	ln -sf $(SHARED_LIB) $(SHARED_LINK)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

clean:
	rm -f $(TARGET) $(OBJS) parse.c parse.h $(LIB_OBJS) $(STATIC_LIB) $(SHARED_LIB) $(SHARED_LINK) *~

PREFIX ?= /usr/local
LIBDIR ?= $(PREFIX)/lib
INCLUDEDIR ?= $(PREFIX)/include

install: install-bin install-lib

install-bin: $(TARGET)
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 755 $(TARGET) $(DESTDIR)$(PREFIX)/bin/

install-lib: $(STATIC_LIB) $(SHARED_LIB)
	install -d $(DESTDIR)$(INCLUDEDIR)
	install -m 644 chtmplr.h $(DESTDIR)$(INCLUDEDIR)/

	install -d $(DESTDIR)$(LIBDIR)
	install -m 644 $(STATIC_LIB) $(DESTDIR)$(LIBDIR)/

	install -m 755 $(SHARED_LIB) $(DESTDIR)$(LIBDIR)/
	ln -sf $(SHARED_LIB) $(DESTDIR)$(LIBDIR)/$(SHARED_LINK)
	ln -sf $(SHARED_LIB) $(DESTDIR)$(LIBDIR)/$(SONAME)
	
	-if [ $$(id -u) -eq 0 ]; then ldconfig; fi

.PHONY: all clean install install-bin install-lib

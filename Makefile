CC := gcc
CFLAGS := -O3 -Wall -Wextra

SRCDIR := src
LIBDIR := lib
EXEDIR := exe

SRCS := $(wildcard $(SRCDIR)/*.c)
LIBS := $(wildcard $(LIBDIR)/*.c)

all: $(SRCS:$(SRCDIR)/%.c=$(EXEDIR)/%)

clean:
	rm -f $(EXEDIR)/*

$(EXEDIR)/%: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) $< $(LIBS) -o $@

.PHONY: all clean

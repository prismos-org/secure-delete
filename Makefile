# Compiler and tools
CC = gcc

# Directories
SRC_DIR = src
DOC_SRC_DIR = doc
BIN_DIR = out/bin

INSTALL_DIR = /usr/bin
MAN_DIR = /usr/local/man/man1
DOC_DIR = /usr/share/doc/secure_delete

# Programs and sources
PROGRAMS = srm sfill sswap smem
SOURCES = $(addprefix $(SRC_DIR)/,$(addsuffix .c,$(PROGRAMS)))
OBJECTS = $(addprefix $(BIN_DIR)/,$(addsuffix .o,$(PROGRAMS)))
LIB_SRC = $(SRC_DIR)/sdel-lib.c
LIB_OBJ = $(BIN_DIR)/sdel-lib.o
BINS = $(addprefix $(BIN_DIR)/,$(PROGRAMS))

# Compiler flags
CFLAGS = -O3 -g0 -fstack-protector-strong -fstack-check -fcf-protection=full \
         -D_FORTIFY_SOURCE=2 -D_GLIBCXX_ASSERTIONS -fPIE -pie -fstrict-overflow -fno-strict-aliasing \
         -Wall -fcf-protection -Wformat-security -Werror=format-security -Werror=implicit-function-declaration
LDFLAGS = -Wl,-z,relro -Wl,-z,now -Wl,-z,defs

# Documentation files
MAN_PAGES = $(DOC_SRC_DIR)/man/srm.1 $(DOC_SRC_DIR)/man/sfill.1 $(DOC_SRC_DIR)/man/sswap.1 $(DOC_SRC_DIR)/man/smem.1
DOC_FILES = $(DOC_SRC_DIR)/secure_delete.doc $(DOC_SRC_DIR)/usenix6-gutmann.doc

# Targets
all: $(BINS)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(LIB_OBJ): $(LIB_SRC) | $(BIN_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BIN_DIR)/%.o: $(SRC_DIR)/%.c | $(BIN_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BIN_DIR)/%: $(BIN_DIR)/%.o $(LIB_OBJ)
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@
	strip --strip-unneeded $@

clean:
	rm -rf $(BIN_DIR) *.o core

install: all
	install -Dm755 $(BINS) $(INSTALL_DIR)
	install -Dm755 $(SRC_DIR)/the-cleaner $(INSTALL_DIR)
	ln -sf srm $(INSTALL_DIR)/sdel
	install -Dm644 $(MAN_PAGES) $(MAN_DIR)
	install -Dm644 $(DOC_FILES) $(DOC_DIR)

uninstall:
	rm -f $(addprefix $(INSTALL_DIR)/,$(PROGRAMS)) $(INSTALL_DIR)/the-cleaner.sh $(INSTALL_DIR)/sdel
	rm -f $(addprefix $(MAN_DIR)/,$(notdir $(MAN_PAGES)))
	rm -f $(addprefix $(DOC_DIR)/,$(notdir $(DOC_FILES)))

# Phony targets
.PHONY: all clean install uninstall

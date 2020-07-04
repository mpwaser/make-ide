#!/usr/bin/make -f

CC     = gcc

BUILD := build
BIN   := $(BUILD)/bin
OBJ   := $(BUILD)/obj

SOURCES := $(patsubst src/%.c,%,$(wildcard src/*.c))
TESTS   := $(patsubst test/%.c,%,$(wildcard test/*.c))

CFLAGS += -std=gnu11
CFLAGS += -O3 -march=native -fdata-sections -ffunction-sections
CFLAGS += -Wall -Wextra -Wpedantic
CFLAGS += -Wno-unused-result -Wno-unused-value -Wno-unused-function

CFLAGS += -Iincl -I/usr/local/lib
LDLIBS += -lm -pthread

CFLAGS += $(shell pkg-config --cflags libcurl)
CFLAGS += $(shell pkg-config --cflags libpq)
CFLAGS += $(shell pkg-config --cflags json-c)
CFLAGS += $(shell pkg-config --cflags nlopt)

LDLIBS += $(shell pkg-config --libs blas)
LDLIBS += $(shell pkg-config --libs lapack)
LDLIBS += $(shell pkg-config --libs lapacke)
LDLIBS += $(shell pkg-config --libs libcurl)
LDLIBS += $(shell pkg-config --libs libpq)
LDLIBS += $(shell pkg-config --libs json-c)
LDLIBS += $(shell pkg-config --libs nlopt)

ifeq ($(DEBUG),true)
CFLAGS := -g3 -O0 $(filter-out -O3,$(CFLAGS))
endif

NAME := module
NAME_UPPER  = $(shell echo $(NAME) | tr a-z A-Z)

TEST := main
DEBUG := false

main: $(SOURCES:%=$(OBJ)/%.o) ## Compile main
	$(CC) $^ $(CFLAGS) -MMD $(LDLIBS) -o $@

$(OBJ)/%.o: src/%.c | $(OBJ)
	$(CC) -c $(CFLAGS) -MMD -MT $@ -MF $(OBJ)/$*.d $< -o $@

check: $(TESTS:%=$(BIN)/%)  ## Run all unit tests
	@for name in $^; do ./$$name; done

$(BIN)/%: $(OBJ)/%.o $(filter-out $(OBJ)/main.o,$(SOURCES:%=$(OBJ)/%.o)) | $(BIN)
	@$(CC) $^ $(CFLAGS) -MMD $(LDLIBS) -o $@

$(OBJ)/%.o: test/%.c | $(OBJ)
	@$(CC) -c $(CFLAGS) -MMD -MT $@ -MF $(OBJ)/$*.d $< -o $@

$(BIN) $(OBJ):
	@mkdir -p $@

clean: ## Remove build folder
	rm -rf build

run: ## Compile main and run executable
	make main -s && make ./main

debug: ## Debug main or module unit test, e.g. make debug TEST=foo
ifeq ($(TEST),main)
	make main DEBUG=true && gdb ./$(TEST)
else
	make check DEBUG=true && gdb ./build/bin/test_$(TEST)
endif

ide: ## Open all project related files in Vim
	ctags -R . && vim -c "set list nu et sta sts=2 ts=2 sw=2 tag \
	       	| vsp | args **/*.c **/*.h <CR> "

module: ## Create templates for new modules, e.g. make module NAME=foo

	@printf '%s\n' '#include <stdlib.h>' '' '#include "$(NAME).h"' '' ''     \
		'void' 'function(void)' '{' '' '}' >> src/$(NAME).c
	@printf '%s\n' '#ifndef $(NAME_UPPER)_H_' '' '' '/* description */'      \
		'void' 'function(void);' '' '' '#endif' >> incl/$(NAME).h
	@printf '%s\n' '#include <stdlib.h>' '#include <stdbool.h>' ''           \
		'#include "check.h"' '#include "$(NAME).h"' '' '' 'static void'  \
		'test_feature(void)' '{' '  check_assert(0);' '}' '' ''          \
		'int main(void)' '{' '  check_init("test_$(NAME)");'             \
		'  check_run(test_feature);' '  exit(EXIT_SUCCESS);' '}'         \
		>> test/test_$(NAME).c

project:  ## Set up folder structure for new project in empty root folder
	@mkdir -p test src incl
	$(file > check.h,$(CHECK))
	@mv check.h incl/check.h
	@printf '%s\n' '#include <stdlib.h>' '' '' 'int main(void)' \
		'{' '' '}' >> src/main.c

help: 
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sed -n 's/^\(.*\): \(.*\)##\(.*\)/\1\t\3/p'

.PHONY: ide module project


define CHECK = 
#ifndef CHECK_H_
#define CHECK_H_

#include <unistd.h>
#include <sys/mman.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>

#define CHECK_SHOW_MAX 20
#define CHECK_EXPR_LENGTH 100

struct check_info {
  unsigned num_tests, num_failed;
  char fail_msg[CHECK_SHOW_MAX][CHECK_EXPR_LENGTH];
  int main_pid;
};
static struct check_info* ci;

#define PASSED     "\x1B[1;32mok\x1B[0m"
#define FAILED     "\x1B[1;31mfailed\x1B[0m"
#define PASS_DOT   "\x1B[1;32m.\x1B[0m"
#define FAIL_DOT   "\x1B[1;31mF\x1B[0m"
#define EXIT_DOT   "\x1B[1;31mE\x1B[0m"
#define SIGNAL_DOT "\x1B[1;31mS\x1B[0m"

#define CHECK__STR(n) #n
#define CHECK_STR(n) CHECK__STR(n)
#define check__assert(expr, ...) do {                           \
  if (!(expr)) {                                                \
    snprintf(ci->fail_msg[ci->num_failed++], CHECK_EXPR_LENGTH, \
        __FILE__ ": " CHECK_STR(__LINE__) ": " __VA_ARGS__);    \
    return;                                                     \
  }                                                             \
} while (0)
#define check_assert(expr) check__assert(expr, "'%s' failed\n", #expr)


static void
check_exit(void)
{
  if (getpid() == ci->main_pid)
  {
    if (!ci->num_failed)
    {
      fprintf(stderr, " %s %u test%s\n", PASSED, ci->num_tests,
          ci->num_tests == 1 ? "" : "s");
    }
    else
    {
      fprintf(stderr, " %s %u of %u test%s\n", FAILED, ci->num_failed,
          ci->num_tests, ci->num_tests == 1 ? "" : "s");
      size_t k = ci->num_failed > CHECK_SHOW_MAX ? CHECK_SHOW_MAX : ci->num_failed;
      for (size_t i = 0; i < k; ++i)
      {
        printf("%s", ci->fail_msg[i]);
      }
    }
  }
  fflush(stderr);
  munmap(ci, sizeof(*ci));
}


void
check_init(const char* name)
{
  ci = mmap(NULL, sizeof(*ci), PROT_READ | PROT_WRITE,
      MAP_SHARED | MAP_ANONYMOUS, -1, 0);
  ci->num_tests = ci->num_failed = 0;
  ci->main_pid = getpid();
  atexit(check_exit);
  fprintf(stderr, "%8s: ", name);
}


void
check_error(const char* file, int line, const char* fname, int stat)
{
  int sig = 0;
  if ((sig = WEXITSTATUS(stat))) 
  {
    fprintf(stderr, "%s", EXIT_DOT);
    snprintf(ci->fail_msg[ci->num_failed++], CHECK_EXPR_LENGTH,
        "%s:%d: %s non-zero exit (%d)\n", file, line, fname, sig);
  }
  else if ((sig = WTERMSIG(stat)))
  {
    fprintf(stderr, "%s", SIGNAL_DOT);
    snprintf(ci->fail_msg[ci->num_failed++], CHECK_EXPR_LENGTH,
        "%s:%d: %s recieved signal %d (%s)\n", file, line, fname,
        sig, strsignal(sig));
  }
  fflush(stderr);
}


#define check_run(fn) check__run(__FILE__, __LINE__, #fn, fn)

static void __attribute__ ((unused))
check__run(const char* file, int line, const char* fname, void(*fn)(void))
{
  int stat = 0;
  unsigned fails = ci->num_failed;
  ++ci->num_tests;
  pid_t pid = fork();
  if (pid == 0)
  {
    fn();
    fprintf(stderr, "%s", ci->num_failed > fails ? FAIL_DOT : PASS_DOT);
    fflush(stderr);
    exit(EXIT_SUCCESS);
  }
  else
  {
    waitpid(pid, &stat, 0);
    check_error(file, line, fname, stat);
  }
}

#endif
endef



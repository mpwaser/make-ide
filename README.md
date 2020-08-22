# make-ide

GNU Make and Vim based micro IDE for the C programming language. Open project files, add module templates, compile and debug sources, run unit tests - all with a single make command. Tested on Ubuntu 18.04.


## Dependencies

Depends on Vim, Exuberant Ctags, Curl, and GCC. Install as follows under Ubuntu:
```bash
sudo apt-get install vim
sudo apt-get install build-essential
sudo apt-get install exuberant-ctags
sudo apt-get install curl
```


## Getting started

Put the makefile into an empty folder e.g. `project/` and type `make project` which will initialize a new project. Type `make module NAME=foo` to add source, header and unit test templates for your new foo module. Thereafter, type `make ide` to open all project sources in Vim and start coding. Use `make run` and/or `make debug` to test and debug your code (to debug unit tests run `make debug TEST=foo`). Use `make check` to run all unit tests. If they pass, add some more modules and code some more and have a happy day. Rinse and repeat.

## Commands

0.  `make`:		Compile module source files
1.  `make project`:	Set-up folder structure for new project (run in empty folder)
2.  `make module`:	Add source and header file templates for new module, e.g. make module NAME=foo
3.  `make ide`:		Open all project files as buffers in Vim (plus split plus fullscreen)
4.  `make check`:	Compile module and unit test source files and run unit tests
5.  `make run`:		Compile module source files and run main
6.  `make clean`:	Remove build folder (needed before switching between make run/debug)
7.  `make debug`:	Debug project or unit test sources, e.g. make debug TEST=foo
8.  `make profile`:	Generate main or unit test profiling information, e.g. make profile TEST=foo
9.  `make update`:	Replace local makefile between UPDATE markers with repo contents
10. `make help`:	List available commands and short descriptions thereof

	
### (1) make project

To start a new project, place the `makefile` into an empty folder e.g. `project/` and type `make project` into the terminal console. This will set up the following folder structure:

```bash
project/
├── incl/
│   └── check.h
├── makefile
├── src/
│   └── main.c
└── test/
```

where `check.h` contains a tiny header-only unit testing framework (see **make check** section).


### (2) make module

To add a module e.g. foo, type `make module NAME=foo` from within the project folder. This will add three new template files to the project. One for the module source, one for the header file, and one for the unit test source:


```bash
project/
├── incl/
│   ├── check.h
│   └── foo.h
├── makefile
├── src/
│   ├── main.c
│   └── foo.c
└── test/
    └── test_foo.c
```

Note that this will overwrite existing files if a new module is added with the same name. 


### (3) make ide

To start editing project files, type `make ide` into the console. This will open all project related source and header files in Vim with some basic Vim settings, analogue to the following command:

```bash
vim -c "set list nu et sta sts=2 ts=2 sw=2 tag | vsp | args **/*.c **/*.h <CR>"
```

In particular, this will add line numbering, use spaces as tabstops, set indentation to 2 spaces and start Vim in fullscreen and vertical split mode. Change as you see fit. However I suggest moving more extensive personalizations to a `vimrc` file. An interactive Vim tutorial can be found [here](https://www.openvim.com/).

Note that this also runs Exuberant Ctags via  `ctags -R .`, creating a `TAGS` file in the project root directory. To update the tags database from inside Vim use `:!ctags -R .` from the Vim command line. Some basic Vim Ctags commands are:


| **Vim command** | **Action** |
|:-:|:-:|
| Ctrl-]  | Jump to tag under cursor  |
| :ts <tag> <RET>  | Search for <tag>  |
| :ts  | List all definitions of last tag |
| :tn  | Go to the next/previous tag definition  |
| Ctrl-t  | Jump up the tag stack (go back) |


### (4) make check

Unit tests can be compiled and ran using the `make check` command. Note that `make module` will automatically add the following template, e.g. for `test/test_foo.c`:

```C
#include <stdlib.h>
#include <stdbool.h>

#include "check.h"
#include "foo.h"


static void
test_feature(void)
{
  check_assert(false);
}


int main(void)
{
  check_init("test_foo");
  check_run(test_feature);
  exit(EXIT_SUCCESS);
}
```

where test functions like `test_feature` can be added via
```C
check_run(void(*f)(void));
```

and assertions testet via
```C
check_assert(bool);
```


### (5) make run

Typing `make run` into the console will compile all project sources and run the executable generated from `main.c`.


### (6) make clean

Remove build folder, equal to command line `rm -rf build`.


### (7) make debug

Debug main or test sources with GDB by running `make debug` or `make debug TEST=foo`.


### (8) make profile

Generate profiling information in PROFILE text file by using the `gprof` utilty. Note that this has to compile and run the code before profiling infoformation can be created which might take some time. Use either on main or a module unit test via `make profile` or `make profile TEST=foo`.


### (9) make update

Replace the content of your local makefile between `###BEGIN-UPDATE` and `###END-UPDATE` with the latest `make-ide` repository makefile content between these markers.

### (10) make help

List available commands and short descriptions thereof.

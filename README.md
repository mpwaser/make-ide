# make-ide

GNU Make and VIM based micro IDE for the C programming language featuing simple commands to realize a simple terminal-only edit-compile-test development cycle. Linux-only (tested on Ubunutu 18.04). 


## Dependencies

Depends on VIM, exuberant ctags, and build-essentials which can be installed as follows (under Debian/Ubuntu):
```bash
sudo apt-get install vim
sudo apt-get install build-essential
sudo apt-get install exuberant-ctags
```


## Commands

1. make project: Set-up folder structure for new project 
2. make module: Add source and header file templates for new module 
3. make ide: Open all project files as buffers in Vim (plus split plus fullscreen)
4. make check: Compile module and unit test source files and run unit tests
5. make run: Compile module source files and run main


	
### make project

To start a new project, place the `makefile` into an empty folder e.g. `project/` and type `make project` into the terminal which will set up the following folder structure:

```bash
project/
├── incl/
│   └── check.h
├── makefile
├── src/
│   └── main.c
└── test/
```

where `check.h` contains a micro header-only unit testing framework (see `make check` command later on).

### make module

To add a module e.g. foo, type `make module NAME=foo` from within the project folder which will add three new template files to the project (module source, header file, and unit test source)


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


### make ide

Project files can be edited via `make ide`. This will open all project related source and header files in Vim. Additionally, this will set the following options (which can be found in the `makefile`):

```bash
vim -c "set list nu et sta sts=2 ts=2 sw=2 tag | vsp | args **/*.c **/*.h <CR>"
```

In particular, this will set tabstops and indentation to 2 spaces, as well as start Vim in fullscreen and vertical split mode. Change as you see fit, however I suggest moving more extensive personalizations to a `vimrc` file. An interactive Vim tutorial can be found [here](https://www.openvim.com/).

Note that this also runs exuberant ctags via  `ctags -R .` which will create a `TAGS` file in the project root directory. To update the tags database from inside Vim use `:!ctags -R .` from the Vim command line. Some basic commands are:


| **Vim command** | **Action** |
|:-:|:-:|
| Ctrl-]  | Jump to tag under cursor  |
| :ts <tag> <RET>  | Search for <tag>  |
| :ts  | List all definitions of last tag |
| :tn  | Go to the next/previous tag definition  |
| Ctrl-t  | Jump up the tag stack (go back) |

### make run

Compile project sources and execute main with time measurement, i.e. `make && time ./main`.

### make check

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
`check_run(void(*f)(void))`
```

and assertions testet via
```C
`check_assert(bool)`.
```




# make-ide

GNU Make and Vim based micro IDE for the C programming language. Open project files, add module templates, compile and debug sources, run unit tests - all with a single make command. Tested on Ubuntu 18.04.


## Dependencies

Depends on Vim, Ctags, Curl, and GCC. Install as follows under Ubuntu:
```bash
sudo apt-get install vim
sudo apt-get install build-essential
sudo apt-get install exuberant-ctags
sudo apt-get install curl
```


## Getting started

-  Put the makefile into an empty folder e.g. `project/`. Open a terminal window, navigate to this folder and type `make project`. This will initialize a new project including some folders and a main source file.
-  Type `make module NAME=foo` to add source, header and unit test templates for a new module called "foo".
-  Open a second terminal window (preferably on your second screen), navigate into your project folder and type `make ide`. This will open all project sources in Vim where you can now write the code for "main" and your "foo" module.
-  In the first terminal window, type `make run` and/or `make debug` to run and/or debug your code. Note that you might need to clean the build folder via `make clean` before `make debug` which will recompile with debugging symbols (and vice versa if you want `make run` to compile without debugging symbols). Use `make check` to run all unit tests (to check a single module, run `make check TEST=foo`). If you want to debug a spedific unit test, type `make debug TEST=foo`.

## Available commands

1.  `make project`:	Set-up folder structure for new project (run in empty folder)
2.  `make module`:	Add source and header file templates for new module, e.g. make module NAME=foo
3.  `make ide`:		Open all project files as buffers in Vim (plus split plus fullscreen)
4.  `make check`:	Compile module and unit test source files and run unit tests
5.  `make run`:		Compile module source files and run main
6.  `make clean`:	Remove build folder (needed before switching between make run/debug)
7.  `make debug`:	Debug project or unit test sources, e.g. make debug TEST=foo
8.  `make profile`:	Generate main or unit test profiling information, e.g. make profile TEST=foo
9.  `make update`:	Replace local makefile after the ###BEGIN-UPDATE marker with repo contents
10. `make help`:	List available commands and short descriptions thereof

	
### 1. make project

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


### 2. make module

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


### 3. make ide

To start editing project files, type `make ide` into the console. This will open all project related source and header files in Vim with some basic Vim settings, analogue to the following command:

```bash
vim -c "set list nu et sta sts=2 ts=2 sw=2 tag | vsp | args **/*.c **/*.h <CR>"
```

In particular, this will add line numbering, use spaces as tabstops, set indentation to 2 spaces and start Vim in fullscreen and vertical split mode. Change as you see fit. However I suggest moving more extensive personalizations to a `vimrc` file. An interactive Vim tutorial can be found [here](https://www.openvim.com/).

Note that this also runs Exuberant Ctags via  `ctags -R .`, creating a `tags` file in the project root directory. To update the tags database from inside Vim use `:!ctags -R .` from the Vim command line. Some basic Vim Ctags commands are:


| **Vim command** | **Action** |
|:-:|:-:|
| Ctrl-]  | Jump to tag under cursor  |
| :ts <tag> <RET>  | Search for <tag>  |
| :ts  | List all definitions of last tag |
| :tn  | Go to the next/previous tag definition  |
| Ctrl-t  | Jump up the tag stack (go back) |


### 4. make check

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


### 5. make run

Typing `make run` into the console will compile all project sources and run the executable generated from `main.c`.


### 6. make clean

Remove build folder, equal to command line `rm -rf build`.


### 7. make debug

Debug main or test sources with `gdb` by running `make debug` or `make debug TEST=foo`.


### 8. make profile

Generate profiling information in PROFILE text file by using the `gprof` utilty. Note that this has to compile and run the code before profiling infoformation can be created which might take some time. Use either on main or a module unit test via `make profile` or `make profile TEST=foo`.


### 9. make update

Replace the content of your local makefile after `###BEGIN-UPDATE` with the latest `make-ide` repository makefile content after this marker. This only has an effect if there were changes in the master branch of this respository, i.e. when a new version was released.

### 10. make help

List available commands and short descriptions thereof.

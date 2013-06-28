# CMake Project Support in Vim
[CMake](http://www.cmake.org) is the ONLY way you should be building your C or 
C++ projects. [Vim](http://www.vim.org) is the ultimate text editor. Together, 
along with the power of gray skull, CMake support in Vim is born.

[`cmake-support.vim`](https://github.com/jalcine/cmake-support.vim) is a Vim 
plugin that allows you to build your projects that are based on the CMake 
meta-build system.

## Requirements
> **NOTE**: This plugin has ONLY been tested on a bleeding edge version of Vim 
> 7.3 with `--features=huge`. Please report any problems you encounter with 
> version information and compilation options included.

At the time of writing, `cmake-support.vim` supports Vim 7.3+ and CMake 
2.8+. Have fun!

## Installing
I recommending using [Vundle](http://github.com/gmarik/vundle) to install 
plugins. The line necessary to add this plugin is as follows:

```viml
Bundle 'jalcine/android-dev.vim'
```

## Commands
Some of the more commonly used commands in the plugin include:

  + `:CMakeBuild` - invokes `make install` from the path prescribed by CMake.

## Options
In order for CMake to operate, it **has** to know where the build directory is 
located.

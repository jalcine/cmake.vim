# CMake Project Support in Vim
[CMake](http://www.cmake.org) is the ONLY way you should be building your C or 
C++ projects. [Vim](http://www.vim.org) is the ultimate text editor. Together, 
along with the power of gray skull, CMake support in Vim is born.

[`cmake-support.vim`](https://github.com/jalcine/cmake.vim) is a Vim 
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
Bundle 'jalcine/cmake.vim`
```

## Commands
Some of the more commonly used commands in the plugin include:

  + `:CMakeBuild` - invokes `make` from the path prescribed by CMake.
  + `:CMakeInstall` - invokes `make install` from the path prescribed by CMake.
  + `:CMakeTest` - invokes `make test` from the path prescribed by CMake.
  + `:CMakeGetVariable` - gets the specified variable in your `${CMAKE_BINARY_DIR}/CMakeCache.txt`
  + `:CMakeSetVariable` - sets the specified variable in your `${CMAKE_BINARY_DIR}/CMakeCache.txt`

## Options
In order for CMake to operate, it **has** to know where the build directory is 
located. This is done automatically by the plugin but it does need help in the 
event that you happen to build your CMake project in a sub-directory. This 
option and more are listed below.

  + `g:cmake_cxx_compiler`: Defines the default C++ compiler to build your 
    project with. (default: `clang++`)
  + `g:cmake_c_compiler`: Defines the default C compiler to build your project 
    with (default: `clang`)
  + `g:cmake_build_dirs`: Defines the names of directories at which 
    a directory would be searched for `CMakeCache.txt`. (default: [ 'build' ])
  + `g:cmake_build_type`: Defines the build configuration type of the project. 
    (default ['Debug'])
  + `g:cmake_install_prefix`: Defines the installation prefix to be used by 
    CMake. (default: $HOME/.local)

**NOTE**: These variables are defined by `cmake.vim` if the variable itself 
isn't found *before* it's loaded.

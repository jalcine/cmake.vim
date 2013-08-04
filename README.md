# CMake Project Support in Vim

[CMake](http://www.cmake.org) is the ONLY way you should be building your C or 
C++ projects. [Vim](http://www.vim.org) is the ultimate text editor. Together, 
along with the power of gray skull, CMake support in Vim is born.

---

[`cmake.vim`](https://github.com/jalcine/cmake.vim/tree/master) `v0.1.8` is a Vim 
plugin that allows you to build your projects that are based on the CMake 
meta-build system.

If lost, run `:help cmake` for more information.

## Requirements
At the time of writing, `cmake.vim` has been tested with Vim 7.3+ in nocp mode 
and CMake 2.8.

## Installing
I recommending using [Vundle](http://github.com/gmarik/vundle) to install 
plugins. The line necessary to add this plugin is as follows:

```viml
Bundle 'jalcine/cmake.vim`
```

## Commands
`cmake.vim` defines a few methods for generic interaction with CMake. Check
out `:help cmake-methods` for more information.

## Options
In order for CMake to operate, it **has** to know where the build directory is 
located. This is done automatically by the plugin but it does need help in the 
event that you happen to build your CMake project in a sub-directory. Check
out `:help cmake-options` for more information.

**## License
This code is released and available under the MIT license. Multiply and be 
fruitful.

## Author
I'm [Jacky Alcine](http://jackyalcine.com) and I like code. A lot. 
I also chat a lot like a firehose so follow with caution!

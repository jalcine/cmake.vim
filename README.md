# CMake Project Support in Vim

> [CMake](http://www.cmake.org) is the ONLY way you should be building your C or 
> C++ projects. [Vim](http://www.vim.org) is the ultimate text editor. Together, 
> along with the power of gray skull, CMake support in Vim is born.

---

[`cmake.vim`](https://github.com/jalcine/cmake.vim/tree/v0.2.0) `v0.2.0` is a Vim 
plugin that allows you to build your projects that are based on the CMake 
meta-build system.

If lost, run `:help cmake` for a bit of guidance.

## Requirements
At the time of writing, `cmake.vim` has been tested with Vim 7.3+ in nocp mode 
and CMake 2.8.

## Installing
I recommending using [Vundle](http://github.com/gmarik/vundle) to install 
plugins. The line necessary to add this plugin is as follows:

```viml
Bundle 'jalcine/cmake.vim`
```

## Getting Started

After you installed the plugin, just `cd` into the directory where the
top-level CMakeLists.txt can be found and run:

```viml
:CMakeCreateProject <build-dir-name>
:CMakeBuild
```

With that, you created (or re-configured in a vanilla-setup) a new binary
directory and built the project.

## Commands
`cmake.vim` defines a few methods for generic interaction with CMake. Check
out `:help cmake-methods` for more information.

## Options
In order for CMake to operate, it **has** to know where the build directory is 
located. This is done automatically by the plugin but it does need help in the 
event that you happen to build your CMake project in a sub-directory. Check
out `:help cmake-options` for more information.

## Integrations

See [`:help cmake-integrations`][doc/cmake.txt] for tips on integrations `cmake.vim` with
other plug-ins like `syntastic` or `YouCompleteMe`.

## Known Issues

  * You can't pass in options for configuring the project at first-run (or
    later on, actually). At the moment, you can *obtain* values from the cache
    by using `:CMakeGetVar`.

## To-Dos

  * Provide `:CMakeBuildTarget` that'd build the target provided. If a file is
    to be provided, find the target for that file and build the target it
    belongs to (restricted to source files).
    * Also for `:CMakeCleanTarget` since we can determine pre-target cleaning
      information.
  * Improve integration's use flag lookup and discovery on a per-target basis
    and a per-file basis (restricted to source files).
  * Pass an argument string to `:CMakeCreateBuild`.
  * Allow setting and getting values using `:CMakeGetVar` and `:CMakeSetVar`.
  * Expose `cmake.vim`'s buffer commands only in `worthy` buffers.

## License
This code is released and available under the MIT license. Multiply and be 
fruitful.

## Author
I'm [Jacky Alcine](http://jalcine.me) and I like code. A lot. 
I also chat a lot like a firehose so follow with caution!


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/jalcine/cmake.vim/trend.png)](https://bitdeli.com/free "Bitdeli Badge")


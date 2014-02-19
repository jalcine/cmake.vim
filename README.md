# [CMake Project Support in Vim][site]

> With the power of gray skull, [CMake][] support in Vim is born. This allows for
> CMake commands for building, installing, cleaning and invoking custom
> targets within Vim. It makes uses of [vimux][] if found and can provide
> integrations for [Syntastic][] and [YouCompleteMe][ycm].

---

[`cmake.vim 0.2.2`][release] is a Vim plugin that allows you to use [CMake][cmake]
within Vim for your projects. **This is alpha-grade software and may turn your CMake
project into a cat-overrun Telnet session**.

If lost, run `:help cmake` for a bit of guidance.

## Requirements
At the time of writing, `cmake.vim` has been tested with Vim 7.3+ in nocp mode 
and CMake 2.8.

## Installing
I recommending using [Vundle][vundle] to install plugins. The line necessary 
to add this plugin is as follows:

```viml
Bundle 'jalcine/cmake.vim`
```

## Getting Started

After you installed the plugin, just `cd` into the directory where the
top-level CMakeLists.txt can be found and run:

```viml
" Create a new binary directory for your clean project.
:CMakeCreateProject <build-dir-name>

" Build all of the targets.
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

See `:help cmake-integrations` for tips on integrations `cmake.vim` with
other plug-ins like [Syntastic][] or [YouCompleteMe][ycm]. Long story short, it's
freaking awesome but could use some work. With this version, the integrations are now
*target-specific*, allowing for fine-grained integration for every single
file.

## Known Issues

  * With the more recent changes to [YouCompleteMe][ycm]; it's become a bit
    difficult to dynamically add per-file flags. Right now, the best
    suggestion is to use the JSON compilation file in your `.ycm_extra_conf.py`
    to pass in *all of the flags* for your project.

  * Getting and setting variables is still rough around the edges.

## To-Dos

  * ~~Provide `:CMakeBuildTarget` that'd build the target provided. If a file is 
    to be provided, find the target for that file and build the target it
    belongs to (restricted to source files).~~
    **Implemented as :CMakeBuildCurrent**.
    * ~~Also for `:CMakeCleanTarget` since we can determine pre-target cleaning
      information.~~
  * ~~Improve integration's use flag lookup and discovery on a per-target basis
    and a per-file basis (restricted to source files).~~
  * ~~Pass an argument string to `:CMakeCreateBuild`.~~
  * Allow setting and getting values using `:CMakeGetVar` and `:CMakeSetVar`.
  * Expose `cmake.vim`'s buffer commands only in `worthy` buffers.

## License
This code is released and available under the MIT license. Multiply and be 
fruitful.

## Author
I'm [Jacky Alcine][jalcine] and I like code. A lot. I also chat a lot like a 
firehose so follow with caution!

[vundle]: https://github.com/gmarik/Vundle.vim
[cmake]: http://cmake.org
[syntastic]: https://github.com/scrooloose/syntastic
[ycm]: https://github.com/Valloric/YouCompleteMe/ 
[jalcine]: http://jalcine.me
[vimux]: https://github.com/benmills/vimux
[site]: http://jalcine.github.io/cmake.vim
[release]: https://github.com/jalcine/cmake.vim/tree/v0.2.2

class CMakeVim
  def initialize(args)
    @vim = args[:vim]
  end

  def create_new_project(args = {})
    args = args.merge({
      extra_lines: ''
    })

    @dir = Dir.mktmpdir
    Dir.chdir dir

    # TODO Make the root CMakeLists.txt file.
  end

  def configure_project(build_dir = 'build')
    # TODO Run CMake command for specified directory
    Dir.mkdir "#{@dir}/build"
    Dir.chdir "#{@dir}/build"

    PTY.spawn('cmake', %W[])

    `mkdir -p #{build_dir} && cd #{build_dir} && cmake ..`
  end

  def cd_into_project
    # TODO Move Vim into the current project's directory.

  end

  def destroy_project
    # TODO Delete this project's directory.

  end
end

class CMakeVim
  attr_reader :basep_path, :vim, :dir

  def initialize(args)
    @vim = args[:vim]
    @base_path = args[:base_path]
    @base_path = File.dirname(File.expand_path('../..', __FILE__))
  end

  # TODO Allow adding of lines to CMake file.
  def create_new_project(args = {})
    args = args.merge({
      extra_lines: '',
    })

    Dir.glob(@base_path + '/spec/data/**').each do | file |
      new_place = file.gsub(@base_path + '/spec/data/', '')
      FileUtils.copy(file, new_place)
    end
  end

  def configure_project(args = {})
    args = args.merge({
      build_dir: 'build',
      definitions: {},
    })

    definitions = []

    args.definitions.each do | key, value | 
      aDef = "-D#{key}=\"#{value}\""
      definitions.push aDef
    end

    definitions.join ' '

    Dir.mkdir "./build"
    `cd ./build && cmake .. #{definitions}`
  end

  def cd_into_project
    # TODO Move Vim into the current project's directory.

  end

  def destroy_project
    # TODO Delete this project's directory.

  end
end

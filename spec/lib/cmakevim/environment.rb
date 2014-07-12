require_relative '../cmakevim'

module CMakeVim::Environment
  class << self
    attr_accessor :vim_instance, :cmake_instance
  end

  private
  def spawn_vim_instance
    @vim_instance = Vimrunner.start
    add_plugin_to_vim 'plugin/cmake'
  end

  def create_cmake_object
    @cmake_instance = CMakeVim::Driver.new(vim: @vim_instance)
  end

  def add_plugin_to_vim(file)
    plugin_path = File.dirname(File.expand_path('../../../', __FILE__))
    @vim_instance.add_plugin(plugin_path, "#{file}.vim")
  end

  def vim
    spawn_vim_instance if @vim_instance.nil?
    @vim_instance
  end

  def cmake
    create_cmake_object if @cmake_instance.nil?
    @cmake_instance
  end

  def kill_vim
    @vim_instance.kill unless @vim_instance.nil?
    @vim_instance = nil
  end

  def cleanup_cmake
    cmake.destroy_project unless @cmake_instance.nil?
    @cmake_instance = nil
  end

end

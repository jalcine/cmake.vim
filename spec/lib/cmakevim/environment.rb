require_relative '../cmakevim'

module CMakeVim::Environment
  class << self
    attr_accessor :vim_instance, :cmake_instance
  end

  private
  def fresh_vim
    plugin_path = File.dirname(File.expand_path('../../../', __FILE__))
    @vim_instance = Vimrunner.connect('candy')
    @vim_instance.add_plugin(plugin_path, 'plugin/cmake.vim')
  end

  def fresh_cmake
    @cmake_instance = CMakeVim.new(vim: @vim_instance)
  end

  def vim
    fresh_vim if @vim_instance.nil?
    @vim_instance
  end

  def cmake
    fresh_cmake if @cmake_instance.nil?
    @cmake_instance
  end

  def kill_vim_session
  end

  def cleanup_cmake
    cmake.destroy_project unless cmake.nil?
    cmake = nil
  end

end

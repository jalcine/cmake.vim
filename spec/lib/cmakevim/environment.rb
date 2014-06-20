require_relative '../cmakevim'

module CMakeVim::Environment
  class << self
    attr_accessor :vim_instance, :cmake_instance
  end

  private
  def fresh_vim
    plugin_path = File.dirname(File.expand_path('../../../', __FILE__))
    @vim_instance = Vimrunner.start
    @vim_instance.add_plugin(plugin_path, 'plugin/cmake.vim')
  end

  def fresh_cmake
    @cmake_instance = CMakeVim.new(vim: self.vim)
  end

  def vim
    fresh_vim if @vim_instance.nil?
    @vim_instance
  end

  def cmake
    fresh_cmake if @vim_instance.nil?
    @cmake_instance
  end

end

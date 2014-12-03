require_relative '../cmakevim'

module CMakeVim
  module Environment
    class << self
      attr_accessor :cmake_instance
    end

    def create_cmake_object
      @cmake_instance = CMakeVim::Driver.new(vim: @vim)
    end

    def cmake
      create_cmake_object if @cmake_instance.nil?
      @cmake_instance
    end

    def cleanup_cmake
      cmake.destroy_project unless @cmake_instance.nil?
      @cmake_instance = nil
    end
  end
end

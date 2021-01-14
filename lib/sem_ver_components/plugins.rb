module SemVerComponents

  class Plugins

    # Constructor
    #
    # Parameters::
    # * *plugins_type* (Symbol): Plugins type we are parsing
    def initialize(plugins_type)
      @plugins_type = plugins_type
      @plugins = Hash[Dir.glob("#{__dir__}/#{plugins_type}/*.rb").map do |plugin_file|
        plugin_name = File.basename(plugin_file, '.rb').to_sym
        require "#{__dir__}/#{plugins_type}/#{plugin_name}.rb"
        [
          plugin_name,
          SemVerComponents.
            const_get(plugins_type.to_s.split('_').collect(&:capitalize).join.to_sym).
            const_get(plugin_name.to_s.split('_').collect(&:capitalize).join.to_sym)
        ]
      end]
    end

    # List available plugin names
    #
    # Result::
    # * Array<Symbol>: Available plugin names
    def list
      @plugins.keys
    end

    # Get a plugin class
    #
    # Parameters::
    # * *plugin_name* (Symbol): The plugin name
    # Result::
    # * Class: The corresponding plugin class
    def [](plugin_name)
      @plugins[plugin_name]
    end

  end

end

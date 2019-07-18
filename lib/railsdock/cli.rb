# frozen_string_literal: true

require 'thor'

module Railsdock
  # Handle the application command line parsing
  # and the dispatch to various command objects
  #
  # @api public
  class CLI < Thor
    # Error raised by this runner
    Error = Class.new(StandardError)

    desc 'version', 'railsdock version'
    def version
      require_relative 'version'
      puts "Railsdock v#{Railsdock::VERSION}"
    end
    map %w[--version -v] => :version

    desc 'install', 'Command description...'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    def install(*)
      if options[:help]
        invoke :help, ['install']
      else
        require_relative 'commands/install'
        Railsdock::Commands::Install.new(options).execute
      end
    end
  end
end

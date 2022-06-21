# frozen_string_literal: true

require 'forwardable'

module Railsdock
  class Command
    extend Forwardable

    def_delegators :command, :run

    # Execute this command
    #
    # @api public
    def execute(*)
      raise(
        NotImplementedError,
        "#{self.class}##{__method__} must be implemented"
      )
    end

    # The external commands runner
    #
    # @see http://www.rubydoc.info/gems/tty-command
    #
    # @api public
    def cmd
      require 'tty-command'
      TTY::Command.new
    end

    # File manipulation utility methods.
    #
    # @see http://www.rubydoc.info/gems/tty-file
    #
    # @api public
    def file
      require 'tty-file'
      TTY::File
    end

    # Terminal platform and OS properties
    #
    # @see http://www.rubydoc.info/gems/tty-platform
    #
    # @api public
    def platform
      require 'tty-platform'
      TTY::Platform.new
    end

    # The interactive prompt
    #
    # @see http://www.rubydoc.info/gems/tty-prompt
    #
    # @api public
    def prompt
      require 'tty-prompt'
      TTY::Prompt.new
    end

    def color
      require 'pastel'
      Pastel.new
    end
  end
end

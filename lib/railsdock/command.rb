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
    def command(**options)
      require 'tty-command'
      TTY::Command.new(options)
    end

    # The cursor movement
    #
    # @see http://www.rubydoc.info/gems/tty-cursor
    #
    # @api public
    def cursor
      require 'tty-cursor'
      TTY::Cursor
    end

    # The generating config files
    #
    # @see http://www.rubydoc.info/gems/tty-config
    #
    # @api public
    def config
      require 'tty-config'
      TTY::Config
    end

    # Open a file or text in the user's preferred editor
    #
    # @see http://www.rubydoc.info/gems/tty-editor
    #
    # @api public
    def editor
      require 'tty-editor'
      TTY::Editor
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
    def prompt(**options)
      require 'tty-prompt'
      TTY::Prompt.new(options)
    end

    def progress(*options)
      require 'tty-progressbar'
      TTY::ProgressBar.new(*options)
    end

    def color
      require 'pastel'
      Pastel.new
    end
  end
end

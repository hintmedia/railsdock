# frozen_string_literal: true
require 'erb'
require_relative '../command'
require_relative '../logo'

module Railsdock
  MEMORY_STORE_OPTIONS = %i[memcached redis].freeze
  DB_OPTIONS = %i[mysql postgres].freeze
  POST_INSTALL_MESSAGE = <<-MESSAGE
  OK
  MESSAGE
  module Commands
    class Install < Railsdock::Command
      def initialize(options)
        @options = options
        @variables = OpenStruct.new(
          is_windows?: platform.windows?,
          is_mac?: platform.mac?,
          uid: cmd.run('id -u')
        )
      end

      def execute(input: $stdin, output: $stdout)
        output.puts Railsdock::Logo.call
        @variables[:dockerfile_dir] = prompt_for_dockerfile_directory
        copy_default_files
        service_hash = collect_service_selections
        service_hash.each do |type, service|
          output.puts(type, service)
          # file.copy_file("./lib/railsdock/templates/install/#{service}/Dockerfile", [@variables.dockerfile_dir, service, "/Dockerfile"].join)
          # inject_driver_config(service)
          # append_erb_to_file(service)
        end
        prompt_for_db_yml_override
        output.puts Railsdock::POST_INSTALL_MESSAGE
      end

      private

      def prompt_for_db_yml_override
        prompt.ask?
      end

      def collect_service_selections
        prompt.collect do
          key(:database).select('Select the Database used by your application:', Railsdock::DB_OPTIONS)
          key(:mem_store).select('Select')
        end
      end

      def inject_driver_config(service)
        file.inject_into_file('./docker-compose.yml', after: "  node_modules:\n    driver: ${VOLUMES_DRIVER}\n") do
          <<-YAML
  #{service}:
    driver: ${VOLUMES_DRIVER}
          YAML
        end
      end

      def append_erb_to_file(service)
        file.append_to_file('./docker-compose.yml') do
          version = ERB.version.scan(/\d+\.\d+\.\d+/)[0]
          source_path = "./lib/railsdock/templates/install/#{service}/docker-compose.yml.erb"
          template = if version.to_f >= 2.2
                        ERB.new(::File.binread(source_path), trim_mode: '-', eoutvar: '@output_buffer')
                      else
                        ERB.new(::File.binread(source_path), nil, '-', '@output_buffer')
                      end
          template.result(@variables.instance_eval('binding'))
        end
      end

      def prompt_for_dockerfile_directory
        prompt.ask('Where would you like your docker container configuration files to live?') do |q|
          q.default './docker/'
          q.validate(%r{\.\/[A-z\/]+\/})
          q.modify :remove
          q.messages[:valid?] = 'Invalid directory path (should start with ./ and end with /)'
        end
      end

      def copy_default_files
        Dir['./lib/railsdock/templates/install/default/*'].each do |path|
          file.copy_file(path, destination_file(File.basename(path)), context: @variables)
        end
      end

      def destination_file(filename)
        case filename
        when 'Dockerfile'
          "#{@variables.dockerfile_dir}ruby/Dockerfile"
        when 'docker-compose.yml.erb'
          './docker-compose.yml'
        when 'example.env.erb'
          './.env.railsdock'
        else
          "./#{filename}"
        end
      end
    end
  end
end

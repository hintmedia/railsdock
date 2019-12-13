# frozen_string_literal: true

require 'ostruct'
require 'erb'
require 'rails'
require_relative '../command'
require_relative '../logo'

module Railsdock
  module Commands
    class Install < Railsdock::Command
      OPTIONS_HASH = {
        database: {
          name: 'Database',
          options: %i[mysql postgres]
        },
        mem_store: {
          name: 'In-Memory Store',
          options: %i[memcached redis]
        }
      }.freeze

      POST_INSTALL_MESSAGE = 'Railsdock successfully installed'.freeze

      BASE_TEMPLATE_DIR = './lib/railsdock/templates/install'.freeze

      def initialize(options)
        @options = options
        @variables = OpenStruct.new(
          app_name: options[:app_name] || Rails.application.engine_name.gsub(/_application/, ''),
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
          file.copy_file("#{BASE_TEMPLATE_DIR}/#{service}/Dockerfile", [@variables.dockerfile_dir, service, "/Dockerfile"].join)
          inject_driver_config(service)
          append_erb_to_compose_file(service)
          copy_db_yml("#{BASE_TEMPLATE_DIR}/#{service}/database.yml.erb") if type == :database
        end
        output.puts Railsdock::POST_INSTALL_MESSAGE
      end

      private

      def copy_db_yml(erb_file)
        file.copy_file(erb_file, Rails.root.join('config'), context: @variables)
      end

      def collect_service_selections
        prompt.collect do
          OPTIONS_HASH.each do |key, value|
            key(key).select("Select the #{value[:name]} used by your application:", value[:options])
          end
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

      def generate_erb(source_path)
        template = if ERB.version.scan(/\d+\.\d+\.\d+/)[0].to_f >= 2.2
                     ERB.new(::File.binread(source_path), trim_mode: '-', eoutvar: '@output_buffer')
                   else
                     ERB.new(::File.binread(source_path), nil, '-', '@output_buffer')
                   end
        template.result(@variables.instance_eval('binding'))
      end

      def append_erb_to_compose_file(service)
        file.append_to_file('./docker-compose.yml') do
          generate_erb("#{BASE_TEMPLATE_DIR}/#{service}/docker-compose.yml.erb")
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
        Dir["#{BASE_TEMPLATE_DIR}/default/*"].each do |path|
          destination_file(path)
        end
      end

      def destination_file(path)
        case File.basename(path)
        when 'Dockerfile'
          file.copy_file(path, "#{@variables.dockerfile_dir}ruby/Dockerfile", context: @variables)
        when 'docker-compose.yml.erb'
          file.copy_file(path, './docker-compose.yml', context: @variables)
        when 'example.env.erb'
          file.append_to_file('./.env', generate_erb("#{BASE_TEMPLATE_DIR}/default/example.env.erb")
        else
          "./#{filename}"
        end
      end
    end
  end
end

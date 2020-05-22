# frozen_string_literal: true

require 'ostruct'
require 'erb'
require 'bundler'
require_relative '../command'
require_relative '../logo'

module Railsdock
  module Commands
    class Install < Railsdock::Command
      OPTIONS_HASH = {
        database: {
          name: 'Database',
          options: %i[postgres mysql],
          default_port: {
            postgres: 5432,
            mysql: 3306
          }
        },
        mem_store: {
          name: 'In-Memory Store',
          options: %i[redis memcached]
        }
      }.freeze

      POST_INSTALL_MESSAGE =<<~PIM
      Railsdock successfully installed

      Run `docker-compose build` then `docker-compose up` to start your app,

      PIM

      BASE_TEMPLATE_DIR = File.expand_path("#{__dir__}/../templates/install").freeze

      def initialize(options)
        @options = options
        @variables = OpenStruct.new(
          app_name: options[:app_name] || get_app_name,
          is_windows?: platform.windows?,
          is_mac?: platform.mac?,
          uid: cmd.run('id -u').out.chomp,
          ruby_version: get_ruby_version
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
          file.inject_into_file('./docker-compose.yml', "\n  #{service}:", after: "\nvolumes:")
          append_service_config_to_env(service)
          if type == :database
            copy_db_yml("#{BASE_TEMPLATE_DIR}/#{service}/database.yml.erb")
            inject_db_script_into_entrypoint(service)
          end
        end
        cmd.run('chmod +x ./docker/ruby/entrypoint.sh')
        output.puts POST_INSTALL_MESSAGE
      end

      private

      def get_app_name
        ::File.open('./config/application.rb').read.match(/module (.+)\s/)[1].downcase
      end

      def get_ruby_version
        ::Bundler.definition.ruby_version.versions[0] || RUBY_VERSION
      end

      def copy_db_yml(erb_file)
        file.copy_file(erb_file, './config/database.yml', context: @variables)
      end

      def inject_db_script_into_entrypoint(service)
        file.inject_into_file('./docker/ruby/entrypoint.sh', after: "echo \"DB is not ready, sleeping...\"\n") do
          <<~BASH
            until nc -vz #{service} #{OPTIONS_HASH[:database][:default_port][service]}; do
              sleep 1
            done
          BASH
        end
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
          <<~YAML
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

      def create_or_append_to_file(source_path, destination_path)
        if ::File.exist?(destination_path) && generate_erb(source_path) != ::File.binread(destination_path)
          file.safe_append_to_file(destination_path, generate_erb(source_path))
        else
          file.copy_file(source_path, destination_path, context: @variables)
        end
      end

      def append_erb_to_compose_file(service)
        file.safe_append_to_file('./docker-compose.yml') do
          generate_erb("#{BASE_TEMPLATE_DIR}/#{service}/docker-compose.yml.erb")
        end
        file.inject_into_file('./docker-compose.yml', "    - #{service}\n", after: "depends_on:\n")
      end

      def append_service_config_to_env(service)
        file.safe_append_to_file('./.env') do
          ::File.binread("#{BASE_TEMPLATE_DIR}/#{service}/#{service}.env")
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
        when 'entrypoint.sh'
          file.copy_file(path, "#{@variables.dockerfile_dir}ruby/entrypoint.sh", context: @variables)
        when 'docker-compose.yml.erb'
          file.copy_file(path, './docker-compose.yml', context: @variables)
        when 'default.env.erb'
          create_or_append_to_file(path, './.env')
        else
          file.copy_file(path, "./#{File.basename(path)}", context: @variables)
        end
      end
    end
  end
end

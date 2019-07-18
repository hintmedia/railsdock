# frozen_string_literal: true
require 'pry'
require 'erb'
require_relative '../command'
require_relative '../logo'

module Railsdock
  CONTAINER_OPTIONS = %i[memcached mysql postgres redis].freeze
  module Commands
    class Install < Railsdock::Command
      def initialize(options)
        @options = options
        @variables = OpenStruct.new(
          is_windows?: platform.windows?,
          is_mac?: platform.mac?
        )
      end

      def execute(input: $stdin, output: $stdout)
        output.puts Railsdock::Logo.call
        @variables[:dockerfile_dir] = prompt.ask('Where would you like your docker container configuration files to live?') do |q|
          q.default './docker/'
          q.validate(%r{\.\/[A-z\/]+\/})
          q.modify :remove
          q.messages[:valid?] = 'Invalid directory path (should start with ./ and end with /)'
        end
        Dir['./lib/railsdock/templates/install/default/*'].each do |path|
          file.copy_file(path, destination_file(File.basename(path)), context: @variables)
        end
        prompt
          .multi_select('Select services below:', Railsdock::CONTAINER_OPTIONS)
          .each do |service|
            file.copy_file("./lib/railsdock/templates/install/#{service}/Dockerfile", [@variables.dockerfile_dir, service, "/Dockerfile"].join)
            file.inject_into_file('./docker-compose.yml', after: "  node_modules:\n    driver: ${VOLUMES_DRIVER}\n") do
              <<-YAML
  #{service}:
    driver: ${VOLUMES_DRIVER}
              YAML
            end
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
        output.puts 'OK'
      end

      private

      def destination_file(filename)
        case filename
        when 'Dockerfile'
          "#{@variables.dockerfile_dir}ruby/Dockerfile"
        when 'docker-compose.yml.erb'
          './docker-compose.yml'
        when 'example.env.erb'
          './.env.railsdock'
        end
      end
    end
  end
end

require 'sinatra/base'
require 'open3'

module Iuno
  # Converters
  class HamlConverter
    CONVERTERS = %i(herbalizer haml_gem).freeze

    def initialize(input, converter_name)
      # We need newline at end for herbalizer
      @input = "#{input.force_encoding('UTF-8').gsub(/\r?\n/, "\n")}\n"
      @converter = converter_name.to_sym
    end

    def render
      unless CONVERTERS.include?(@converter)
        raise StandardError, "Unknown converter #{converter}"
      end
      begin
        send(@converter)
      rescue StandardError => e
        raise StandardError,
              "#{e.message}#{herbalizer? ? '' : "\nAt #{e.backtrace[0]}"}"
      end
    end

    private

    def herbalizer?
      @converter == :herbalizer
    end

    def herbalizer
      html, status = Open3.capture2e('vendor/herbalizer', stdin_data: @input)
      unless status.success? && (html =~ /\A\(line\s\d+\,\scolumn\s\d+\):/).nil?
        raise StandardError, html
      end
      html
    end

    def haml_gem
      engine = Haml::Engine.new(@input, suppress_eval: true, ugly: false)
      engine.render
    end
  end
end

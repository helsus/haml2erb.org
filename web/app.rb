require 'bundler'
require 'sinatra/base'
require 'newrelic_rpm' if Sinatra::Application.production?
require 'tilt/erubis'

ENV['RACK_ENV'] ||= 'development'

Bundler.require(:default, ENV['RACK_ENV'].to_sym)

require 'sinatra/json'
require 'sinatra/content_for'
require 'haml_converter'

module Iuno
  module Web
    # Old-style API
    class LegacyAPI < Sinatra::Base
      # Legacy API
      post(/api\.(html|json)/) do |format|
        erb = begin
          HamlConverter.new(params[:haml] || '',
                            params[:converter] || :herbalizer).render
        rescue StandardError => error
          error.message
        end
        case format
        when 'json'
          content_type :json
          MultiJson.dump(erb)
        else
          content_type :text
          erb
        end
      end
    end

    # Web API
    class API < Sinatra::Base
      post '/convert' do
        begin
          json success: true,
               erb: HamlConverter.new(params[:haml] || '',
                                      params[:converter] || :herbalizer).render
        rescue StandardError => error
          status 422
          json success: false, error: error.message
        end
      end
    end

    # Web Site
    class App < Sinatra::Base
      set :root, File.dirname(__FILE__)
      set :views, File.join(root, 'templates')
      set :public_folder, File.join(root, 'public')
      set :protection, except: [:frame_options, :xss_header]

      configure :production do
        use HtmlCompressor::Rack
        disable :static
      end

      helpers ActionView::Helpers::FormOptionsHelper
      helpers ActionView::Helpers::FormTagHelper
      helpers ERB::Util
      helpers Sinatra::ContentFor

      before do
        # Disable Chromium XSSAuditor
        headers['X-XSS-Protection'] = '0;'
      end

      get '/' do
        erb :form
      end

      post '/' do
        begin
          @erb = HamlConverter.new(params[:haml], params[:converter]).render
        rescue StandardError => error
          @erb = error.message
        end

        erb :form
      end

      get '/api-reference' do
        erb :api_reference
      end
    end
  end
end

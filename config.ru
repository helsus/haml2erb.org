$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')

require './web/app'

app = Rack::Builder.new do
  map '/' do
    run Rack::Cascade.new([Iuno::Web::App, Iuno::Web::LegacyAPI])
  end

  map '/api' do
    run Iuno::Web::API
  end
end

run app

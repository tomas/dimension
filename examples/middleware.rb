ROOT = File.expand_path(File.dirname(__FILE__))

require 'thin'
require 'rack/builder'
require 'rack/static'

require ROOT + '/../lib/dimension'
require ROOT + '/../lib/dimension/middleware'

app = Rack::Builder.new do

  # root = File.join(ROOT, 'assets')
  root = ROOT

  use Rack::CommonLogger

  use Dimension::Middleware, { :root => root, :throttle => 1, :save => false }

  use Rack::Static,
    :urls => ['/'],
    :root => root

  run lambda { |env|
    [ 200, { 'Content-Type'  => 'text/html'}, ['Not Found.'] ]
  }

end

Thin::Server.start('0.0.0.0', 4567, app.to_app)

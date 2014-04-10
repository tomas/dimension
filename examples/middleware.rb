ROOT = File.expand_path(File.dirname(__FILE__))

require 'thin'
require 'rack/builder'
require 'rack/static'

require ROOT + '/../lib/dimension'
require ROOT + '/../lib/dimension/middleware'

app = Rack::Builder.new do

  root = File.join(ROOT, 'assets')

  use Dimension::Middleware, { :root => root }

  use Rack::Static,
    :urls => ['/'],
    :root => root

  run lambda { |env|
    [ 200, { 'Content-Type'  => 'text/html'}, ['Not Found.'] ]
  }

end.to_app

Thin::Server.start('0.0.0.0', 4567, app)

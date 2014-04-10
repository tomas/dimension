require 'rack/throttle'

module Dimension

  class Middleware
  
    EXCEEDED = [403, {'Content-Type' => 'text/plain'}, ['Limit Exceeded.']]
  
    def initialize(app, opts = {})
      @app  = app
      @root = File.expand_path(opts[:root] || Dir.pwd())
      @save = opts[:save]
      
      if opts[:throttle]
        @throttle = Rack::Throttle::Interval.new(self, :min => opts[:throttle])
      end
    end
  
    def call(env)
      url      = env['PATH_INFO']
      geometry = url[/-([0-9x:-]+)\.(png|gif|jpe?g)/, 1]
      
      return @app.call(env) unless geometry

      resized  = File.join(@root, url)
      original = resized.sub("-#{geometry}", '')
    
      if !File.exist?(resized) and File.exist?(original)
        
        if @throttle
          req = Rack::Request.new(env)
          return EXCEEDED unless @throttle.allowed?(req)
        end
        
        # puts 'Processing image: ' + file
        image = Dimension.open(original)
        image.generate(geometry) do
          image.save_as(resized) if @save
          return image.to_response
        end
      end

      @app.call(env)
    rescue ArgumentError => e # Dimension::Error
      # puts "Error processing image: #{e.message}"
      @app.call(env)
    end
  
  end

end
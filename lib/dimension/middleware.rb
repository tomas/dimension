class Middleware
  
  FORMATS = ['.jpg', '.png', '.gif', '.jpeg']
  
  def initialize(app, opts = {})
    @app  = app
    @root = File.expand_path(opts[:root] || Dir.pwd())
  end
  
  def call(env)
    url      = env['PATH_INFO']
    query    = env['QUERY_STRING']
    geometry = query && query[/geometry=([^\&|$]+)/, 1]
    
    if geometry and ext = File.extname(url) and ext != '' and FORMATS.include?(ext.downcase)
      file = File.join(@root, url)
      # puts 'Processing image: ' + file
      
      image = Dimension.open(file)
      image.generate(geometry) do
        image.to_response
      end
    end

    @app.call(env)
  rescue ArgumentError => e # Dimension::Error
    # puts "Error processing image: #{e.message}"
    @app.call(env)
  end
  
end
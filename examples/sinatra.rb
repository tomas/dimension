ROOT = File.expand_path(File.dirname(__FILE__))

require 'sinatra'
require ROOT + '/../lib/dimension'

get '/' do
  images = Dir.glob(File.join(ROOT, 'assets') + '/*')
  links = images.map do |i|
    name = File.basename(i)
    "<a href='/images/#{name}?geometry=200x200'>#{name}</a>"
  end
  '<ul><li>' + links.join('</li><li>') + '</li></ul>'
end

get '/images/:file' do
  file = File.join(ROOT, 'assets', params[:file])

  if params[:geometry].nil?
    puts "Returning original file: #{file}"
    return send_file file
  end

  begin
    thumb = Dimension.open(file)
  rescue => e
    return e.message
  end

  thumb.generate(params[:geometry]) do
    thumb.to_response
  end
end

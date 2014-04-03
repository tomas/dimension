ROOT = File.expand_path(File.dirname(__FILE__))

require 'sinatra'
require ROOT + '/../lib/resizer'

get '/' do
  images = Dir.glob(File.join(ROOT, 'assets') + '/*')
  links = images.map do |i|
    name = File.basename(i)
    "<a href='/images/#{name}'>#{name}</a>"
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
    thumb = Resizer.open(file)
  rescue => e
    return e.message
  end

  thumb.generate(params[:geometry]) do
    @out = thumb.to_response
  end

  @out
end

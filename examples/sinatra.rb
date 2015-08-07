ROOT = File.expand_path(File.dirname(__FILE__))

require 'sinatra'
require ROOT + '/../lib/dimension'

if processor = ARGV[0]
  puts "Using #{processor} as processor"
  Dimension.processor = processor
end

geometries = [
  '200x200',
  '300x200!',
  '200x300#',
  '20x50:ne'
]

get '/' do
  images = Dir.glob(File.join(ROOT, 'assets') + '/*')
  index = 0
  links = images.map do |i|
    name = File.basename(i)
    geom = geometries[index]
    index += 1
    index = 0 unless geometries[index]
    "<a href='/images/#{name}?geometry=#{geom}'>#{name}</a>"
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

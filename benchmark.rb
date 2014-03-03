require './lib/thumbnail'
require 'benchmark'

file = ARGV[0] or abort('File needed')
geometry = ARGV[1] or abort('Geometry required: 100x100#ne')

out = "#{File.basename(file)}.out#{File.extname(file)}"
puts "Processing #{file}"

Benchmark.bm do |x|

  x.report do
    Thumbnail.processor = 'imlib2'
    b = Thumbnail.new(file)
    res = b.crop(geometry)
    puts res.inspect
  end

  sleep 1

  x.report do
    Thumbnail.processor = 'image_magick'
    a = Thumbnail.new(file)
    res = a.crop(geometry)
    puts res.inspect
  end

end

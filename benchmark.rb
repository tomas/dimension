require './lib/dimension'
require 'benchmark'

file = ARGV[0] or abort('File needed')
geometry = ARGV[1] or abort('Geometry required: 100x100#ne')

out = "#{File.basename(file)}.out#{File.extname(file)}"
puts "Processing #{file}"

Benchmark.bm do |x|

  x.report do
    Dimension.processor = 'imlib2'
    a = Dimension.open(file)
    res = a.generate!(geometry)
    puts res.inspect
  end

  sleep 1

  x.report do
    Dimension.processor = 'image_magick'
    b = Dimension.open(file)
    res = b.generate!(geometry)
    puts res.inspect
  end

end

require './lib/dimension'
require 'benchmark'

file = ARGV[0] or abort('File needed')
geometry = ARGV[1] or abort('Geometry required: 100x100')

ext  = File.extname(file)
base = File.basename(file, ext)
puts "Processing #{file}"

Benchmark.bm do |x|

  begin
    Dimension.processor = 'imlib2'
    x.report do
      a = Dimension.open(file)
      res = a.generate!(geometry, [base, '-imlib2', ext].join)
      puts res.inspect
    end
  rescue LoadError
    puts "imlib2 missing."
  end

  sleep 1

  begin
    Dimension.processor = 'image_magick'
    x.report do
      b = Dimension.open(file)
      res = b.generate!(geometry, [base, '-image_magick', ext].join)
      puts res.inspect
    end
  rescue LoadError => e
    puts "imagemagick missing."
  end

  sleep 1

  begin
    Dimension.processor = 'vips'
    x.report do
      b = Dimension.open(file)
      res = b.generate!(geometry, [base, '-vips', ext].join)
      puts res.inspect
    end
  rescue LoadError => e
    puts "vips missing."
  end

end

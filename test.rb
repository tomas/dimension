require './lib/dimension'
require 'benchmark'

file    = ARGV[0] or abort('File needed. Try with examples/assets/chair.jpg')
geometry = ARGV[1] or abort('Geometry required. Example: 100x100')

# Dimension.processor = 'imlib2'
# Dimension.processor = 'image_magick'

thumb = Dimension.open(file)

# thumb.crop(geometry) do |res|
  # puts thumb.format
  # puts res.inspect
  # puts thumb.image_data
# end

res = thumb.generate(geometry)
puts res.inspect

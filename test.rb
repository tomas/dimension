require './lib/thumbnail'
require 'benchmark'

file = ARGV[0] or abort('File needed')
geometry = ARGV[1] or abort('Geometry required: 100x100#ne')

Thumbnail.processor = 'imlib2'
# Thumbnail.processor = 'image_magick'

thumb = Thumbnail.new(file)

# thumb.crop(geometry) do |res|
  # puts thumb.format
  # puts res.inspect
  # puts thumb.image_data
# end

res = thumb.generate!(geometry)
puts res.inspect

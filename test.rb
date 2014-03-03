require './lib/thumbnail'
require 'benchmark'

file = ARGV[0] or abort('File needed')
geometry = ARGV[1] or abort('Geometry required: 100x100#ne')

Thumbnail.processor = 'imlib2'
thumb = Thumbnail.new(file)
res = thumb.crop(geometry)
puts res.inspect

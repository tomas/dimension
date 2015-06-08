require File.expand_path(File.dirname(__FILE__)) + '/dimension/image'
# require 'dimension/image'

module Dimension

  ROOT = File.expand_path(File.dirname(__FILE__))

  PROCESSORS = {
    'imlib2' => 'Imlib2Processor',
    'image_magick' => 'ImageMagickProcessor'
  }

  def self.processor
    @processor
  end

  def self.processor=(name)
    @processor = PROCESSORS[name] or raise "Processor not found: #{name}"
    # require File.join(ROOT, 'dimension', 'processors', name)
    require_relative "dimension/processors/#{name}"
    Image.include(Kernel.const_get(@processor))
  end

  def self.open(file)
    Image.new(file)
  end

end

begin
  require 'imlib2'
  Dimension.processor = 'imlib2'
rescue LoadError
  out = `convert -h`
  if $?.success?
    Dimension.processor = 'image_magick'
  else
    puts "No available processors found. Please install ruby-imlib2 or ImageMagick."
  end
end

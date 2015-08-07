require File.expand_path(File.dirname(__FILE__)) + '/dimension/image'
# require 'dimension/image'

module Dimension

  ROOT = File.expand_path(File.dirname(__FILE__))

  PROCESSORS = {
    'vips' => 'VipsProcessor',
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

def load_processor(name)
  # puts "Loading #{name}"
  require name
  Dimension.processor = name
  true
rescue LoadError => e
  # puts "#{name} not found."
  nil
end

unless load_processor 'vips'
  unless load_processor 'imlib2'
    out = `which convert`
    if $?.success?
      Dimension.processor = 'image_magick'
    else
      puts "No available processors found. Please install ruby-vips, ruby-imlib2 or ImageMagick."
    end
  end
end

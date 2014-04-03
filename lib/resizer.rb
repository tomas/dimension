require File.expand_path(File.dirname(__FILE__)) + '/image'

module Resizer 

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
    require File.join(ROOT, 'processors', name)
    Image.include(Kernel.const_get(@processor))
  end
  
  def self.open(file)
    Image.new(file)
  end
  
end

begin
  require 'imlib2'
  Resizer.processor = 'imlib2'
rescue LoadError
  if system("convert -h")
    Resizer.processor = 'image_magick'
  else
    puts "No available processors found. Please install ruby-imlib2 or ImageMagick."
  end
end

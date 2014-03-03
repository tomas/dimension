require 'fileutils'

class Thumbnail

  PROCESSORS = {
    'imlib2' => 'Imlib2Processor',
    'image_magick' => 'ImageMagickProcessor'
  }

  GRAVITIES = {
    'nw' => 'NorthWest',
    'n'  => 'North',
    'ne' => 'NorthEast',
    'w'  => 'West',
    'c'  => 'Center',
    'e'  => 'East',
    'sw' => 'SouthWest',
    's'  => 'South',
    'se' => 'SouthEast'
  }

  # Geometry string patterns
  RESIZE_GEOMETRY         = /^(\d+)?x(\d+)?[><%^!]?$|^\d+@$/ # e.g. '300x200!'
  CROPPED_RESIZE_GEOMETRY = /^(\d+)x(\d+)#(\w{1,2})?$/ # e.g. '20x50#ne'
  CROP_GEOMETRY           = /^(\d+)x(\d+)([+-]\d+)?([+-]\d+)?(\w{1,2})?$/ # e.g. '30x30+10+10'

  def self.processor
    @processor
  end

  def self.processor=(name)
    @processor = PROCESSORS[name] or raise "Processor not found: #{name}"
    require "./lib/processors/#{name}"
    self.include(Kernel.const_get(@processor))
  end

  attr_reader :file

  def initialize(file, options = {})
    @file = File.expand_path(file)
    log "File loaded: #{file}. Geometry: #{geometry.join('x')}"
  end

  def crop(geometry, output_file = nil)
    @output_file = output_file || "/tmp/thumb-#{File.basename(file)}"

    case geometry
    when RESIZE_GEOMETRY
      log "Resize: #{$1}x#{$2}"
      resize($1, $2)
    when CROPPED_RESIZE_GEOMETRY
      log "Resize and crop: width: #{$1}, height: #{$2}, gravity: #{$3}"
      resize_and_crop($1, $2, $3)
    when CROP_GEOMETRY
      log "Crop: width: #{$1}, height: #{$2}, x: #{$3}, y: #{$4}, gravity: #{$5}"
      crop($1, $2, $3, $4, $5)
    else
      raise ArgumentError, "Didn't recognise the geometry string #{geometry}"
    end

    save(output_file)
  end

  def save(out_file)
    new_geometry = get_new_geometry

    if out_file.nil?
      out_file = file.sub(File.extname(file), '-' + new_geometry.join('x') + File.extname(file))
    end

    log "Writing file: #{out_file}"
    save_as(out_file)
    close

    {:file => out_file, :width => new_geometry[0], :height => new_geometry[1]}
  end

  def log(msg)
    puts "[Thumbnail::#{self.class.processor}] #{msg}"
  end

  def to_response(env)
    [200, {'Content-Type' => "image/#{format}"}, image_data]
  end

end

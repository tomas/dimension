require 'fileutils'

module Resizer

class Image

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

  attr_reader :file

  def initialize(file)
    if self.class.processor.nil?
      raise "No processor set! Please set Thumbnail.processor = 'imlib' or 'image_magick'"
    end

    @file = File.expand_path(file)
    raise ArgumentError, "File not found: #{@file}" unless File.exist?(@file)
    log "File loaded: #{file}. Geometry: #{geometry.join('x')}"
  end

  def generate(geometry, &block)
    new_geometry = resize_to(geometry)
    yield({:width => new_geometry[0], :height => new_geometry[1]}) if block_given?
    close && self
  end

  def generate!(geometry, output_file = nil)
    resize_to(geometry)
    save(output_file)
  end

  def resize_to(geometry)
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
    get_new_geometry
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
    puts "[Resizer::#{Resizer.processor}] #{msg}"
  end

  def to_response(env = nil)
    [200, {'Content-Type' => "image/#{format}"}, image_data]
  end

end

end

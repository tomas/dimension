require 'fileutils'

module Dimension

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
  CROPPED_RESIZE_GEOMETRY = /^(\d+)x(\d+)[:|#](\w{1,2})?$/ # e.g. '20x50:ne'
  CROP_GEOMETRY           = /^(\d+)x(\d+)([+-]\d+)?([+-]\d+)?(\w{1,2})?$/ # e.g. '30x30+10+10'

  attr_reader :file

  def initialize(file)
    unless Dimension.processor
      raise "No processor set! Please set Dimension.processor = 'imlib2' or 'image_magick'"
    end

    @file = File.expand_path(file)
    @name = File.basename(file)
    @path = File.dirname(@file)

    raise ArgumentError, "File not found: #{@file}" unless File.exist?(@file)
    log "File loaded: #{file}. Geometry: #{geometry.join('x')}"
  end

  def generate(geometry, &block)
    new_geometry = resize_to(geometry)
    if block_given?
      out = yield(new_geometry)
      close
    end
    out || self
  end

  def generate!(geometry, output_file = nil)
    resize_to(geometry)
    save(output_file) && self
  end

  def resize_to(geometry)
    case geometry
      when RESIZE_GEOMETRY
        log "Resize -- #{$1}x#{$2}"
        resize($1, $2)
      when CROPPED_RESIZE_GEOMETRY
        log "Resize and crop -- width: #{$1}, height: #{$2}, gravity: #{$3}"
        resize_and_crop($1, $2, $3)
      when CROP_GEOMETRY
        log "Crop -- width: #{$1}, height: #{$2}, x: #{$3}, y: #{$4}, gravity: #{$5}"
        crop($1, $2, $3, $4, $5)
      else
        raise ArgumentError, "Didn't recognise the geometry string #{geometry}"
    end

    new_geometry = get_new_geometry
    {:width => new_geometry[0], :height => new_geometry[1]}
  end

  def save(out_file)
    new_geometry = get_new_geometry

    path = @path

    if out_file and File.directory?(out_file)
      path = File.expand_path(out_file)
      out_file = nil
    end

    if out_file.nil?
      out_file = File.join(path, @name.sub(File.extname(file), '-' + new_geometry.join('x') + File.extname(file)))
    end

    log "Writing file: #{out_file}"
    save_as(out_file) or return false
    close

    {:file => out_file, :width => new_geometry[0], :height => new_geometry[1]}
  end

  def to_s
    image_data
  end

  def to_a
    to_response
  end

  def to_rgba
    bytes = image_data.bytes
    (1..bytes.length).step(4).map { |i| bytes[i..i+2] << bytes[i-1] }.flatten
  end

  # transforms data (RGBA buffer) into a array of RGB values
  def to_rgb
    bytes = image_data.bytes
    (1..bytes.length).step(4).map { |i| [bytes[i-1],bytes[i],bytes[i+1]] }.flatten
  end

  def inspect
    geometry = get_new_geometry
    "#<Dimension::Image:#{object_id} @width=#{geometry[0]}, @height=#{geometry[1]}>"
  end

  def to_response(env = nil)
    [200, {'Content-Type' => "image/#{format}"}, [image_data]]
  end

  def log(msg)
    puts "[Dimension::#{Dimension.processor}] #{msg}"
  end

end

end

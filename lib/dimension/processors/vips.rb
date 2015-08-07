# from examples at
# - https://github.com/eltiare/carrierwave-vips/blob/master/lib/carrierwave/vips.rb
# - https://github.com/jcupitt/ruby-vips/tree/master/examples

require 'vips'

module VipsProcessor

  FORMAT_OPTS = {
    'jpeg' => { :quality => 0.9 },
    'png'  => { :compression => 6, :interlace => false }
  }

  SHARPEN_MASK = begin
    conv_mask = [
      [ -1, -1, -1 ],
      [ -1, 24, -1 ],
      [ -1, -1, -1 ]
    ]
    ::VIPS::Mask.new conv_mask, 16
  end

  def image
    @image ||= if format == 'jpeg'
        VIPS::Image.jpeg(@file, :sequential => true)
      elsif format == 'png'
        VIPS::Image.png(@file, :sequential => true)
      else
        VIPS::Image.new(@file)
      end
  end

  def geometry
    [image.x_size, image.y_size]
  end

  def format
    file[/.png$/] ? 'png' : file[/jpe?g$/] ? 'jpeg' : File.extname(file).sub('.', '')
  end

  def image_data
    writer.to_memory
  end

  def save_as(new_file_path)
    save(new_file_path)
  end

  def save!
    save(file)
  end

  def close
    log "Closing image and cutting thread..."
    @image = nil
    VIPS::thread_shutdown
    # image.delete!(true) # free image, and de-cache it too
  end

  def get_new_geometry
    geometry
  end

  private

  def resize(width, height, min_or_max = :min)
    ratio = get_ratio(width, height, min_or_max)
    if ratio == 1
      return log "Same ratio as original."
    end
    if ratio > 1
      @image = image.affinei_resize :nearest, ratio
    else
      if ratio <= 0.5
        factor = (1.0 / ratio).floor
        @image = image.shrink(factor)
        @image = image.tile_cache(image.x_size, 1, 30)
        ratio = get_ratio(width, height, min_or_max)
      end
      @image = image.affinei_resize :bicubic, ratio
      @image = image.conv SHARPEN_MASK
    end
  end

  def resize_and_crop(w, h, gravity)
    resize_image(new_width, new_height, :max)

    if image.x_size > new_width
      top = 0
      left = (image.x_size - new_width) / 2
    elsif image.y_size > new_height
      left = 0
      top = (image.y_size - new_height) / 2
    else
      left = 0
      top = 0
    end

    @image = image.extract_area(left, top, new_width, new_height)
  end

  def crop(width, height, x, y, gravity)
    raise "TODO"
  end

  def crop_scaled(x, y, new_w, new_h)
    raise "TODO"
  end

  def get_ratio(width, height, min_or_max = :min)
    width_ratio = width.to_f / image.x_size
    height_ratio = height.to_f / image.y_size
    [width_ratio, height_ratio].send(min_or_max)
  end

  def write(filename, strip = false)
    if strip
      writer.remove_exif
      writer.remove_icc
    end
    writer.write(filename)
  end

  def writer
    @writer ||= writer_class.send(:new, @image, FORMAT_OPTS[format] || {})
  end

  def writer_class
    case format
      when 'jpeg' then VIPS::JPEGWriter
      when 'png' then VIPS::PNGWriter
      else VIPS::Writer
    end
  end

end

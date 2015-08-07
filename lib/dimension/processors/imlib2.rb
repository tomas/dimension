require 'imlib2'

module Imlib2Processor

  def image
    @image ||= Imlib2::Image.load(@file)
  end

  def geometry
    [image.w, image.h]
  end

  def format
    image.format # .gsub('jpeg', 'jpg')
  rescue ArgumentError
    File.extname(file).sub('.', '')
  end

  def image_data
    unless @temp_file
      @temp_file = "/tmp/#{$$}.#{File.basename(file)}"
      save_as(@temp_file)
    end
    IO.read(@temp_file)
  end

  def save_as(new_file_path)
    image.save(new_file_path)
  end

  def save!
    image.save(file)
  end

  def close
    log "Closing image."
    FileUtils.rm(@temp_file) if @temp_file
    image.delete!(true) # free image, and de-cache it too
  end

  def get_new_geometry
    geometry
  end

#  http://pablotron.org/software/imlib2-ruby/doc/
#
#  iw, ih = old_image.width, old_image.height
#  new_w, new_h = iw - 20, ih - 20
#  values = [10, 10, iw - 10, iw - 10, new_w, new_h]
#  new_image = old_image.crop_scaled values

  def resize(w, h)
    new_w, new_h = get_resize_geometry(w, h, false)
    crop_scaled(0, 0, new_w, new_h)
  end

#  def resize_and_fill(w, h)
#    new_w, new_h = get_resize_geometry(w, h, false)
#    x = (w.to_i - new_w)
#    y = (h.to_i - new_h)
#    image.crop_scaled!(x*-1, y*-1, image.w + x*2, image.h + y*2, w.to_i, h.to_i)
#  end

  def resize_and_crop(w, h, gravity)
    new_w, new_h = get_resize_geometry(w, h, true)
    crop_scaled(0, 0, new_w, new_h)
    # crop_scaled(0, 0, w, h)

    offset = get_offset(w, h, gravity)
    # original_height = image.h
    # original_width  = image.w

    image.crop!(offset[0], offset[1], w.to_i, h.to_i)
    # crop_scaled(offset[0], offset[1], new_w, new_h)
  end

  def crop(width, height, x, y, gravity)
    rect = [(x || 0).to_i, (y || 0).to_i, width.to_i, height.to_i]
    image.crop!(rect)
  end

  def crop_scaled(x, y, new_w, new_h)
    log "Resizing #{image.w}x#{image.h} to #{new_w}x#{new_h}. Offset at #{x},#{y}"
    image.crop_scaled!(x, y, image.w, image.h, new_w.to_i, new_h.to_i)
  end

  def get_offset(w, h, gravity = 'c')
    if gravity.nil? or gravity == '' or gravity == 'c'
      return get_center_offset(w, h)
    else
      raise 'Not implemented'
    end
  end

  def get_center_offset(w, h)
    w_diff = image.w - w.to_i
    h_diff = image.h - h.to_i
    log "Width diff: #{w_diff}"
    log "Height diff: #{h_diff}"

    if w_diff == h_diff
      return [0, 0]
    elsif w_diff > h_diff
      return [w_diff.to_f/2, 0]
    else
      return [0, h_diff.to_f/2]
    end
  end

  def get_resize_geometry(w, h, to_longer = true)
    if to_longer or h.nil?
      if image.w < image.h
        new_h = ((w.to_f / image.w) * image.h).round
        return w.to_i, new_h
      else
        new_w = ((h.to_f / image.h) * image.w).round
        return new_w, h.to_i
      end
    else
      if w && image.w >= image.h
        new_h = ((w.to_f / image.w) * image.h).round
        return w.to_i, new_h
      else
        new_w = ((h.to_f / image.h) * image.w).round
        return new_w, h.to_i
      end
    end
  end

end

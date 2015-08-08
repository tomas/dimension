module ImageMagickProcessor

  def geometry
    [image_details[:width], image_details[:height]]
  end

  def format
    image_details[:format]
  end

  def image_data
    @current_path = path if @current_path.nil?
    IO.read(@current_path)
  end

  def save_as(new_file_path)
    return if new_file_path == @temp_file
    FileUtils.mv(@temp_file, new_file_path)
    @current_path = new_file_path
  end

  def get_new_geometry
    self.class.new(@temp_file).geometry
  end

  def save!
    FileUtils.mv(@temp_file, file)
  end

  def close
    log "Removing temp file: #{@temp_file}"
    FileUtils.rm_f(@temp_file)
  end

  private

  def resize(w, h)
    convert "-resize #{w}x#{h}"
  end

  def resize_and_crop(w, h, gravity)
    gravity = self.class::GRAVITIES[gravity || 'c']
    convert "-resize #{w}x#{h}^^ -gravity #{gravity} -crop #{w}x#{h}+0+0 +repage"
  end

  def crop(width, height, x = 0, y = 0, gravity)
    raise ArgumentError, "you can't give a crop offset and gravity at the same time" if x != 0 and gravity

    x = '+' + x unless x[/^[+-]/]
    y = '+' + y unless y[/^[+-]/]
    args = "-crop #{w}x#{h}#{x}#{y} +repage"

    if gravity and g = self.class::GRAVITIES[gravity]
      args = "-gravity #{gravity} #{args}"
    end

    convert args
  end

  def convert(args)
    @temp_file = "/tmp/#{$$}.#{File.basename(file)}"
    out = `convert "#{file}" #{args} "#{@temp_file}"`
  end

  def image_details
    @image_details ||= identify(file)
  end

  def identify(path)
    out = `identify -ping -format '%m %w %h' "#{path}"`
    format, width, height = out.split
    { :format => format.downcase,
      :width  => width.to_i,
      :height => height.to_i }
  end

end

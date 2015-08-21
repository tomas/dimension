require 'dimension'
require 'logger'
require 'uri'

module Dimension
  
  class Scanner

    def initialize(opts = {})
      raise "Search root path required." unless opts[:root]
      @root = File.expand_path(opts.delete(:root))
      @log_output = opts.delete(:log_output) || STDOUT
    end
    
    def process(content)
      images = content.scan(/([a-z\-_0-9\/\:\.]*\.(jpg|jpeg|png|gif))/i)
      return [] if images.empty?
    
      paths = images.map { |img| URI.parse(img[0]).path }.uniq
      paths.map do |path|
    
        full = File.join(@root, path)
        if File.exist?(full)
          logger.info "Image exists in #{@root}: #{path}"
          next
        end
    
        logger.info "Image not found! #{path}"
        no_extension = File.basename(path, File.extname(path))
    
        if geometry = no_extension[/((\d+)?x(\d+)?.?)$/i, 1]
          original = File.join(@root, path.sub(/-?#{geometry}/, ''))

          if File.exist?(original)
            if resize_image(original, geometry, full)
              logger.warn "Generated thumbnail for #{geometry} version or #{original}."
              full
            else
              logger.error "Unable to generate #{geometry} thumbnail for #{original}"
              nil
            end
          else
            logger.warn "Geometry #{geometry} was requested, but #{original} does not exist."
            nil
          end
        end
      end.compact
    end

    private
    
    def logger
      Logger.new(@log_output)
    end
  
    def resize_image(file, geometry, destination)
      thumb = Dimension.open(file)
      thumb.generate!(geometry, destination)
    end

  end

end

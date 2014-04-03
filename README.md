Resizer
=======

Fast, simplified image resizing for Ruby. No ImageMagick.

``` rb
  require 'resizer'
   
  thumb = Resizer.open('tux.png')
  thumb.generate('100x100') # => { :width => 100, :height => 100 }
  thumb.save('resized.png')
```

Or generate and write file automatically.

``` rb
  thumb = Resizer.new('tux.png')
  thumb.generate!('100x300!') # will write file as 'tux-100x300.png'
```

# In memory processing

Yes sir, we have it.

``` rb
  thumb = Resizer.open(params[:file])
  thumb.generate('200x300#')
  thumb.image_data
```

You can also pass a block, which will ensure the original image is closed after processing.

``` rb
  get '/resize/:file' do
    thumb = Resizer.open(params[:file])
    thumb.generate('200x300#') do |res|
      @out = thumb.to_response
    end
    @out.to_response
  end
```

# Resizing geometries

This is taken directly from the excellent Dragonfly gem. 

Copyright
=========

(c) Fork, Ltd. MIT Licensed.

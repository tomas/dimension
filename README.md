Dimension
=========

Fast, simplified image resizing for Ruby. No ImageMagick.

``` rb
  require 'Dimension'
   
  thumb = Dimension.open('tux.png')
  thumb.generate('100x100') # => { :width => 100, :height => 100 }
  thumb.save('resized.png')
```

Or generate and write file automatically.

``` rb
  thumb = Dimension.new('tux.png')
  thumb.generate!('100x300!') # will write file as 'tux-100x300.png'
```

# In memory processing

Yes sir, we have it.

``` rb
  thumb = Dimension.open(params[:file])
  thumb.generate('200x300#')
  thumb.image_data
```

You can also pass a block, which will ensure the original image is closed after processing.

``` rb
  get '/resize/:file' do
    thumb = Dimension.open(params[:file])
    thumb.generate('200x300#') do
      thumb.to_response
    end
  end
```

# Resizing geometries

This is taken directly from the excellent Dragonfly gem. 

Author
======

Written by Tomás Pollak.

Copyright
=========

(c) Fork, Ltd. MIT Licensed.

# Dimension

Lightweight image resizing for Ruby, either with vips, imlib2 or ImageMagick.

``` rb
  require 'dimension'

  thumb = Dimension.open('tux.png')
  thumb.generate('100x100') # => { :width => 100, :height => 100 }
  thumb.save('resized.png')
```

Or generate and write file automatically.

``` rb
  thumb = Dimension.open('tux.png')
  thumb.generate!('100x300!') # will write file as 'tux-100x300.png'
```

## In memory processing

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
    thumb.generate('200x300@') do
      thumb.to_response
    end
  end
```

# Installation

For vips backend:

    # install library
    apt install libvips42
    # then, the ruby bindings
    gem install ruby-vips
    # and in case you don't get a libvips.so symlink
    sudo ln -s /usr/lib/x86_64-linux-gnu/libvips.so.42 /usr/lib/x86_64-linux-gnu/libvips.so

For imlib2 backend:

    # install deps
    sudo apt install libimlib2-dev
    # clone repo
    git clone https://github.com/pepabo/imlib2-ruby
    cd imlib2-ruby
    # build/install
    ruby extconf.rb
    make
    make install
    # and clean up
    cd ..
    rm -Rf imlib2-ruby

For ImageMagick, there's no gem required. Just make sure the binaries (identify, convert) are in place:

    sudo apt install imagemagick

# TODO

 - [ ] Support for N/S/W/E gravities.
 - [ ] Tests (e.g. ensure geometry calculation works equally across backends).

# Related

 - [Dragonfly gem](http://markevans.github.io/dragonfly). This is where the original inspiration came from.

# Author

Written by Tomás Pollak.

# Copyright

(c) Fork, Ltd. MIT Licensed.

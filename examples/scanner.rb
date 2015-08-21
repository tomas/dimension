require_relative '../lib/dimension'
require_relative '../lib/dimension/scanner'

content = %{
  This is a snippet of text to demonstrate how Dimension's scanner module works.
  It will detect any link that points to an image containing a geometry (e.g image-100x100.png)
  and try to generate a thumbnail if it doesn't exist already.
  
  The parser is quite smart, and will correctly detect images linked using an HTML tag,
  like <img src="assets/window-200x.jpg" /> or Markdown ![img](assets/chair-x200.jpg) or
  simply a spare URL like assets/the-two-towers-200x200.png.
}

scanner = Dimension::Scanner.new(:root => File.dirname(__FILE__))

thumbs = scanner.process(content)

puts thumbs.inspect

thumbs.each do |thumb|
  if File.exist?(thumb)
    puts "Thumbnail generated! #{thumb}"
  else
    puts "Huh? There should be an image at #{thumb} but there's nothing there."
  end
end
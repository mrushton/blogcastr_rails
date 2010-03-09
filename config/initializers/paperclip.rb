#MVR - the style extension is always the same as the style except for the original
Paperclip.interpolates :style_extension do |attachment, style|
  if style == :original
    extension = File.extname(attachment.instance.audio_file_name)
    #MVR - remove leading "."
    extension[1,extension.length-1]
  else
    style
  end
end

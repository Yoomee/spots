module DocumentsHelper
  def document_icon(document)
    icon = case document.file_ext
      when /jpg|png|gif|psd|eps|ai|bmp/ then "image"
      when /doc|docx|txt|pages/ then "word"
      when /pdf/ then "pdf"
      when /zip/ then "zip"
      when /excel|xls|xlsx/ then "excel"
      when /ppt|pptx|keynote/ then "excel"
      when /mp3|aac|wav/ then "audio"
      when /mov|avi|mpeg4|mp4/ then "audio"
      else "item"
    end
    image_tag("doc_#{icon}.png")
  end
end
class String

  def fully_underscore
    gsub(/\W+/, '_')
  end

  def is_number?
    true if Float(self) rescue false
  end

  def indefinitize
    (%w{a e i o u}.include?(self.first.downcase) ? "an " : "a ") + self
  end

  def split_with_index(regex)
    ret = []
    index_offset = 0
    remaining_text = dup
    split(regex).each do |word|
      ret << [word,remaining_text.index(word) + index_offset]
      cutoff = remaining_text.index(word) + word.length
      remaining_text.slice!(0..cutoff)
      index_offset += cutoff + 1
    end
    ret
  end
  
  def plural?
    self.pluralize == self
  end

  def preview(max_length = 30)
    self.strip_tags.word_truncate(max_length)
  end
  
  def singular?
    self.singularize == self
  end
  

  def strip_tags
    ActionController::Base.helpers.strip_tags(self)
  end

  # Like the Rails _truncate_ helper but doesn't break HTML tags or entities.
  def truncate_html(max_length = 30, ellipsis = "...", options = {})
    doc = Hpricot(self)
    ellipsis_length = Hpricot(ellipsis).inner_text.mb_chars.length
    content_length = doc.inner_text.mb_chars.length
    actual_length = max_length - ellipsis_length
    return self unless content_length > max_length
    doc.truncate(actual_length, ellipsis, options).inner_html
  end

  def urlify
    strip.gsub(/[^a-zA-Z0-9\s\-]/,"").gsub(/\s+/,"-")
  end

  def variableize
    downcase.underscore.gsub(/\s+/, '_')
  end

  # Truncate at word boundary thus avoiding chopping words 
  def word_truncate(length = 30, truncate_string = "...")
    return if self.nil?
    strip!
    l = length - truncate_string.length
    ret = self.length > length ? self[/\A.{#{l}}\w*\;?/m][/.*[\w\;]/m] + truncate_string : self
    ret = ret.gsub(/&#39;/,"'")
  end

  def word_truncate_html(max_length = 30, ellipsis = "...", options = {})
    truncate_html(max_length, ellipsis, options.merge(:word_truncate => true))
  end

end

module HpricotTruncator
  
  module IgnoredTag
    def truncate(max_length)
      self
    end
  end

  module NodeWithChildren
    def truncate(max_length, ellipsis = '...', options = {})
      return self if inner_text.mb_chars.length <= max_length
      truncated_node = self.dup
      truncated_node.name = self.name if self.respond_to?(:name)
      truncated_node.children = []
      each_child do |node|
        remaining_length = max_length - truncated_node.inner_text.mb_chars.length
        break if remaining_length < 1
        node.truncate(remaining_length, ellipsis, options)
        truncated_node.children << node
      end
      truncated_node
    end
  end

  module TextNode
    def truncate(max_length, ellipsis = "...", options = {})
      # We're using String#scan because Hpricot doesn't distinguish entities.
      if content.mb_chars.length > max_length
        if options[:word_truncate]
          self.content = content[/\A.{#{max_length}}\w*\;?/m][/.*[\w\;]/m].to_s + ellipsis
        else
          self.content = content.scan(/&#?[^\W_]+;|./).first(max_length).join + ellipsis
        end
      end
    end
  end

end

Hpricot::BogusETag.send(:include, HpricotTruncator::IgnoredTag)
Hpricot::Comment.send(:include,   HpricotTruncator::IgnoredTag)
Hpricot::Doc.send(:include,       HpricotTruncator::NodeWithChildren)
Hpricot::Elem.send(:include,      HpricotTruncator::NodeWithChildren)
Hpricot::Text.send(:include,      HpricotTruncator::TextNode)

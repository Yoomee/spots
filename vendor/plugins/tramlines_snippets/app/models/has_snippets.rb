module HasSnippets

  def self.included(klass)
    klass.has_many :snippets, :as => :item, :dependent => :destroy, :autosave => true
    klass.after_save :save_snippets
    klass.send(:before_save, :destroy_blank_snippets)
    klass.send(:before_save, :set_delta_flag)
    klass.send(:alias_method_chain, :attributes, :snippets)
    klass.send(:alias_method_chain, :method_missing, :snippets)
    klass.send(:alias_method_chain, :respond_to?, :snippets)
    klass.send(:define_method, :has_snippet?) do |name|
      !snippet_text(name).blank?
    end
    klass.send(:define_method, :has_any_snippet?) do |*names|
      names.any? {|name| has_snippet?(name)}
    end
  end
  
  attr_accessor :skip_save_snippets
  
  def attributes_with_snippets
    returning out = attributes_without_snippets do
      snippets.reject(&:blank?).each do |snippet|
        out["snippet_#{snippet.name}"] = snippet_text(snippet.name)
      end
    end
  end  
  
  def has_snippets?
    !snippets.empty? || (@cached_snippets && !@cached_snippets.empty?)
  end
  
  def method_missing_with_snippets(method_id, *args)
    method_name = method_id.to_s
    case 
      when match = method_name.match(/^snippet_(\w+)=/)
        send(:snippet_text=, match[1], args.first)
      when match = method_name.sub(/_before_type_cast$/, '').match(/^snippet_(\w+)/)
        snippet_text(match[1])
      else
        method_missing_without_snippets(method_id, *args)
    end
  end
  
  def respond_to_with_snippets?(method_id)
    respond_to_without_snippets?(method_id) || !(method_id.to_s =~ /^snippet_(\w+)/).nil?
  end

  def snippet(name)
    @cached_snippets ||= {}
    @cached_snippets[name.to_s] ||= (load_snippet(name) || snippets.build(:name => name))
  end
  
  def snippet_text(name)
    snippet = snippet(name)
    snippet ? snippet.text : ''
  end

  def snippet_text=(name, val)
    snippet = snippet(name)
    changed_attributes["snippet_#{name}"] = snippet.text unless snippet.text == val
    snippet.text = val
  end

  private
  def changed_snippets
    arr = (@cached_snippets || {}).select do |snippet_key, snippet|
      db_snippet = load_snippet(snippet_key)
      db_snippet.nil? || db_snippet.text != snippet.text
    end
    arr.inject({}) do |memo, pair|
      memo[pair[0].gsub(/_text$/, '')] = pair[1]
      memo
    end
  end
  
  def destroy_blank_snippets
    @cached_snippets.select {|name, snippet| snippet.text_is_blank?}.each {|name, snippet| snippet.destroy} unless @cached_snippets.nil?
  end

  def load_snippet(name)
    snippets(true).detect {|snippet| snippet.name == name.to_s}
  end

  def needing_save_snippets
    return [] if @cached_snippets.nil?
    @cached_snippets.reject {|name, snippet| snippet.text_is_blank?}
  end

  def save_snippets
    unless skip_save_snippets
      needing_save_snippets.each do |name, snippet|
        # It shouldn't be necessary to set the item_id on these, but for some reason it only seems to set it on the first one.
        snippet.item_id = self.id if snippet.item_id.nil?
        snippet.save
      end
    end
  end
  
  def set_delta_flag
    self.delta = true if respond_to?(:delta) && has_snippets?
  end

end


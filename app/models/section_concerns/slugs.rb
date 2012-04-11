module SectionConcerns::Slugs

  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
  
    def about_us
      slug(:about_us)
    end

    def news
      slug(:news)
    end

    def slug(slug_name, options = {})
      if section = find_by_slug(slug_name.to_s)
        return section
      end
      s = new(options.reverse_merge!(:name => slug_name.to_s.titleize))
      s.update_attributes!(:slug => slug_name.to_s)
      s
    end

  end

  def root_slug_is(slug_name)
    absolute_root.slug_is?(slug_name)
  end
  alias_method :root_slug_is?, :root_slug_is
  
  def descendant_of_slug(slug_name)
    ancestors.any?{|s| s.slug_is?(slug_name)}
  end
  alias_method :descendant_of_slug?, :descendant_of_slug

end

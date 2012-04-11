module PageConcerns::Slugs
  
  def self.included(klass)
    klass.extend(ClassMethods)
    klass.delegate :slug, :to => :section, :prefix => true, :allow_nil => true
  end

  module ClassMethods

    def slug(slug_name, options = {})
      if page = find_by_slug(slug_name.to_s)
        return page
      end
      section = (Section.first || Section.create!(:name => 'About'))
      p = new(options.reverse_merge!(:section => section, :title => slug_name.to_s.titleize, :text => "Content coming soon"))
      p.update_attributes!(:slug => slug_name.to_s)
      p
    end

  end
  
  def root_slug_is(slug_name)
    section.absolute_root.slug_is?(slug_name)
  end
  alias_method :root_slug_is?, :root_slug_is
  
  def section_slug_is(slug_name)
    section.slug_is?(slug_name)
  end
  alias_method :section_slug_is?, :section_slug_is
  
  def descendant_of_slug(slug_name)
    section.descendant_of_slug(slug_name)
  end
  alias_method :descendant_of_slug?, :descendant_of_slug
  
end

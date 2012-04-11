module HasPermalink
  
  def self.included(klass)
    klass.cattr_accessor :auto_update_permalink
    klass.has_one :permalink, :as => :model, :autosave => true, :dependent => :destroy
    klass.has_many :old_permalinks, :as => :model, :dependent => :destroy
    klass.extend Forwardable
    klass.extend ClassMethods
    klass.def_delegator :get_permalink, :name, :permalink_name
    klass.def_delegator :get_permalink, :slug, :permalink_slug
    klass.def_delegator :get_permalink, :name=, :permalink_name=
    klass.before_validation :setup_permalink
    klass.before_validation :destroy_permalink_if_blank
    klass.has_virtual_attribute :permalink_name
    klass.after_validation :validate_permalink
    klass.send(:attr_writer, :slug)
    klass.send(:alias_method, :slug_name, :slug)
    klass.send(:alias_method, :slug_name=, :slug=)
  end
  
  # def attributes_with_permalinks
  #   returning out = attributes_without_permalinks do
  #     out['permalink_name'] = permalink_name
  #   end
  # end  
  
  module ClassMethods
    
    def find_by_slug(slug_name)
      find(:first, :joins => :permalink, :conditions => {:permalinks => {:slug => slug_name.to_s}})
    end
    alias_method :find_by_slug_name, :find_by_slug
    
    def find_or_initialize_by_slug(slug_name)
      find_by_slug(slug_name) || new(:slug => slug_name)
    end
    alias_method :find_or_initialize_by_slug_name, :find_or_initialize_by_slug
    
  end
  
  def slug
    @slug || get_permalink.slug
  end
  
  def slug_in(slug_names)
    slug_names.collect(&:to_s).include?(slug)
  end
  alias_method :slug_in?, :slug_in
  
  def slug_is(slug_name)
    slug == slug_name.to_s
  end
  alias_method :slug_is?, :slug_is
  
  def permalink_path
    # We don't want to use an unsaved value for this, otherwise form actions etc. will break
    (!permalink_name.blank? && !permalink.name_was.blank?) ? "/#{permalink.name_was}" : nil
  end
  
  private  
  def destroy_permalink_if_blank
    permalink.destroy if permalink && permalink_name.blank? && permalink_slug.blank?
  end
  
  def setup_permalink
    if !to_s.blank? && (permalink.nil? || permalink.name.blank? || self.class::auto_update_permalink)
      get_permalink.name = get_permalink.generate_unique_name(to_s.remove_accents.downcase.urlify)
    end
    get_permalink.slug = @slug unless @slug.nil?
  end
  
  def get_permalink
    self.permalink ||= build_permalink
  end
  
  def validate_permalink
    if permalink
      permalink.errors.each do |attr, msg|
        if attr.to_s == 'slug'
          errors.add(:slug_name, msg)
        else
          errors.add(:permalink_name, msg)
        end
      end
      permalink.errors.clear
    end
  end
  
end
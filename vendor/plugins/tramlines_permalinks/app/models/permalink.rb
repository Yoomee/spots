class Permalink < ActiveRecord::Base

  include PermalinkConcerns
  
  validates_uniqueness_of :slug, :allow_blank => true
  validates_uniqueness_of :name, :case_sensitive => false

  after_update :create_old_permalink

  named_scope :with_slug, :conditions => "slug IS NOT NULL AND slug <> ''"

  class << self
    
    def replace_urls_with_permalinks(text, options = {})
      controller_names = (options[:classes] || HasPermalink.included_in_classes).collect {|c| c.to_s.underscore.pluralize}
      text = text.gsub(/(#{controller_names.join("|")})\/(\d+)/) do |match|
        controller_name, model_id = $1, $2
        if permalink = Permalink.find_by_model_type_and_model_id(controller_name.classify, model_id)
          permalink.name
        else
          "#{controller_name}/#{model_id}"
        end
      end
    end
    
  end

  def generate_unique_name(text)
    count = 1
    new_text = text
    permalinks = new_record? ? self.class : self.class::not_including(self)
    while permalinks.exists?(:name => new_text)
      new_text = "#{text}-#{count}"
      count += 1
    end
    new_text
  end

  private
  def create_old_permalink
    if ActiveRecord::Base.connection.table_exists? 'old_permalinks'
      OldPermalink.create(:name => name_was, :model => model)
    end
  end

end
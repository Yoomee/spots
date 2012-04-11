class AddSlugToPermalinks < ActiveRecord::Migration
  def self.up
    add_column :permalinks, :slug, :string
    if table_exists?(:slugs)
      Slug.all.each do |slug|
        if p = slug.model.try(:permalink)
          p.update_attribute(:slug, slug.name)
        end
      end
    end
  end

  def self.down
    if table_exists?(:slugs)
      Permalink.with_slug.each do |permalink|
        if m = permalink.model
          Slug.find_or_initialize_by_name(permalink.slug).update_attributes!(:model => m)
        end
      end
    end
    remove_column :permalinks, :slug
  end
end


class Slug < ActiveRecord::Base
  
  belongs_to :model, :polymorphic => true
  
end
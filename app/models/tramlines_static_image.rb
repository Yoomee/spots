module TramlinesStaticImage

  # This is now redundant, just include TramlinesImages and if the model doesn't have any image_uid columns, it will always use the default image
  
  def self.included(klass)
    klass.send(:include, TramlinesImages)
  end
  
  # # Adds functionality giving same getter interface as including TramlinesImages,
  # # but adds a single default image to a model, without needing to add database column etc.
  # # Hopefully works, but might possibly be buggy - need to see if any images clash
  # def self.included(klass)
  #   klass.send(:define_method, :image_uid) do
  #     TramlinesImages::default_image_location(self.class, :image)
  #   end
  #   klass.send(:define_method, :image) do
  #     #attachments[image].to_value
  #     Dragonfly::ActiveRecordExtensions::Attachment.new(Member::dragonfly_apps_for_attributes['image'], self, :image).to_value
  #   end
  # end

end
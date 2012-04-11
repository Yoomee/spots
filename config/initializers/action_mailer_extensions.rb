ActionMailer::Base.class_eval do

  class << self

    def arrange_view_paths
      view_paths.unshift("#{RAILS_ROOT}/client/app/views")
      view_paths.delete("#{RAILS_ROOT}/app/views")
      view_paths << "#{RAILS_ROOT}/app/views"      
    end
  
  end

  arrange_view_paths

end


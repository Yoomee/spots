SessionsController.class_eval do
  
  skip_before_filter :redirect_to_organisation_terms, :only => %w{destroy}

end
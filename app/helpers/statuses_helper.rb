module StatusesHelper
  
  def render_status_for(member)
    render("statuses/status", :member => member)
  end
  
  def render_status_form(member, options = {})
    unless member.nil?
      options[:status] ||= member.statuses.build
      options[:persist_form] ||= false
      if @logged_in_member && @logged_in_member == member
        render("statuses/form", options)
      end
    end
  end
  
end

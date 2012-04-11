module ApplicationControllerConcerns::Permalinks

  protected
  def path_not_permalink?(permalink_name)
    return false if permalink_name.blank?
    request_path = request.env["ORIGINAL_PATH_INFO"]
    request_path.present? && request_path != "/#{permalink_name}"
  end

  def redirect_to_permalink(permalink_name)
    url = "/#{permalink_name}"
    url += "?#{request.query_string}" if request.query_string.present?
    redirect_to(url, :status => 301)
  end
  
  def redirect_to_permalink_if_needed(permalink_name)
    redirect_to_permalink(permalink_name) if path_not_permalink?(permalink_name)
  end

end

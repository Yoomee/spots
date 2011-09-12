SectionsController.class_eval do

  def show_with_client
    if @section.view == "normal"
      @pages_sections = @section.pages + @section.children
      @pages_sections.delete(Page.slug(:big_print))
      @pages_sections = @pages_sections.sort_by(&:weight)
      render
    else
      show_without_client
    end
  end
  alias_method_chain :show, :client

end
module ApplicationControllerConcerns::Tabs
  
  def tab
    locals = tab_locals(params.dup)
    validate, tab_name = params[:validate], params[:tab_name]
    options = {:controller => self, :tabs => [tab_name], :locals => locals, :tab_directory => params[:tab_directory], :validate => params[:validate]}
    form = TabHelper::TabbedForm.new(@template, options)
    render :update do |page|
      page.insert_html :after, "#{controller_name}_tab_links_break", form.render_tab(tab_name)
      page << "TabForm.hide_other_tabs('#{controller_name}_#{params[:tab_name]}_tab')"
    end
  end
  
  def tab_locals(params)
    locals = params.delete_if {|name, value| name.in? %w{authenticity_token action controller tab_directory tab_name container_id validate}}
    model_locals = locals.select{|key, value| key.match(/^.+_attributes$/)}
    model_locals.each do |name, value|
      model_name = name.gsub('_attributes', '')
      if locals.keys.include?("#{model_name}_class")
        model_class = locals.delete("#{model_name}_class").gsub('_', '::').constantize
        model_instance = value[:id] ? model_class.find(value[:id]) : model_class.new(value)
        locals[model_name] = model_instance
        locals.delete(name)
      end
    end
    locals
  end
  
end

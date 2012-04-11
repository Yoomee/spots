module StylesHelper
  
  def display_if_true(val)
    {:style => "display:#{val ? 'block' : 'none'}"}
  end
  
end
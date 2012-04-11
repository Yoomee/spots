module FlashHelper
  
  def render_flash
    flash.map {|flash_key, flash_value| content_tag(:p, flash_value, :id => flash_key, :class => "flash", :onclick => "$(this).blindUp('slow');")}.join
  end
  
end
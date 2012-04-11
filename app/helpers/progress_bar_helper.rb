module ProgressBarHelper
  
  def progress_bar(value, options = {})
    target = (options[:target] || 100).to_i
    return if target.zero?
    percentage_complete = ((value.to_f/target.to_f)*100).round
    if options[:vertical]
      progress_bar_width = options[:width] || 10
      progress_bar_height = options[:height] || 100
      if value >= target
        inner_bar_length = progress_bar_height
      else
        inner_bar_length = ((value.to_f/target.to_f) * progress_bar_height).round
      end
    else
      progress_bar_width = options[:width] || 100
      progress_bar_height = options[:height] || 10
      if value >= target
        inner_bar_length = progress_bar_width
      else
        inner_bar_length = ((value.to_f/target.to_f) * progress_bar_width).round
      end
    end
    bar_color = options[:color] || "#64bc46"
    if options[:multicolor]
      bar_color = case percentage_complete
        when 0..25 then "#df1763"
        when 25..60 then "#faaa20"
        else "#64bc46"
      end 
    end

    html = "<div class='progress_bar'>"
    html << "<div style='height: #{progress_bar_height}px; border: 1px solid #888; width: #{progress_bar_width}px'>"
    
    if options[:vertical]
      if progress_bar_height > inner_bar_length
        html << "<div class='progress_bar_outer' style='width:#{progress_bar_width}px; height:#{progress_bar_height - inner_bar_length}px'></div>"
      end
      html << "<div class='progress_bar_inner' style='background:none repeat scroll 0 0 #{bar_color}; border-bottom:1px solid black; width:#{progress_bar_width}px; height:#{inner_bar_length}px'></div>"
    else
      html << "<div class='progress_bar_inner' style='background:none repeat scroll 0 0 #{bar_color}; height:#{progress_bar_height}px; width:#{inner_bar_length}px'></div>"
    end
    
    html << "</div></div>"
  end
  
end
module WaypointsHelper
  
  def link_to_waypoint(*args, &block)
    # don't want to link to current page
    new_waypoint = current_page?(waypoint) ? home_url : waypoint
    if block_given?
      link_to(new_waypoint, args, yield)
    else
      link_to(args.first, new_waypoint, args.second)
    end
  end
  
end
module TimeSlotsHelper
  
  def time_slot_infobox(time_slot)
    render("time_slots/infobox", :time_slot => time_slot)
  end
  
end
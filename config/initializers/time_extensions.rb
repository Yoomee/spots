class Time

  DATE_FORMATS[:neat_date] = "%A %b %d"
  DATE_FORMATS[:neat_date_full_month] = "%A %B %d"
  DATE_FORMATS[:neat_date_full_month_with_year] = "%A %B %d %y"
  DATE_FORMATS[:neat_date_and_time] = "%A %b %d %H:%M"
  DATE_FORMATS[:neat_date_and_time_with_at] = "%A %b %d at %H:%M"
  DATE_FORMATS[:short_date] = "%d/%m/%Y"
  DATE_FORMATS[:short_date_and_time] = "%d/%m/%Y %H:%M"
  DATE_FORMATS[:short_time] = "%H:%M"
  DATE_FORMATS[:month] = "%b"

  def nearest_minutes(minutes = 15)
    Time.at(self.to_i/(minutes*60)*(minutes*60))
  end

  def nearest_fifteen_minutes
    nearest_minutes(15)
  end
  
end

module DatesHelper
  
  def time_without_current_year(date, format = "%a %d %b")
    year = (Time.zone.now.year==date.year) ? '' : date.strftime(" %Y")
    date.strftime(format) + year
  end
  
end
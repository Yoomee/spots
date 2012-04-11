class GeocodesController < ApplicationController
  open_action :show
  
  def show
    if !params[:lat_lng].blank?
      city_country = GoogleGeocode::get_address(params[:lat_lng].split(','))
      if city_country
        render :json => {:city => city_country[0], :country => city_country[1]}
      else
        render :nothing => true
      end
    elsif !params[:address].blank?
      lat_lng = GoogleGeocode::get_lat_lng(params[:address])
      if lat_lng
        render :json => {:lat => lat_lng[0], :lng => lat_lng[1]}
      else
        render :nothing => true
      end
    else
      render :nothing => true
    end
  end
  
end
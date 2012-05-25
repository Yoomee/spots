PagesController.class_eval do
  
  def show
    if @page.slug_is(:get_involved)
      if params[:filter]
        @organisation_group = OrganisationGroup.find_by_id(params[:filter])
      else
        @organisation_group = OrganisationGroup.for_get_involved.first
      end
      date = params[:date].present? ? Date.strptime(params[:date], "%d-%m-%y") : nil
      @activities = Activity.for_organisation_group_with_bookings_availaible_on_date(@organisation_group.try(:id), date)
    end
  end
  
end
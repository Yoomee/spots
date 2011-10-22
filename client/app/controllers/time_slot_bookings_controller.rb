# Copyright 2011 Yoomee Digital Ltd.
# 
# This software and associated documentation files (the
# "Software") was created by Yoomee Digital Ltd. or its agents
# and remains the copyright of Yoomee Digital Ltd or its agents
# respectively and may not be commercially reproduced or resold
# unless by prior agreement with Yoomee Digital Ltd.
# 
# Yoomee Digital Ltd grants Spots of Time (the "Client") 
# the right to use this Software subject to the
# terms or limitations for its use as set out in any proposal
# quotation relating to the Work and agreed by the Client.
# 
# Yoomee Digital Ltd is not responsible for any copyright
# infringements caused by or relating to materials provided by
# the Client or its agents. Yoomee Digital Ltd reserves the
# right to refuse acceptance of any material over which
# copyright may apply unless adequate proof is provided to us of
# the right to use such material.
# 
# The Client shall not be permitted to sub-license or rent or
# loan or create derivative works based on the whole or any part
# of the Works supplied by us under this agreement without prior
# written agreement with Yoomee Digital Ltd.
class TimeSlotBookingsController < ApplicationController
  
  member_only :create
  owner_only :thank_you

  custom_permission :index, :in_past do |url_options, member|
    organisation = Organisation.find(url_options[:organisation_id])
    organisation.owned_by?(member) || (member && member.is_admin?)
  end
  
  custom_permission :update, :cancel, :confirm do |url_options, member|
    time_slot_booking = TimeSlotBooking.find(url_options[:id])
    time_slot_booking.organisation.owned_by?(member) || (member && member.is_admin?)
  end

  def cancel
    @time_slot_booking = TimeSlotBooking.find(params[:id])
    @time_slot_booking.cancel = true
    render :layout => false
  end
  
  def confirm
    @time_slot_booking = TimeSlotBooking.find(params[:id])
    @time_slot_booking.confirmed = true
    render :layout => false    
  end
  
  def create
    @time_slot_booking = logged_in_member.time_slot_bookings.build(params[:time_slot_booking])
    if @time_slot_booking.save
      flash[:notice] = "Thanks #{logged_in_member.forename}, you are now booked to be at #{@time_slot_booking.organisation_name} on #{@time_slot_booking.starts_at_neat_string}"
      redirect_to thank_you_time_slot_booking_path(@time_slot_booking)
    else
      @time_slot = @time_slot_booking.time_slot
      render :template => "time_slots/show"
    end
  end
  
  def in_past
    @organisation = Organisation.find(params[:organisation_id])
    @time_slot_bookings = @organisation.time_slot_bookings.starts_at_lte(Time.now).ascend_by_starts_at.paginate(:per_page => 20, :page => params[:page])
  end
  
  def index
    @organisation = Organisation.find(params[:organisation_id])
    time_slot_bookings = @organisation.time_slot_bookings.starts_at_gt(Time.now).ascend_by_starts_at
    @unconfirmed_time_slot_bookings = time_slot_bookings.not_confirmed
    @confirmed_time_slot_bookings = time_slot_bookings.confirmed
  end
  
  def thank_you
    @time_slot_booking = TimeSlotBooking.find(params[:id])
  end
  
  # currently only used for confirm and cancel actions
  def update
    @time_slot_booking = TimeSlotBooking.find(params[:id])
    @time_slot_booking.attributes = params[:time_slot_booking]
    render :update do |page|
      if @time_slot_booking.cancel?
        if @time_slot_booking.destroy
          Notifier.deliver_cancel_time_slot_booking(@time_slot_booking)
        end
        flash[:notice] = "Activity slot has been cancelled and email has been sent."
        page.redirect_to(organisation_time_slot_bookings_path(@time_slot_booking.organisation))        
      else
        if @time_slot_booking.save
          if @time_slot_booking.confirmed?
            Notifier.deliver_confirm_time_slot_booking(@time_slot_booking)
          end
          flash[:notice] = "Activity slot has been confirmed and email has been sent."
          page.redirect_to(organisation_time_slot_bookings_path(@time_slot_booking.organisation))
        else
          page[:time_slot_booking_form].replace(render("time_slot_bookings/form", :time_slot_booking => @time_slot_booking))
        end
      end
    end
  end
  
end

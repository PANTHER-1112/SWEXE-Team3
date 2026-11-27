class FacilitiesController < ApplicationController
  def index
    @facilities = Facility.includes(:category).order(:id)
    @stamped_facility_ids =
      if logged_in?
        current_user.stamp_logs.pluck(:facility_id)
      else
        []
      end
  end

  def show
    @facility = Facility.includes(:category).find(params[:id])
    @is_stamped = logged_in? && current_user.stamp_logs.exists?(facility_id: @facility.id)
  end
end

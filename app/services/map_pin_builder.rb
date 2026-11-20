# frozen_string_literal: true

require "set"

class MapPinBuilder
  MIN_COORDINATE = 0.0
  MAX_COORDINATE = 100.0

  Pin = Struct.new(
    :facility_id,
    :name,
    :disaster_type,
    :map_x,
    :map_y,
    :stamped,
    keyword_init: true
  )

  def initialize(facilities:, stamped_facility_ids:)
    @facilities = Array(facilities)
    @stamped_facility_ids =
      Set.new(Array(stamped_facility_ids).compact)
  end

  def call
    @facilities.each_with_object([]) do |facility, pins|
      next unless valid_coordinates?(facility)

      pins << build_pin(facility)
    end
  end

  private

  def build_pin(facility)
    Pin.new(
      facility_id: facility.id,
      name: facility.name,
      disaster_type: disaster_type_for(facility),
      map_x: facility.map_x.to_f,
      map_y: facility.map_y.to_f,
      stamped: @stamped_facility_ids.include?(facility.id)
    )
  end

  def valid_coordinates?(facility)
    valid_coordinate?(facility.map_x) &&
      valid_coordinate?(facility.map_y)
  end

  def valid_coordinate?(coordinate)
    coordinate.is_a?(Numeric) &&
      coordinate.finite? &&
      coordinate.between?(MIN_COORDINATE, MAX_COORDINATE)
  end

  def disaster_type_for(facility)
    return facility.disaster_type if facility.respond_to?(:disaster_type)
    return unless facility.respond_to?(:category)

    category = facility.category
    category&.disaster_type
  end
end

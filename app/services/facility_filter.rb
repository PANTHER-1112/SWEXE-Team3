# frozen_string_literal: true

class FacilityFilter
  ALL_DISASTER_TYPES = "すべて"

  def self.call(facilities:, disaster_type:)
    new(
      facilities: facilities,
      disaster_type: disaster_type
    ).call
  end

  def initialize(facilities:, disaster_type:)
    @facilities = Array(facilities)
    @disaster_type = disaster_type
  end

  def call
    return @facilities.dup if all_disaster_types?

    @facilities.select do |facility|
      disaster_type_for(facility) == @disaster_type
    end
  end

  private

  def all_disaster_types?
    @disaster_type == ALL_DISASTER_TYPES
  end

  def disaster_type_for(facility)
    return facility.disaster_type if facility.respond_to?(:disaster_type)
    return unless facility.respond_to?(:category)

    facility.category&.disaster_type
  end
end

# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../app/services/facility_filter"

class FacilityFilterTest < Minitest::Test
  TestCategory = Struct.new(
    :disaster_type,
    keyword_init: true
  )

  TestFacility = Struct.new(
    :name,
    :category,
    keyword_init: true
  )

  def setup
    @earthquake_facility = build_facility(
      name: "第一小学校避難所",
      disaster_type: "震災"
    )
    @flood_facility = build_facility(
      name: "中央給水所",
      disaster_type: "風水害"
    )
    @landslide_facility = build_facility(
      name: "砂防ダム",
      disaster_type: "土砂"
    )

    @facilities = [
      @earthquake_facility,
      @flood_facility,
      @landslide_facility
    ]
  end

  def test_filters_facilities_for_earthquake
    result = filter("震災")

    assert_equal [ @earthquake_facility ], result
  end

  def test_filters_facilities_for_flood
    result = filter("風水害")

    assert_equal [ @flood_facility ], result
  end

  def test_filters_facilities_for_landslide
    result = filter("土砂")

    assert_equal [ @landslide_facility ], result
  end

  def test_returns_all_facilities
    result = filter("すべて")

    assert_equal @facilities, result
    refute_same @facilities, result
  end

  def test_unknown_disaster_type_returns_no_facilities
    result = filter("不明")

    assert_empty result
  end

  def test_nil_facilities_are_treated_as_empty
    result = FacilityFilter.call(
      facilities: nil,
      disaster_type: "すべて"
    )

    assert_empty result
  end

  def test_input_array_is_not_modified
    original = @facilities.dup

    filter("震災")

    assert_equal original, @facilities
  end

  private

  def filter(disaster_type)
    FacilityFilter.call(
      facilities: @facilities,
      disaster_type: disaster_type
    )
  end

  def build_facility(name:, disaster_type:)
    TestFacility.new(
      name: name,
      category: TestCategory.new(
        disaster_type: disaster_type
      )
    )
  end
end

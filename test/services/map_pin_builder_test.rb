# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../app/services/map_pin_builder"

class MapPinBuilderTest < Minitest::Test
  FacilityStub = Struct.new(
    :id,
    :name,
    :disaster_type,
    :map_x,
    :map_y,
    keyword_init: true
  )

  CategoryStub = Struct.new(
    :disaster_type,
    keyword_init: true
  )

  CategorizedFacilityStub = Struct.new(
    :id,
    :name,
    :category,
    :map_x,
    :map_y,
    keyword_init: true
  )

  def test_builds_map_pins
    facilities = [
      facility(
        id: 1,
        name: "防災センター",
        disaster_type: "震災",
        map_x: 25.5,
        map_y: 40.0
      )
    ]

    pins = build_pins(
      facilities: facilities,
      stamped_facility_ids: []
    )

    assert_equal 1, pins.length

    pin = pins.first

    assert_equal 1, pin.facility_id
    assert_equal "防災センター", pin.name
    assert_equal "震災", pin.disaster_type
    assert_equal 25.5, pin.map_x
    assert_equal 40.0, pin.map_y
    refute pin.stamped
  end

  def test_gets_disaster_type_from_category
    category = CategoryStub.new(
      disaster_type: "震災")

    facilities = [
      CategorizedFacilityStub.new(
        id: 1,
        name: "防災センター",
        category: category,
        map_x: 25.5,
        map_y: 40.0
      )
    ]

    pins = build_pins(
      facilities: facilities,
      stamped_facility_ids: []
    )

    assert_equal 1, pins.length
    assert_equal "震災", pins.first.disaster_type
  end

  def test_marks_stamped_facilities
    facilities = [
      facility(id: 1),
      facility(id: 2)
    ]

    pins = build_pins(
      facilities: facilities,
      stamped_facility_ids: [ 1 ]
    )

    assert pins[0].stamped
    refute pins[1].stamped
  end

  def test_accepts_boundary_coordinates
    facilities = [
      facility(
        id: 1,
        map_x: 0.0,
        map_y: 100.0
      )
    ]

    pins = build_pins(
      facilities: facilities,
      stamped_facility_ids: []
    )

    assert_equal 1, pins.length
    assert_equal 0.0, pins.first.map_x
    assert_equal 100.0, pins.first.map_y
  end

  def test_excludes_out_of_range_coordinates
    facilities = [
      facility(id: 1, map_x: -0.1, map_y: 50.0),
      facility(id: 2, map_x: 50.0, map_y: 100.1)
    ]

    pins = build_pins(
      facilities: facilities,
      stamped_facility_ids: []
    )

    assert_empty pins
  end

  def test_excludes_missing_and_non_numeric_coordinates
    facilities = [
      facility(id: 1, map_x: nil, map_y: 50.0),
      facility(id: 2, map_x: "50", map_y: 50.0),
      facility(id: 3, map_x: 50.0, map_y: nil)
    ]

    pins = build_pins(
      facilities: facilities,
      stamped_facility_ids: []
    )

    assert_empty pins
  end

  def test_excludes_non_finite_coordinates
    facilities = [
      facility(
        id: 1,
        map_x: Float::NAN,
        map_y: 50.0
      ),
      facility(
        id: 2,
        map_x: Float::INFINITY,
        map_y: 50.0
      )
    ]

    pins = build_pins(
      facilities: facilities,
      stamped_facility_ids: []
    )

    assert_empty pins
  end

  def test_duplicate_stamped_ids_do_not_change_result
    facilities = [
      facility(id: 1)
    ]

    pins = build_pins(
      facilities: facilities,
      stamped_facility_ids: [ 1, 1, 1 ]
    )

    assert_equal 1, pins.length
    assert pins.first.stamped
  end

  def test_returns_empty_array_for_empty_facilities
    pins = build_pins(
      facilities: [],
      stamped_facility_ids: [ 1 ]
    )

    assert_empty pins
  end

  def test_does_not_modify_input_arrays
    facilities = [
      facility(id: 1)
    ]
    stamped_facility_ids = [ 1, 1 ]

    original_facilities = facilities.dup
    original_stamped_facility_ids =
      stamped_facility_ids.dup

    build_pins(
      facilities: facilities,
      stamped_facility_ids: stamped_facility_ids
    )

    assert_equal original_facilities, facilities
    assert_equal(
      original_stamped_facility_ids,
      stamped_facility_ids
    )
  end

  private

  def facility(
    id:,
    name: "施設",
    disaster_type: "震災",
    map_x: 50.0,
    map_y: 50.0
  )
    FacilityStub.new(
      id: id,
      name: name,
      disaster_type: disaster_type,
      map_x: map_x,
      map_y: map_y
    )
  end

  def build_pins(facilities:, stamped_facility_ids:)
    MapPinBuilder.new(
      facilities: facilities,
      stamped_facility_ids: stamped_facility_ids
    ).call
  end
end


$: << File.dirname(__FILE__)
require 'test_helper'

if ENV['TEST_ACTIVERECORD']
  class GeographyColumnsTests < ActiveRecord::TestCase
    include TestHelper
    include ActiveRecord::TestFixtures

    self.fixture_path = File.join(File.dirname(__FILE__), 'fixtures')
    fixtures :foo_geographies

    def test_geography_columns_detected
      assert_equal(2, FooGeography.geography_columns.length)

      FooGeography.geography_columns.each do |column|
        assert_kind_of(ActiveRecord::ConnectionAdapters::PostgreSQLSpatialColumn, column)
      end
    end

    def test_srid_for
      assert_equal(0, FooGeography.srid_for(:the_geom))
      assert_equal(4326, FooGeography.srid_for(:the_other_geom))
    end

    def test_coord_dimension_for
      assert_equal(2, FooGeography.coord_dimension_for(:the_geom))
      assert_equal(2, FooGeography.coord_dimension_for(:the_other_geom))
    end

    def test_geography_column_by_name
      assert_kind_of(ActiveRecord::ConnectionAdapters::PostgreSQLSpatialColumn, FooGeography.geography_column_by_name(:the_geom))
      assert_kind_of(ActiveRecord::ConnectionAdapters::PostgreSQLSpatialColumn, FooGeography.geography_column_by_name(:the_other_geom))
    end

    def test_accessors
      foo = FooGeography.find(1)

      Geos::ActiveRecord::SpatialColumns::SPATIAL_COLUMN_OUTPUT_FORMATS.each do |format|
        assert(foo.respond_to?("the_geom_#{format}"))
        assert(foo.respond_to?("the_other_geom_#{format}"))
      end
    end

    def test_without_accessor
      foo = FooGeography.find(1)
      assert_kind_of(String, foo.the_geom)
    end

    def test_geos_accessor
      foo = FooGeography.find(1)
      assert_kind_of(Geos::Point, foo.the_geom_geos)
    end

    def test_wkt_accessor
      foo = FooGeography.find(1)
      assert_kind_of(String, foo.the_geom_wkt)
      assert_match(/^POINT\s*\(0\.0+\s+0\.0+\)$/, foo.the_geom_wkt)
    end

    def test_wkb_accessor
      foo = FooGeography.find(1)
      assert_kind_of(String, foo.the_geom_wkb)
      assert_match(/^[A-F0-9]+$/, foo.the_geom_wkb)
    end

    def test_ewkt_accessor
      foo = FooGeography.find(1)
      assert_kind_of(String, foo.the_geom_ewkt)
      assert_match(/^SRID=\d+;POINT\s*\(0\.0+\s+0\.0+\)$/, foo.the_geom_ewkt)
    end

    def test_ewkb_accessor
      foo = FooGeography.find(1)
      assert_kind_of(String, foo.the_geom_ewkb)
      assert(/^[A-F0-9]+$/, foo.the_geom_wkb)
    end

    def test_wkb_bin_accessor
      foo = FooGeography.find(1)
      assert_kind_of(String, foo.the_geom_wkb_bin)
    end

    def test_ewkb_bin_accessor
      foo = FooGeography.find(1)
      assert_kind_of(String, foo.the_geom_ewkb_bin)
    end

    def test_geos_create
      foo = FooGeography.create!(
        :name => 'test_geos_create',
        :the_geom => Geos.read(POINT_WKT)
      )

      foo.reload
      assert_saneness_of_point(foo.the_geom_geos)
    end

    def test_wkt_create
      foo = FooGeography.create!(
        :name => 'test_wkt_create',
        :the_geom => POINT_WKT
      )

      foo.reload
      assert_saneness_of_point(foo.the_geom_geos)
    end

    def test_wkb_create
      foo = FooGeography.create!(
        :name => 'test_wkb_create',
        :the_geom => POINT_WKB
      )

      foo.reload
      assert_saneness_of_point(foo.the_geom_geos)
    end

    def test_ewkt_create_with_srid_4326
      foo = FooGeography.create!(
        :name => 'test_ewkt_create_with_srid_4326',
        :the_other_geom => POINT_EWKT
      )

      foo.reload
      assert_saneness_of_point(foo.the_other_geom_geos)
    end

    def test_create_with_no_srid_converting_to_4326
      foo = FooGeography.create!(
        :name => 'test_ewkt_create_with_no_srid_converting_to_4326',
        :the_other_geom => POINT_WKT
      )

      foo.reload
      assert_saneness_of_point(foo.the_other_geom_geos)
    end

    def test_create_with_no_srid_converting_to_minus_1
      foo = FooGeography.create!(
        :name => 'test_ewkt_create_with_no_srid_converting_to_minus_1',
        :the_geom => POINT_EWKT
      )

      foo.reload
      assert_saneness_of_point(foo.the_geom_geos)
    end

    def test_create_with_converting_from_900913_to_4326
      FooGeography.create!(
        :name => 'test_create_with_converting_from_900913_to_4326',
        :the_other_geom => "SRID=900913; #{POINT_WKT}"
      )
    end

    def test_ewkt_create_with_srid_default
      foo = FooGeography.create!(
        :name => 'test_ewkt_create_with_srid_default',
        :the_other_geom => POINT_EWKT_WITH_DEFAULT
      )

      foo.reload
      assert_saneness_of_point(foo.the_other_geom_geos)
    end

    def test_ewkb_create
      foo = FooGeography.create!(
        :name => 'test_ewkb_create',
        :the_other_geom => POINT_EWKB
      )

      foo.reload
      assert_saneness_of_point(foo.the_other_geom_geos)
    end
  end
end
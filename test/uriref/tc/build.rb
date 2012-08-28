require 'rio'
require 'rio/uriref'

module RIO::URIRef::UnitTest
  module Build
    module Tests

  def test_alturi_uriref_build
    alturi = Alt::URI::File.new
    u = RIO::URIRef.build(alturi)
    assert_kind_of(Alt::URI::Base,u.ref)
    assert_same(alturi,u.ref)
    assert_equal(alturi,u.ref)
  end

  def test_uriref_uriref_build
    alturi = Alt::URI::File.new
    ui = RIO::URIRef.build(alturi)
    u = RIO::URIRef.build(ui)
    assert_kind_of(Alt::URI::Base,u.ref)
    assert_same(alturi,u.ref)
    assert_equal(alturi,u.ref)
  end


    end
    
  end
end


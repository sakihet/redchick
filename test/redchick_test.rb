require 'test_helper'

class RedchickTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Redchick::VERSION::STRING
  end

  def test_version_number_format
    assert_match(/(\d).(\d).(\d)/, Redchick::VERSION::STRING)
  end
end

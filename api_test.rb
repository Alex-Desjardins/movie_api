require "minitest/autorun"
require "minitest/pride"
require 'net/http'
require 'json'

class APITest < Minitest::Test
  def test_request_success
    url = 'http://www.omdbapi.com/?apikey=9b20bff6&s=thomas'
    uri = URI(url)
    response = Net::HTTP.get(uri)
    to_json = JSON.parse(response, symbolize_names: true)

    assert_equal to_json.class, Hash
    assert_equal to_json[:Search].class, Array
    assert_equal to_json[:Response], "True"
  end
end

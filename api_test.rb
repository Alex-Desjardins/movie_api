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

  def test_missing_api_key
    url = 'http://www.omdbapi.com/?apikey='
    uri = URI(url)
    response = Net::HTTP.get(uri)
    to_json = JSON.parse(response, symbolize_names: true)

    assert_equal to_json[:Response], "False"
    assert_equal to_json[:Error], "No API key provided."
  end

  def test_search_for_thomas
    keyword = "thomas"
    url = "http://www.omdbapi.com/?apikey=9b20bff6&s=#{keyword}"
    uri = URI(url)
    response = Net::HTTP.get(uri)
    to_json = JSON.parse(response, symbolize_names: true)
    to_json[:Search].each do |result|
      assert_includes result[:Title], keyword.capitalize || keyword.downcase
      assert_includes result, :Title && :Year && :imdbID && :Type && :Poster
      result.values.each do |v|
        assert_equal v.class, String
      end
      if result[:Type] == "movie"
        assert_equal result[:Year].to_i.between?(1900,2022), true
      end
      if result[:Type] == "series"
        assert_equal result[:Year][0..3].to_i.between?(1900,2022), true
        assert_equal result[:Year][-4..-1].to_i.between?(1900,2022), true
      end
    end
  end

  def test_search_results_have_valid_imdb_id
    keyword = "rush hour"
    url = "http://www.omdbapi.com/?apikey=9b20bff6&s=#{keyword}"
    uri = URI(url)
    response = Net::HTTP.get(uri)
    to_json = JSON.parse(response, symbolize_names: true)

    to_json[:Search].each do |result|
      url = "http://www.omdbapi.com/?apikey=9b20bff6&i=#{result[:imdbID]}"
      uri = URI(url)
      response = Net::HTTP.get(uri)
      to_json = JSON.parse(response, symbolize_names: true)
      assert_equal to_json[:Response], "True"
    end
  end
end

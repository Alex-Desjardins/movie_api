require "minitest/autorun"
require "minitest/pride"
require 'net/http'
require 'json'

class APITest < Minitest::Test
  def test_request_success
    keyword = "thomas"
    results = keyword_search(keyword)

    assert_equal results.class, Hash
    assert_equal results[:Search].class, Array
    assert_equal results[:Response], "True"
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
    results = keyword_search(keyword)

    results[:Search].each do |result|
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
    results = keyword_search(keyword)

    results[:Search].each do |result|
      url = "http://www.omdbapi.com/?apikey=9b20bff6&i=#{result[:imdbID]}"
      uri = URI(url)
      response = Net::HTTP.get(uri)
      to_json = JSON.parse(response, symbolize_names: true)
      assert_equal to_json[:Response], "True"
    end
  end

  def test_search_results_have_working_poster_links
    keyword = "rush hour"
    results = keyword_search(keyword)

    results[:Search].each do |result|
      uri = URI(result[:Poster])
      response = Net::HTTP.get(uri)
      assert_equal response.class, String
    end
  end

  def test_no_duplicate_records_up_to_page_5
    pages = (1..5)
    keyword = 'thomas'
    titles = Hash.new
    pages.each do |page|
      url = "http://www.omdbapi.com/?apikey=9b20bff6&s=#{keyword}&page=#{page}"
      uri = URI(url)
      response = Net::HTTP.get(uri)
      to_json = JSON.parse(response, symbolize_names: true)
      to_json[:Search].each do |result|
        titles[result[:Title]] = result[:Year]
      end
    end

    assert_equal titles.size == titles.uniq.size, true
  end

  def test_search_results_include_only_movies
    pages = (1..5)
    keyword = "thomas"
    type = "movie"
    pages.each do |page|
      url = "http://www.omdbapi.com/?apikey=9b20bff6&s=#{keyword}&page=#{page}&type=#{type}"
      uri = URI(url)
      response = Net::HTTP.get(uri)
      to_json = JSON.parse(response, symbolize_names: true)

      to_json[:Search].each do |result|
        assert_includes result[:Type], "movie"
      end
    end
  end

  private

  def keyword_search(keyword)
    url = "http://www.omdbapi.com/?apikey=9b20bff6&s=#{keyword}"
    uri = URI(url)
    response = Net::HTTP.get(uri)
    JSON.parse(response, symbolize_names: true)
  end
end

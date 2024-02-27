require "nokogiri"
require "httparty"
require "aws-record"

require "digest"

#####
# This Lambda function scrapes a website to get the names of all countries.
# The countries are then written into a DynamoDB table and returned as a json array.
#####

SOURCE = "https://www.scrapethissite.com/pages/simple/"

class Country
  include Aws::Record

  string_attr :id, hash_key: true
  string_attr :name
end

def fetch_countries
  response = HTTParty.get(SOURCE)
  doc = Nokogiri::HTML5(response.body)

  doc.css("#countries .country").map do |row|
    row.css(".country-name").first&.content&.strip
  end
end

def store_countries(country_names)
  country_names.each do |name|
    country_id = Digest::SHA256.hexdigest(name)

    country = Country.find(id: country_id)
    next unless country.nil?

    country = Country.new(id: country_id, name: name)
    country.save
  end
end

def handler(event:, context:)
  countries = fetch_countries
  store_countries(countries)
  countries
end

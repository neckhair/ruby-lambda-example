require "rubygems"
require "bundler/setup"
Bundler.require(:default)

SOURCE = "https://www.scrapethissite.com/pages/simple/"

def handler(event:, context:)
  response = HTTParty.get(SOURCE)
  doc = Nokogiri::HTML5(response.body)

  countries = []

  doc.css("#countries .country").map do |row|
    countries << row.css(".country-name").first&.content&.strip
  end

  JSON.generate(countries)
end

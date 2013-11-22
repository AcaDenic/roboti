require "capybara/dsl"
require "spreadsheet"

Capybara.run_server = false
Capybara.default_driver = :selenium
Capybara.default_selector = :xpath
Spreadsheet.client_encoding = 'UTF-8'

class Rakuten
	include Capybara::DSL

	def go
		visit "http://global.rakuten.com/en/"
		li = all("//div[@class='genreLinks']//li/a")
		niz_li = []

		li.each do |a|
			niz_li << a[:href]
		end

		niz_li.each do |poseti|
			visit poseti
		end

		#while page.has_selector?("//a[text()='»']")
			#find("//a[text()='»']").click
		#end
	end
end

rakuten = Rakuten.new
rakuten.go
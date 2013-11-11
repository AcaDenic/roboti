require "capybara/dsl"
require "spreadsheet"

Capybara.run_server = false
Capybara.default_driver = :selenium
Capybara.default_selector = :xpath

class OpenCulture
	include Capybara::DSL

	def initialize
		@excel = Spreadsheet::Workbook.new
		@radni_list = @excel.create_worksheet
		@red = 0
	end

	def go
		visit "http://www.openculture.com/free_textbooks"
		rezultati = all("//div[@class='entry']/ul/li")
		rezultati.each do |rezultat|
			link = rezultat.find("./a[1]").text
			@radni_list[@red, 0] = rezultat.text.gsub(link, "")
			@radni_list[@red, 1] = link
			
			puts rezultat.text

			@red +=1

			puts "----------------------------------------------------------------"
		end
		@excel.write "open_culture.xls"
	end
end

open_culture = OpenCulture.new
open_culture.go
require "capybara/dsl"
require "spreadsheet"

Capybara.run_server = false
Capybara.default_driver = :selenium
Capybara.default_selector = :xpath
Spreadsheet.client_encoding = 'UTF-8'

class Realestate
	include Capybara::DSL

	def initialize
		@excel = Spreadsheet::Workbook.new
		@radni_list = @excel.create_worksheet
		@red = 0
	end

	def go
		poseti_linkove
		
	end

	def poseti_linkove
		visit "http://www.realestate.com.au/buy/property-house/list-1"
		details = all("//a[@class='detailsButton button']")
		linkovi = []

		details.each do |a|
			linkovi << a[:href]
		end

		linkovi.each do |link|
			visit link
			sacuvaj_podatke
		end
		@excel.write "realestate.xls"
	end

	def sacuvaj_podatke
		podaci = all("//div[@class='agent']")
		podaci.each do |podatak|
			@radni_list[@red, 0] = podatak.find("./div[@class='agentContactInfo']/p[@class='agentName']/strong").text
			@red = @red + 1
		end
	end

end

realestate = Realestate.new
realestate.go
require "capybara/dsl"
require "spreadsheet"

Capybara.run_server = false
Capybara.default_driver = :selenium
Capybara.default_selector = :xpath
Spreadsheet.client_encoding = 'UTF-8'

class Metacritic
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
		visit "http://www.metacritic.com/browse/movies/release-date/theaters/date"
		film = all("//div[@class='basic_stat product_title']/a")
		filmovi = []

		film.each do |a|
			filmovi << a[:href]
		end

		filmovi.each do |klikni|
			visit klikni
			find("//a[text()='Details & Credits']").click
			sacuvaj_podatke
		end
		@excel.write "filmovi.xls"
	end

	def sacuvaj_podatke
		
		podaci = all("//div[@id='main']")
		podaci.each do |podatak|
			@radni_list[@red, 0] = podatak.find("//a[@class='hover_none']").text
			@radni_list[@red, 1] = podatak.find("//li[@class='summary_detail release_data']/span[@class='data']").text
			@radni_list[@red, 2] = podatak.find("//div[4]/table/tbody/tr[4]/td").text
			@red = @red + 1
		end
		
	end
end

metacritic = Metacritic.new
metacritic.go
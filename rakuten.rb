require "capybara/dsl"
require "spreadsheet"

Capybara.run_server = false
Capybara.default_driver = :selenium
Capybara.default_selector = :xpath
Spreadsheet.client_encoding = 'UTF-8'

class Rakuten
	include Capybara::DSL

	def initialize
		@excel = Spreadsheet::Workbook.new
		@radni_list = @excel.create_worksheet
		@red = 0
	end

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

	def skrapuj
		visit "http://global.rakuten.com/en/category/women_apparel/"
		rezultat = all("//div[@class='b-content b-fix-2lines']/a")
		svi_rezultati = []

		rezultat.each do |link|
			svi_rezultati << link[:href]
		end

		svi_rezultati.each do |klikni|
			visit klikni
			sacuvaj
		end

		@excel.write "rakuten.xls"
	end

	def sacuvaj
		podatak = all("//div[@class='b-subarea b-layout-right']")
		podatak.each do |x|
			@radni_list[@red, 0] = x.find("./h1").text
			@radni_list[@red, 1] = x.find("//span[@class='b-text-xlarge']").text
			@red = @red + 1
		end
	end
end

rakuten = Rakuten.new
rakuten.skrapuj
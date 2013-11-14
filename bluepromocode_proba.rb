require "capybara/dsl"
require "spreadsheet"

Capybara.run_server = false
Capybara.default_driver = :selenium
Capybara.default_selector = :xpath
Spreadsheet.client_encoding = 'UTF-8'

class BluePromoCode
	include Capybara::DSL

	def initialize
		@excel = Spreadsheet::Workbook.new
		@radni_list = @excel.create_worksheet
		@red = 0
	end

	def sacuvaj_podatke
		rezultati = all("//div[@class='store_list_item']")
		rezultati.each do |rezultat|
			@radni_list[@red, 0] = rezultat.find("./div[@class='store_name']/a[1]").text
			@radni_list[@red, 1] = rezultat.find("./div[@class='store_name']/span[@class='store_coupon_total_number']").text
			@radni_list[@red, 2] = rezultat.find("./a[@class='store_link']").text
			@red += 1
		end
	end

	def sva_slova
		visit "http://bluepromocode.com/store/electronics"
		slova = all("//a[@class='alphabetic_nav_item']")
		linkovi = []
		slova.each do |a|
			linkovi << a[:href]
		end
		linkovi.each do |link|
			visit link
			sacuvaj_podatke
		end
		@excel.write "bluepromocode.xls"
	end
end 

blue_promo_code = BluePromoCode.new
blue_promo_code.sva_slova
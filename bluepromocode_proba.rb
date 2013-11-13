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

	def go
		visit "http://bluepromocode.com/store/electronics/b/"
		rezultati = all("//div[@class='store_list_item']")
		rezultati.each do |rezultat|
			@radni_list[@red, 0] = rezultat.find("./div[@class='store_name']/a[1]").text
			@radni_list[@red, 1] = rezultat.find("./div[@class='store_name']/span[@class='store_coupon_total_number']").text
			@radni_list[@red, 2] = rezultat.find("./a[@class='store_link']").text
			@red += 1
		end
		@excel.write "bluepromocode.xls"
	end
end 

blue_promo_code = BluePromoCode.new
blue_promo_code.go
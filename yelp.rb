require "capybara/dsl"
require "spreadsheet"

Capybara.run_server = false
Capybara.default_driver = :selenium
Spreadsheet.client_encoding = 'UTF-8'

class Yelp 
	include Capybara::DSL

	def initialize
		@excel = Spreadsheet::Workbook.new
		@radni_list = @excel.create_worksheet
		@red = 0
	end

	

	def go
		search
		paginacija
		vreme = Time.now
		@excel.write "yelp_rezultati#{vreme.hour}-#{vreme.min}-#{vreme.sec}.xls"
	end

	def search
		visit "http://www.yelp.com"
		fill_in "find_desc", { with: "Prcoklica" }
		fill_in "find_loc", { with: "New York" }
		click_button "submit"
	end

	def get_data
		rezultati = all :xpath, "//*[@id='super-container']/div[3]/div[3]/div[1]/div/div[1]/ul/li"
		rezultati.each do |rezultat|
			@radni_list[@red, 0] = rezultat.find("div > div.secondary-attributes > span.biz-phone").text
			@radni_list[@red, 1] = rezultat.find("div > div.secondary-attributes > address").text
			@radni_list[@red, 2] = rezultat.find("span.review-count.rating-qualifier").text
			@red += 1
			puts "---------------------------------------------------------------------"
		end
	end

	def paginacija
		get_data

		while page.has_selector?('.pagination-links > li > a', text: '→')
			find('.pagination-links > li > a', text: '→').click
			sleep 5
			get_data
		end
	end
end

yelp = Yelp.new
yelp.go
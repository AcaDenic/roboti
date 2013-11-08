require "capybara/dsl"

Capybara.run_server = false
Capybara.default_driver = :selenium

class Yelp 
	include Capybara::DSL

	def go
		search
		paginacija
	end

	def search
		visit "http://www.yelp.com"
		fill_in "find_desc", { with: "Nightlife" }
		fill_in "find_loc", { with: "New York" }
		click_button "submit"
	end

	def get_data
		rezultati = all :xpath, "//*[@id='super-container']/div[3]/div[3]/div[1]/div/div[1]/ul/li"
		rezultati.each do |rezultat|
			puts rezultat.text
			puts "---------------------------------------------------------------------"
		end
	end

	def paginacija
		get_data

		while page.has_selector?('a.page-option.prev-next')
			find('a.page-option.prev-next').click
			get_data
		end

	end

end

yelp = Yelp.new
yelp.go
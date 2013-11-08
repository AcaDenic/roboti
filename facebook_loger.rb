require "capybara/dsl"

Capybara.run_server = false
Capybara.default_driver = :selenium

class Facebook
	include Capybara::DSL

		def uloguj_se
			visit "http://www.facebook.com"
			fill_in "email", { with: "aleksandar@gmail.com" }
			fill_in "pass", { with: "aleksandar" }
			labela = find('#loginbutton')
			labela.click
		end
end

facebook = Facebook.new
facebook.uloguj_se
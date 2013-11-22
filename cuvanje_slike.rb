require 'open-uri'

module Downloadable
	def preuzmi_sliku(url)
		open(url, 'wb') do |file|
 		file << open(url).read
		end
	end
end

class ProbaModula
	include Downloadable
	def go
		preuzmi_sliku("http://www.musicjunction.com.au/WebRoot/ecshared01/Shops/musicjunction/4F9E/0F70/076B/0BEA/58BF/C0A8/D240/245E/Guerrini_President_Oro-2.jpg")
	end
end

proba_modula = ProbaModula.new
proba_modula.go


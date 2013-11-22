require 'open-uri'

open("harmonika.jpg", 'wb') do |file|
  file << open("http://www.musicjunction.com.au/WebRoot/ecshared01/Shops/musicjunction/4F9E/0F70/076B/0BEA/58BF/C0A8/D240/245E/Guerrini_President_Oro-2.jpg").read
end
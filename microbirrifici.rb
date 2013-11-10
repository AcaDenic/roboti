require 'capybara/dsl'
require 'spreadsheet'
require 'awesome_print'

Capybara.run_server = false
Capybara.default_driver = :selenium
Capybara.default_selector = :xpath

Spreadsheet.client_encoding = 'UTF-8'

class Microbirrifici
  include Capybara::DSL

  # Конструктор
  def initialize
    @eksel      = Spreadsheet::Workbook.new
    @radni_list = @eksel.create_worksheet
    @red        = 0
    @linkovi    = Array.new  # Прави празан низ. Ово је исто што и @linkovi = []
  end

  def go
    visit "http://www.microbirrifici.org/beer_english.aspx"
    get_links
    ap @linkovi.size
    get_data
    @eksel.write "microbirrifici-#{Time.now.hour}-#{Time.now.min}-#{Time.now.sec}.xls"
  end

  def get_links
    regioni = all('//table[@id="ucMenu_sx_grdListaRegioni"]/tbody/tr/td/table/tbody/tr/td/a').collect { |element| element[:href] }    
    regioni.each do |region|
      visit region
      all('//tr[@class="TDCampoChiaro"]/td[1]/a | //tr[@class="TDCampoScuro"]/td[1]/a').each do |element|
        @linkovi << element[:href]
      end
      if page.has_xpath?('//*[@id="grdListaProduttori"]/tbody/tr[102]/td/a')
        find('//*[@id="grdListaProduttori"]/tbody/tr[102]/td/a').click
        all('//tr[@class="TDCampoChiaro"]/td[1]/a | //tr[@class="TDCampoScuro"]/td[1]/a').each do |element|
          @linkovi << element[:href]
        end
      end
    end
  end
  

  # Пролази кроз све адресе и позива методу за прикупљање података 
  def get_data
    @linkovi.each do |link|
      collect_page_data link
    end
  end

  def collect_page_data(url)
    visit url
    puts "Processing #{url}....."
    @radni_list[@red, 0]  = find_by_xpath('//td/span[@id="lblNomeProd"]')
    @radni_list[@red, 1]  = find_by_xpath('//span[@id="lblTipologia"]')
    @radni_list[@red, 2]  = find_by_xpath('//span[@id="lblIndirizzo"]')
    @radni_list[@red, 3]  = find_by_xpath('//span[@id="lblLocalita"]')
    @radni_list[@red, 4]  = find_by_xpath('//span[@id="lblFax"]')
    @radni_list[@red, 5]  = find_by_xpath('//span[@id="hypEmail"]')
    @radni_list[@red, 6]  = find_by_xpath('//a[@id="hypSito"]')
    @radni_list[@red, 7]  = find_by_xpath('//span[@id="lblAnno"]')
    @radni_list[@red, 8]  = find_by_xpath('//span[@id="lblGiornoChiusura"]')
    @radni_list[@red, 9]  = find_by_xpath('//span[@id="lblOrariApertura"]')
    @radni_list[@red, 10] = yes_no(find('//img[@id="imgBassa"]')[:src])
    @radni_list[@red, 11] = yes_no(find('//img[@id="imgAlta"]')[:src])
    @radni_list[@red, 12] = yes_no(find('//img[@id="imgImpianti"]')[:src])
    @radni_list[@red, 13] = yes_no(find('//img[@id="imgCarta"]')[:src])
    @red += 1
  end

  private
  # Уместо да сваки да се пише if наредба направљена је метода која то ради само једном
  def find_by_xpath(xpath_selector)
    page.has_xpath?(xpath_selector) ? find(xpath_selector).text : ''
  end

  # Уколико је путања слике "http://www.microbirrifici.org/images/ok.gif" онда врати текст "Yes"
  # Ако не онда врати "No"
  def yes_no(image_path)
    image_path.include?('ok.gif') ? 'Yes' : 'No'
  end
end

pocetak = Time.now
microbirrifici = Microbirrifici.new
microbirrifici.go
kraj = Time.now
proteklo_vreme = Time.at((kraj - pocetak).to_i).gmtime.strftime('%R:%S')
puts "Завршено за #{proteklo_vreme}!"
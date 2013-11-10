require 'capybara/dsl'
require 'spreadsheet'
require 'awesome_print'

Capybara.run_server = false
Capybara.default_driver = :selenium

Spreadsheet.client_encoding = 'UTF-8'

class UrbanSpoon
  include Capybara::DSL

  # Конструктор
  def initialize
    @eksel      = Spreadsheet::Workbook.new
    @radni_list = @eksel.create_worksheet
    @red        = 0
    @linkovi    = Array.new  # Прави празан низ. Ово је исто што и @linkovi = []
  end

  def go
    visit "http://www.urbanspoon.com/nf/71/7105/7013/Melbourne/CBD/Coffee-Shops?last_filter=cuisine&page=1"
    paginate
    get_data
    @eksel.write "results-#{Time.now.hour}-#{Time.now.min}-#{Time.now.sec}.xls"
  end

  # Kupi sve linkove sa stranice i stavlja ih u niz
  # Niz je instance variable
  def get_links
    all(:xpath, '//*[@id="main-content"]/section[3]/div/ul/li[@class="row-fluid restaurant"]/div[@class="details"]/div[@class="title"]/a[@class="resto_name ga_event"]').each do |link|
      @linkovi << link[:href]
    end
    ap @linkovi.size
    puts "------------------------------------------------"
  end

  # Pokupi sve linkove za svih 400 i kusur kuhinja
  def paginate
    get_links
    while page.has_selector?('a.next_page')
      find('a.next_page').click
      get_links
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
    @radni_list[@red, 0]  = current_url
    @radni_list[@red, 1]  = find_by_xpath('//h1[@itemprop="name"]')
    @radni_list[@red, 2]  = find_by_xpath('//span[@class="street-address"]')
    @radni_list[@red, 3]  = ''
    @radni_list[@red, 4]  = find_by_xpath('//span[@class="locality"]')
    @radni_list[@red, 5]  = find_by_xpath('//span[@class="region"]')
    @radni_list[@red, 6]  = find_by_xpath('//span[@class="region"]/following-sibling::a[1]') # Царска фора са следећим елементом ;)
    @radni_list[@red, 7]  = find_by_xpath('//div[@class="phone tel"]')
    @radni_list[@red, 8]  = find_by_xpath('//div[@class="tags"]/span[@class="price"]')
    @radni_list[@red, 9]  = find_by_xpath('//div[@class="total"]').gsub("votes", "").strip
    @radni_list[@red, 10] = find_by_xpath('//div[@class="average digits rating"]')
    @radni_list[@red, 11] = find_by_xpath('//span[@class="posts_count"]')
    @radni_list[@red, 12] = page.has_xpath?('//i[@class="icon-globe"]/..') ? find(:xpath, '//i[@class="icon-globe"]/..')[:href] : ''
    @radni_list[@red, 13] = page.has_xpath?('//section[@class="compact"]/a') ? all(:xpath, '//section[@class="compact"]/a').collect { |a| a.text }.join(', ') : ''
    @radni_list[@red, 14] = page.has_xpath?('//div[@class="tags"]/a') ? all(:xpath, '//div[@class="tags"]/a').collect { |a| a.text }.join(', ') : ''
    @red += 1
  end

  private
  # Уместо да сваки да се пише if наредба направљена је метода која то ради само једном
  def find_by_xpath(xpath_selector)
    page.has_xpath?(xpath_selector) ? find(:xpath, xpath_selector).text : ''
  end
end

urban_spoon = UrbanSpoon.new
urban_spoon.go
require 'selenium-webdriver'
require 'byebug'
class GazelleMobileRetail

  def create_md5_hash(data_hash)
    data_string = ''
    data_hash.values.each do |val|
      data_string += val.to_s
    end
    Digest::MD5.hexdigest data_string
  end

  def scraper
    @already_inserted_hashes = Retailer.where("retailers = 'Gazelle'").pluck(:md5_hash)
    # chromedriver_path = '/home/areeba/datametric-marketdata/chromedriver'
    # Selenium::WebDriver::Chrome.driver_path = chromedriver_path
    # driver = Selenium::WebDriver.for :chrome
    # byebug
    @old_records = @already_inserted_hashes.clone
    url = "https://buy.gazelle.com/"
    @agent = Mechanize.new
    @agent.set_proxy('zproxy.lum-superproxy.io','22225', 'brd-customer-hl_b9c73d95-zone-businessprofiles','apx2ojz8d16p')
    @agent.open_timeout=1000
    @agent.read_timeout=1000
    page = @agent.get(url)
    total_iphone_count=page.css("ul.dropdown-menu")[1].css("li").count
    total_samsung_count=page.css("ul.dropdown-menu")[2].css("li").count
    #For Server
    Selenium::WebDriver::Chrome.driver_path = "#{Dir.pwd}/chromedriver"
    # Selenium::WebDriver::Chrome.driver_path = chromedriver_path
    capybara = Capybara::Session.new(:selenium_chrome_headless)
    #For Local
    # capybara = Capybara::Session.new(:selenium_chrome)
    i = 0
    while(i < total_iphone_count)
      break
      link = page.css("ul.dropdown-menu")[1].css("li a")[i]['href']
      inner_page(url + link,capybara,0)
      i+=1
    end
    i = 0
    while(i < total_samsung_count)
      link = page.css("ul.dropdown-menu")[2].css("li a")[i]['href']
      inner_page(url + link,capybara,0)
      i+=1
    end
    url = "https://buy.gazelle.com/collections/google-phones"
    inner_page(url, capybara,1)
    Retailer.where(retailers:"Gazelle", md5_hash: @old_records).update_all(is_deleted: true)
  end

  def inner_page(link,capybara,k)
  if(k == 0)
    carier = "&pf_t_carrier=Carrier%3AUnlocked"
  else
    carier = "?pf_t_carrier=Carrier%3AUnlocked"
  end
   link = link + carier
  #  begin
     newpage = @agent.get(link)
     capybara.visit(link)
     sleep(5)
     data = capybara.all(:css,'div.yc-product-item-inner a.yc-product-item-link').map {|link| link['href']}
     i = 0
     while(i < data.length)
      data_per_phone(data[i])
      i+=1
     end
    # rescue Exception => e
    #   byebug
    #   puts "Gazelle retailer inner_page exception -> #{e}"
    # end
  end

  def data_per_phone(link)
    # begin
     page = @agent.get(link)
     test = page.css("script[data-app='esc-out-of-stock']")[0]
    #  byebug
     data = JSON.parse(test)
     data_hash = {}
     page = @agent.get(link)
     heading = page.css("div.product-title h1").text
     head_data = heading.split(" ")
     storage = page.css(".non-selectable")[0].text.split(",")[1].squish
     length_head = head_data.length
     make = nil
     if(heading.include? "iPhone")
      make = "Apple"
     elsif(heading.include?"Google")
      make="Google"
     else
      make="Samsung"
     end
     model = heading.squish
     total = data.length
     colour = nil
     condition = nil
     main_condition = "Refurbished"
     price = nil
     inventory = nil
     shipping_cost = nil
     j = 0
      while(j < total)
        url = "?variant="
        variant = data[j]["id"].to_s
        url = link + url + variant
        json_request = @agent.get(url)
        discount_data = json_request.css("script[type='application/ld+json']")[0]
        # byebug
        # discounted_data = JSON.parse(discount_data) rescue nil
        discounted_data =  JSON.parse(discount_data.children.first.to_s.gsub("\n","").squish)
        puts 'here'
        # byebug
        next if discounted_data.nil?
        # byebug
        model_inner = json_request.css("div.product-title h1").text.squish
        storage_inner = json_request.css(".non-selectable")[0].text.split(",")[1].squish
        colour = data[j]["options"][0]
        condition = data[j]["options"][1]
        price = (data[j]["price"]/100.to_f)
        inventory = data[j]["inventory_quantity"]
        instock = nil
        if(inventory > 0)
         instock = "Available"
        else
         instock = "Unavailable"
        end
        if(price == discounted_data["offers"]["price"])
          discount_price = nil
        else
          discount_price = discounted_data["offers"]["price"]
        end
        data_hash = {}
        data_hash[:retailers] = "Gazelle"
        data_hash[:make] = make
        data_hash[:model] = model_inner
        data_hash[:storage] = storage_inner
        data_hash[:colour] = colour
        data_hash[:grade]= condition
        data_hash[:mainCondition] = main_condition
        data_hash[:inStock] = instock
        data_hash[:price] = price
        data_hash[:discount_price] = discount_price
        data_hash[:link] = url
        data_hash[:md5_hash] = create_md5_hash(data_hash)
        puts "Processing #{data_hash[:model]}  #{data_hash[:storage]}   #{data_hash[:price]}"
        @old_records = @old_records.reject {|e| e == data_hash[:md5_hash]}
        unless (@already_inserted_hashes.include? data_hash[:md5_hash])
          @already_inserted_hashes << data_hash.delete(:md5_hash)
          data_hash[:shippingcost] = nil
          data_hash[:currency] = "USD"
          data_hash[:is_visited] = true
          data_hash[:is_deleted] = false
          data_hash[:lastseen] =Time.now
          Retailer.create(data_hash)
          j+=1
        else
          j+=1
        end
      end
    # rescue Exception => e
    #   byebug
    #   puts "Gazelle retailer exception -> #{e}"
    # end
  end
end

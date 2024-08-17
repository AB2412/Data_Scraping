class OzMobilesOld
  DOMAIN = 'https://ozmobiles.com.au'
 # WEBDRIVER_HUB_URL = "http://vm74.corp.blockshopper.com:4444/wd/hub"
 # TARGET_RESOLUTION = [1280,1024]
 # CHROME_SWITCHES = %W(--window-size=#{TARGET_RESOLUTION[0]},#{TARGET_RESOLUTION[1]} --disable-translate)
 # CHROME_OPTIONS = {
 #   'args' => CHROME_SWITCHES
 # }
 def inner_request_json(link)
  #puts link
  uri = URI.parse(link.split("?").first + ".json")
  request = Net::HTTP::Get.new(uri)
  request["Authority"] = "ozmobiles.com.au"
  request["Sec-Ch-Ua"] = "\" Not;A Brand\";v=\"99\", \"Google Chrome\";v=\"97\", \"Chromium\";v=\"97\""
  request["Sec-Ch-Ua-Mobile"] = "?0"
  request["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.99 Safari/537.36"
  request["Sec-Ch-Ua-Platform"] = "\"Linux\""
  request["Accept"] = "*/*"
  request["Sec-Fetch-Site"] = "same-origin"
  request["Sec-Fetch-Mode"] = "cors"
  request["Sec-Fetch-Dest"] = "empty"
  request["Referer"] = link
  request["Accept-Language"] = "en-US,en;q=0.9"
  #request["Cookie"] = "secure_customer_sig=; localization=AU; cart_currency=AUD; _orig_referrer=; _landing_page=%2F; _y=42747c20-6408-4721-b1be-79b58403c29f; _shopify_y=42747c20-6408-4721-b1be-79b58403c29f; _gcl_au=1.1.1967785003.1643202140; _gid=GA1.3.1878028038.1643202142; _pin_unauth=dWlkPU9XSTVaakZtWTJVdE5UVTBNeTAwWkRka0xUazBOemN0WkROa1pqUXpZVGc1TkdSbA; hubspotutk=4ab4f92f069b7bc72159c2284256fbda; _ju_dm=cookie; _ju_dn=1; _ju_dc=3b633aa0-7ea8-11ec-8b67-739e46e945dc; _hjSessionUser_545323=eyJpZCI6ImFjNjQzNjExLTQ1NDUtNWYzNy1hM2FiLTQ3ZjM2Mzg3MDZmMyIsImNyZWF0ZWQiOjE2NDMyMDIxNDAxMzMsImV4aXN0aW5nIjp0cnVlfQ==; _gaexp=GAX1.3.0Rl8kJYFSgSHF6wcg6Ws4Q.19109.0; _s=ee497f8e-d3ee-4e33-8ac1-40db7f6c5c5e; _shopify_s=ee497f8e-d3ee-4e33-8ac1-40db7f6c5c5e; _shopify_sa_p=; _hjSession_545323=eyJpZCI6Ijc2ZTY5ZTJhLTNlOTQtNDczNi1hMzVjLTNjYzZhY2Y3MjY2YiIsImNyZWF0ZWQiOjE2NDMyNjMyNTg0ODEsImluU2FtcGxlIjpmYWxzZX0=; _hjAbsoluteSessionInProgress=0; _clck=1ngst6a|1|eyh|0; __hstc=157735141.4ab4f92f069b7bc72159c2284256fbda.1643202147953.1643202147953.1643263260084.2; __hssrc=1; locale_bar_accepted=1; _hjIncludedInSessionSample=0; shopify_pay_redirect=pending; outbrain_cid_fetch=true; _ju_v=4.1_5.05; _ga=GA1.3.1915639532.1643202140; __kla_id=eyIkZW1haWwiOiIiLCIkZmlyc3RfbmFtZSI6IiIsIiRsYXN0X25hbWUiOiIiLCIkcmVmZXJyZXIiOnsidHMiOjE2NDMyMDIxNDAsInZhbHVlIjoiIiwiZmlyc3RfcGFnZSI6Imh0dHBzOi8vb3ptb2JpbGVzLmNvbS5hdS8ifSwiJGxhc3RfcmVmZXJyZXIiOnsidHMiOjE2NDMyNjc3NDgsInZhbHVlIjoiIiwiZmlyc3RfcGFnZSI6Imh0dHBzOi8vb3ptb2JpbGVzLmNvbS5hdS8ifX0=; _clsk=frffww|1643267750753|17|1|i.clarity.ms/collect; _derived_epik=dj0yJnU9VEoweUpwYm42SVZzQmhkSzVkNzZ4bUllUzZCZ3N4SkEmbj1sTmVnR1NWVEdhSmJLZ2JYb0dQUVlBJm09MSZ0PUFBQUFBR0h5UnFZJnJtPTEmcnQ9QUFBQUFHSHlScVk; __hssc=157735141.12.1643263260084; _ga_XE3YHDXHME=GS1.1.1643263255.2.1.1643267840.0; _uetsid=313b13007ea811ecb5a021f8e8a4de7b; _uetvid=313c44f07ea811ec8a9edb600bb412b2; _shopify_sa_t=2022-01-27T07%3A17%3A23.789Z"
  
  req_options = {
   use_ssl: uri.scheme == "https",
  }
  
  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
   http.request(request)
  end
end

 def inner_request(link)
  p link
  uri = URI.parse(link)
  request = Net::HTTP::Get.new(uri)
  request["Authority"] = "ozmobiles.com.au"
  request["Cache-Control"] = "max-age=0"
  request["Sec-Ch-Ua"] = "\" Not;A Brand\";v=\"99\", \"Google Chrome\";v=\"97\", \"Chromium\";v=\"97\""
  request["Sec-Ch-Ua-Mobile"] = "?0"
  request["Sec-Ch-Ua-Platform"] = "\"Linux\""
  request["Upgrade-Insecure-Requests"] = "1"
  request["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.99 Safari/537.36"
  request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
  request["Sec-Fetch-Site"] = "same-origin"
  request["Sec-Fetch-Mode"] = "navigate"
  request["Sec-Fetch-User"] = "?1"
  request["Sec-Fetch-Dest"] = "document"
  request["Referer"] = "https://ozmobiles.com.au/collections/iphones"
  request["Accept-Language"] = "en-US,en;q=0.9"
  #request["Cookie"] = "secure_customer_sig=; localization=AU; cart_currency=AUD; _orig_referrer=; _landing_page=%2F; _y=42747c20-6408-4721-b1be-79b58403c29f; _shopify_y=42747c20-6408-4721-b1be-79b58403c29f; _gcl_au=1.1.1967785003.1643202140; _gid=GA1.3.1878028038.1643202142; _pin_unauth=dWlkPU9XSTVaakZtWTJVdE5UVTBNeTAwWkRka0xUazBOemN0WkROa1pqUXpZVGc1TkdSbA; hubspotutk=4ab4f92f069b7bc72159c2284256fbda; _ju_dm=cookie; _ju_dn=1; _ju_dc=3b633aa0-7ea8-11ec-8b67-739e46e945dc; _hjSessionUser_545323=eyJpZCI6ImFjNjQzNjExLTQ1NDUtNWYzNy1hM2FiLTQ3ZjM2Mzg3MDZmMyIsImNyZWF0ZWQiOjE2NDMyMDIxNDAxMzMsImV4aXN0aW5nIjp0cnVlfQ==; _gaexp=GAX1.3.0Rl8kJYFSgSHF6wcg6Ws4Q.19109.0; _s=ee497f8e-d3ee-4e33-8ac1-40db7f6c5c5e; _shopify_s=ee497f8e-d3ee-4e33-8ac1-40db7f6c5c5e; _shopify_sa_p=; _hjSession_545323=eyJpZCI6Ijc2ZTY5ZTJhLTNlOTQtNDczNi1hMzVjLTNjYzZhY2Y3MjY2YiIsImNyZWF0ZWQiOjE2NDMyNjMyNTg0ODEsImluU2FtcGxlIjpmYWxzZX0=; _hjAbsoluteSessionInProgress=0; _clck=1ngst6a|1|eyh|0; __hstc=157735141.4ab4f92f069b7bc72159c2284256fbda.1643202147953.1643202147953.1643263260084.2; __hssrc=1; locale_bar_accepted=1; _hjIncludedInSessionSample=0; shopify_pay_redirect=pending; _ju_v=4.1_5.05; __kla_id=eyIkZW1haWwiOiIiLCIkZmlyc3RfbmFtZSI6IiIsIiRsYXN0X25hbWUiOiIiLCIkcmVmZXJyZXIiOnsidHMiOjE2NDMyMDIxNDAsInZhbHVlIjoiIiwiZmlyc3RfcGFnZSI6Imh0dHBzOi8vb3ptb2JpbGVzLmNvbS5hdS8ifSwiJGxhc3RfcmVmZXJyZXIiOnsidHMiOjE2NDMyNjkwMjEsInZhbHVlIjoiIiwiZmlyc3RfcGFnZSI6Imh0dHBzOi8vb3ptb2JpbGVzLmNvbS5hdS8ifX0=; _shopify_sa_t=2022-01-27T07%3A37%3A01.305Z; _ga=GA1.1.1915639532.1643202140; _uetsid=313b13007ea811ecb5a021f8e8a4de7b; _uetvid=313c44f07ea811ec8a9edb600bb412b2; _derived_epik=dj0yJnU9Tk5udnFIYklyYVhGR0dCV0ZGQmlyOFR4bFZhaDYxRjEmbj1QVG5Oa3hidXkzZjNYNmQtMHAtanZRJm09MSZ0PUFBQUFBR0h5UzU0JnJtPTEmcnQ9QUFBQUFHSHlTNTQ; __hssc=157735141.15.1643263260084; _clsk=frffww|1643269250476|25|1|i.clarity.ms/collect; _ga_XE3YHDXHME=GS1.1.1643263255.2.1.1643269250.0"
  req_options = {
   use_ssl: uri.scheme == "https",
  }
  
  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
   http.request(request)
   end
 end

 def proces_links(links)
  links.each do |link|
    next if link.include? "39976207483030" # its not a phone
    response = inner_request(link)
    document = Nokogiri::HTML(response.body)
    in_stock_variants = document.css("select#Variant option[value]").map{|e| e['value']}
    response_json = inner_request_json(link)
    data = JSON.parse(response_json.body)
    make = data["product"]["vendor"]
    model = data["product"]["title"]
    variants = data["product"]["variants"]
    variants.each do |variant|
      #price =  variant["price"]
      price =  variant["compare_at_price"]
      discountPrice =  variant["price"]
      id = variant["id"].to_s
      
	    #next if id != "41069169606806"

      if price.nil? or price.empty?
        puts "see no discount"
        puts link.split("=").first  + "=" + id
        price = discountPrice
        discountPrice = nil
      end
      #dis_Percentage = (((price.to_f - discountPrice.to_f)/price.to_f)*100).to_i rescue 0
      
      gradeArray = variant["option3"]
      inStock = 'no'
      inStock = 'yes' if in_stock_variants.include? id
      if variant["option1"].scan(/\d/).empty?
        storage = variant["option2"]
        color = variant["option1"]
      else
        storage = variant["option1"]
        color = variant["option2"]
      end
      
      data_hash = {
        retailers: 'ozmobiles',
        make: make.capitalize,
        model: model,
        currency: 'AUD',
        price: price,
        storage: storage,
        colour: color,
        grade: gradeArray,
        discount_price: discountPrice,
        shippingcost: 0,
        inStock: inStock,
        link: link.split("=").first  + "=" + id
      }
      data_hash[:is_visited] = true
      data_hash[:is_deleted] = false
      search_hash={}
      search_hash[:retailers] = "ozmobiles"
      search_hash[:make] =make
      search_hash[:model] =model
      search_hash[:storage] =storage
      search_hash[:colour] = color
      search_hash[:grade]=gradeArray
      record = Retailer.find_by(data_hash)
      search_record = Retailer.find_by(search_hash)
      if record
        puts 'hurrah.. already exist'
      elsif search_record
        data_hash[:lastseen] =Time.now
        search_record.update(data_hash)
      else
        data_hash[:lastseen] =Time.now
        Retailer.create(data_hash)
      end
    end
   end
#  end
  end

 def scraper()
  Retailer.where(retailers:"ozmobiles").update_all('is_visited': false) 
  # server ...........
  # Capybara.register_driver :selenium do |app|
  #   caps = Selenium::WebDriver::Remote::Capabilities.chrome(:chromeOptions => CHROME_OPTIONS)
  #   opts   = {
  #     :browser     => :remote,
  #     :url         => WEBDRIVER_HUB_URL,
  #     :desired_capabilities => caps
  #   }
  #   Capybara::Selenium::Driver.new(app, opts)
  # end
  # Capybara.configure do |config|
  #   config.default_driver         = :selenium
  #   config.javascript_driver      = :selenium
  # end
  
  # Capybara.ignore_hidden_elements = false
  # Capybara.default_max_wait_time = 60
  # capybara = Capybara::Session.new(:selenium)

  # Server...........
   Selenium::WebDriver::Chrome.driver_path = '/usr/bin/chromedriver'
   capybara = Capybara::Session.new(:selenium_chrome_headless)
  # #.....................
  # Local...........
  #capybara = Capybara::Session.new(:selenium_chrome)
  data_array = []
  header_flag = true
  #skip_flag = true
  phone_categories = ['oppo','others','iphones','samsung']
  phone_categories.each do |cat|
    main_url = "https://ozmobiles.com.au/collections/" + cat
    capybara.visit(main_url)
    while true
      retries = 15
      begin
        break if retries == 0
        puts "processing --> #{main_url}"
        links = capybara.find_all(".product-grid > div").map{|e| e.find_all("a").first["href"]}
        proces_links(links)
        break
      rescue
        retries -= 1
        sleep 3
        capybara.refresh
        links = capybara.find_all(".product-grid > div").map{|e| e.find_all("a").first["href"]}
        proces_links(links)

      end
    end
  
  end
 byebug 
  unvisited_links=Retailer.where(retailers:'ozmobiles', is_visited: false).pluck(:link)
  if (unvisited_links.count>0)
    proces_links(unvisited_links)
  end  
    Retailer.where(retailers:'ozmobiles', is_visited: false).update_all(is_deleted: true)
  #  Retailer.where(retailers:'ozmobiles', is_visited: true).update_all(is_deleted: false)
 end
end
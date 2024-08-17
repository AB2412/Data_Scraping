class Ozmobiles

  def create_md5_hash(data_hash)
    data_string = ''
    data_hash.values.each do |val|
      data_string += val.to_s
    end
    Digest::MD5.hexdigest data_string
  end

  def inner_request_json(link)
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
    req_options = {
    use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
 end

 def proces_links(links)
  links.each do |link|
    link = (link.include? "https://ozmobiles.com.au") ? link : "https://ozmobiles.com.au" + link
    next if link.include? "39976207483030" # its not a phone
    next if link.include? "collections"
    response          = inner_request(link)
    document          = Nokogiri::HTML(response.body)
    in_stock_variants = document.css(".product-form__inventory").text
    response_json     = inner_request_json(link)
    data              = JSON.parse(response_json.body) rescue []
    next if data.empty?
    make              = data["product"]["vendor"]
    model             = data["product"]["title"]
    variants          = data["product"]["variants"]
    variants.each do |variant|
      price =  variant["compare_at_price"]
      discountPrice =  variant["price"]
      if discountPrice.to_f > price.to_f
        price =  variant["price"]
        discountPrice =  variant["compare_at_price"]
      end
      id = variant["id"].to_s
      if price.nil? or price.empty?
        puts "see no discount"
        puts link.split("=").first  + "?variant=" + id
        price = discountPrice
        discountPrice = nil
      end
      storage    = nil
      mainCondition = nil
      color      = nil
      (!(in_stock_variants.include? 'Sold')) ? inStock = "Yes" : inStock = "No"
      (1..3).each do |count|
        next if variant["option#{count}"].nil?
        variable = variant["option#{count}"]
        if (!variant["option#{count}"][/\d/].nil?)
          storage = variant["option#{count}"]
        elsif ( (variable.include? "New") || (variable.include? "Ex-Demo") || (variable.include? "Very Good") || (variable.include? "Average") || (variable.include? "Fair") || (variable.include? "Excellent"))  
          mainCondition = variable
        else
          color = variant["option#{count}"]
        end
      end
      data_hash = {
        retailers: 'ozmobiles',
        make: make.capitalize,
        model: model,
        storage: storage,
        colour: color,
        grade: nil,
        mainCondition: mainCondition,
        inStock: inStock,
        price: price,
        discount_price: discountPrice,
        link: link.split("=").first  + "?variant=" + id
      }
      data_hash[:md5_hash] = create_md5_hash(data_hash)
      @old_records         = @old_records.reject {|e| e == data_hash[:md5_hash]}
      next if @already_inserted_hashes.include? data_hash[:md5_hash]
      @already_inserted_hashes << data_hash.delete(:md5_hash)
      data_hash[:shippingcost] = nil
      data_hash[:currency]     = "AUD"
      data_hash[:is_visited]   = true
      data_hash[:is_deleted]   = false
      data_hash[:lastseen]     = Time.now
      Retailer.create(data_hash)
    end
   end
  end

  def scraper
    # byebug
    @already_inserted_hashes = Retailer.where("retailers = 'Ozmobiles'").pluck(:md5_hash)
    @old_records             = @already_inserted_hashes.clone
    # chromedriver_path = '/home/areeba/datametric-marketdata/chromedriver'
    Selenium::WebDriver::Chrome.driver_path = "#{Dir.pwd}/chromedriver"
    capybara = Capybara::Session.new(:selenium_chrome_headless)

    capybara         = Capybara::Session.new(:selenium_chrome_headless)
    data_array       = []
    header_flag      = true
    phone_categories = ['iphones','samsung','others']
    phone_categories.each_with_index do |cat,index|
      # byebug
      main_url = "https://ozmobiles.com.au/"
      capybara.visit(main_url)
      while true
        retries = 15
        begin
          break if retries == 0
          puts "processing --> #{main_url}"
          page  = Nokogiri::HTML(capybara.body)
          links = page.css(".nav-bar__item")[index].css("li").css("ul a").map{|a| a["href"]}
          proces_links(links)
          break
        rescue
          retries -= 1
          sleep 3
          capybara.refresh
          page  = Nokogiri::HTML(capybara.body) rescue nil
          links = page.css(".nav-bar__item")[index].css("li").css("ul a").map{|a| a["href"]}
          proces_links(links)
        end
      end
    end
    Retailer.where(retailers:'ozmobiles', md5_hash: @old_records).update_all(is_deleted: true)
  end
end


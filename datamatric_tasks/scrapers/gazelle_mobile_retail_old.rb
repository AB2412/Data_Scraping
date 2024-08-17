class GazelleMobileReatailOld
  def inner_page(link,capybara,k)
  if(k==0)
    carier="&pf_t_carrier=Carrier%3AUnlocked"
  else
    carier="?pf_t_carrier=Carrier%3AUnlocked"
  end
   link=link+carier
   @agent = Mechanize.new
   newpage = @agent.get(link)
   capybara.visit(link)
   sleep(5)
   data=capybara.all(:css,'div.yc-product-item-inner a.yc-product-item-link').map {|link| link['href']}
   i=0
   while(i<data.length)
    data_per_phone(data[i])
    i+=1
   end
  end

  def data_per_phone(link)
   @agent = Mechanize.new
   page = @agent.get(link)
   test=page.css("script[data-app='esc-out-of-stock']")[0]
   data=JSON.parse(test)
   data_hash = {}
   page = @agent.get(link)
   heading=page.css("div.product-title h1").text
   head_data=heading.split(" ")
   storage=head_data[-2]
   length_head=head_data.length
   make=nil
   if(heading.include? "iPhone")
    make="Apple"
   elsif(heading.include?"Google")
    make="Google"
   else 
    make="Samsung"
   end
   model=heading.split(storage)[0]
   total=data.length
   colour=nil
   condition=nil
   main_condition="Refurbished"
   price=nil
   inventory=nil
   shipping_cost=nil
   j=0
   while(j<total)
    url="?variant="
    variant=data[j]["id"].to_s
    url=link+url+variant
    json_request=@agent.get(url)
    discount_data=json_request.css("script[type='application/ld+json']")[0]
    discounted_data=JSON.parse(discount_data)
    colour=data[j]["options"][0]
    condition=data[j]["options"][1]
    price=(data[j]["price"]/100)
    inventory=data[j]["inventory_quantity"]
    instock=nil
    if(inventory>0)
     instock="Available"
    else
     instock="Unavailable"
    end
    if(price==discounted_data["offers"]["price"])
      discount_price=nil
    else
      discount_price=discounted_data["offers"]["price"]
    end
    data_hash={}
    data_hash[:retailers] = "Gazelle"
    data_hash[:make] =make
    data_hash[:model] =model.gsub(make,"")
    data_hash[:storage] =storage
    data_hash[:colour] = colour
    data_hash[:grade]=condition
    data_hash[:mainCondition] = main_condition
    data_hash[:price] = price
    data_hash[:shippingcost] = nil
    data_hash[:inStock] = instock
    data_hash[:currency] = "USD"
    data_hash[:link] = url
    data_hash[:discount_price]=discount_price
    data_hash[:is_visited] = true
    data_hash[:is_deleted] = false
    search_hash={}
    search_hash[:retailers] = "Gazelle"
    search_hash[:make] =make
    search_hash[:model] =model.gsub(make,"")
    search_hash[:storage] =storage
    search_hash[:colour] = colour
    search_hash[:grade]=condition
    search_hash[:mainCondition] = main_condition
    record = Retailer.find_by(data_hash)
    search_record = Retailer.find_by(search_hash)
    if record
     puts 'hurrah.. already exist'
    elsif search_record
      data_hash[:lastseen] = Time.now
      search_record.update(data_hash)
    else  
     data_hash[:lastseen] =Time.now
     Retailer.create(data_hash)
   end
    j+=1
   end
  end
 
  def scraper()
    
    Retailer.where(retailers:"Gazelle").update_all('is_visited': false) 
    url="https://buy.gazelle.com/"
    @agent = Mechanize.new
    page = @agent.get(url)
    total_iphone_count=page.css("ul.dropdown-menu")[1].css("li").count
    total_samsung_count=page.css("ul.dropdown-menu")[2].css("li").count
    #For Server
    Selenium::WebDriver::Chrome.driver_path = '/usr/bin/chromedriver'
    capybara = Capybara::Session.new(:selenium_chrome_headless)
    #For Local
    #capybara = Capybara::Session.new(:selenium_chrome)
    i=0
    while(i<total_iphone_count)
      link=page.css("ul.dropdown-menu")[1].css("li a")[i]['href']
      inner_page(url+link,capybara,0)
      i+=1
    end
    i=0
    while(i<total_samsung_count)
      link=page.css("ul.dropdown-menu")[2].css("li a")[i]['href']
      inner_page(url+link,capybara,0)
      i+=1
    end
    url="https://buy.gazelle.com/collections/google-phones"
    inner_page(url,capybara,1)
    Retailer.where(retailers:"Gazelle", is_visited:false).update_all(is_deleted: true)
    Retailer.where(retailers:"Gazelle", is_visited: true).update_all(is_deleted: false)
  end
end
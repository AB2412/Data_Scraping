
class GreengadgetsOld
  DOMAIN = 'https://shop.greengadgets.net.au'
  
  def cat_request(cat,page)
   uri = URI.parse("https://shop.greengadgets.net.au/collections/#{cat}?page=#{page.to_s}")
   puts uri
   request = Net::HTTP::Get.new(uri)
   request["Authority"] = "shop.greengadgets.net.au"
   request["Sec-Ch-Ua"] = "\"Google Chrome\";v=\"95\", \"Chromium\";v=\"95\", \";Not A Brand\";v=\"99\""
   request["Sec-Ch-Ua-Mobile"] = "?0"
   request["Sec-Ch-Ua-Platform"] = "\"Linux\""
   request["Upgrade-Insecure-Requests"] = "1"
   request["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36"
   request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
   request["Sec-Fetch-Site"] = "same-origin"
   request["Sec-Fetch-Mode"] = "navigate"
   request["Sec-Fetch-User"] = "?1"
   request["Sec-Fetch-Dest"] = "document"
   request["Referer"] = "https://shop.greengadgets.net.au/collections/apple?page=2"
   request["Accept-Language"] = "en-US,en;q=0.9"
   req_options = {
    use_ssl: uri.scheme == "https",
   }
   response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
   end
  end

  def inner_request(link)
   puts link
   uri = URI.parse(link)
   request = Net::HTTP::Get.new(uri)
   request["Authority"] = "shop.greengadgets.net.au"
   request["Sec-Ch-Ua"] = "\"Google Chrome\";v=\"95\", \"Chromium\";v=\"95\", \";Not A Brand\";v=\"99\""
   request["Sec-Ch-Ua-Mobile"] = "?0"
   request["Sec-Ch-Ua-Platform"] = "\"Linux\""
   request["Upgrade-Insecure-Requests"] = "1"
   request["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36"
   request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
   request["Sec-Fetch-Site"] = "none"
   request["Sec-Fetch-Mode"] = "navigate"
   request["Sec-Fetch-User"] = "?1"
   request["Sec-Fetch-Dest"] = "document"
   request["Accept-Language"] = "en-US,en;q=0.9"
   req_options = {
    use_ssl: uri.scheme == "https",
   }
   response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
   end
  end
  
  def process_links(links)
    links.each do |link|
      link = link.gsub("/collections/samsung","")
      response = inner_request(link)
      document = Nokogiri::HTML(response.body)
      make = document.css(".product-meta__title.heading.h1").first.text.split[0].strip
      model =  document.css(".product-meta__title.heading.h1").first.text.split("(").first.split[1..-1].join(" ").strip
      main_condition = document.css(".product-meta__title.heading.h1").first.text.split("(").last.gsub(")","").strip
      options = document.css("select[id*='product-select-'] option")
      # if csv_flag
      #   id = link.split("=").last
      #   options = options.select{|e| e["value"] == id}
      # end

      options.each do |option|
        instock = 'yes'
        instock = 'no' if option['disabled'] == "disabled"
        variant = option["value"]
        # if csv_flag
        #   v_link = link
        # else
        link = link.split('?variant=')[0]
        v_link = link + "?variant=" + variant
        # end
        response = inner_request(v_link)
        document = Nokogiri::HTML(response.body)
        prices = document.css("div.price-list > span")
        if prices.count == 2
         price = document.css("div.price-list > span.price.price--compare").first.text.split("$").last
         dsicountPrice = document.css("div.price-list > span.price.price--highlight").first.text.split("$").last

        elsif prices.count == 1
         dsicountPrice = nil
         price = document.css("div.price-list > span").first.text.split("$").last
        else
         puts "see no price"
        end

        option = option.text.strip
        grade = option.split("/").last.split("-").first.strip
        #gradeArray = {"grade" => grade, "main_condition" => main_condition}
        make = make.capitalize
        make = "Google" if make == "Google-pixel"
        data_hash = {
         retailers: 'greengadgets',
         make:make ,
         model: model,
         mainCondition: main_condition,
         currency:  'AUD',
         discount_price: dsicountPrice,
         price: price,
         #price: option.split("-")[-1].gsub("$","").strip,
         storage: option.split("/").first.strip,
         colour: option.split("/")[1].strip,
         grade: grade,
         shippingcost: nil,
         inStock: instock,
         link: v_link
        }
        data_hash[:is_visited] = true
        data_hash[:is_deleted] = false
        search_hash={}
        search_hash[:retailers] = "greengadgets"
        search_hash[:make] =make
        search_hash[:model] =model
        search_hash[:storage] =option.split("/").first.strip,
        search_hash[:colour] = option.split("/")[1].strip,
        search_hash[:grade]=grade
        search_hash[:mainCondition]=main_condition
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
  end
 
  def scraper()
   Retailer.where(retailers:"greengadgets").update_all('is_visited': false) 
   data_array = []
   header_flag = false
   phone_categories = ['samsung','google-pixel','apple', 'smartphones']

   phone_categories.each do |cat|
     page = 1
     while true
       response = cat_request(cat,page)
       document = Nokogiri::HTML(response.body)
       mobile_links = document.css(".product-item.product-item--vertical > a").map{|e| DOMAIN + e['href']} rescue []
       break if mobile_links.empty?
       process_links(mobile_links)
       page += 1
     end
   end

   unvisited_links=Retailer.where(retailers:'greengadgets', is_visited: false).pluck(:link)
   if (unvisited_links.count > 0)
     process_links(unvisited_links)
   end
   Retailer.where(retailers:'greengadgets', is_visited: false).update_all(is_deleted: true)
  end
end
 puts "***Done***"
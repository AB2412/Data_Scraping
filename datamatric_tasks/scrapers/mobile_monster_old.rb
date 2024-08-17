class MobileMonsterOld
  def main_request
   uri = URI.parse("https://mobilemonster.com.au/sell-your-phone/")
   request = Net::HTTP::Get.new(uri)
   request["Authority"] = "mobilemonster.com.au"
   request["Cache-Control"] = "max-age=0"
   request["Sec-Ch-Ua"] = "\" Not;A Brand\";v=\"99\", \"Google Chrome\";v=\"97\", \"Chromium\";v=\"97\""
   request["Sec-Ch-Ua-Mobile"] = "?0"
   request["Sec-Ch-Ua-Platform"] = "\"Linux\""
   request["Upgrade-Insecure-Requests"] = "1"
   request["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.71 Safari/537.36"
   request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
   request["Sec-Fetch-Site"] = "cross-site"
   request["Sec-Fetch-Mode"] = "navigate"
   request["Sec-Fetch-User"] = "?1"
   request["Sec-Fetch-Dest"] = "document"
   request["Referer"] = "https://www.google.com/"
   request["Accept-Language"] = "en-US,en;q=0.9"
   req_options = {
    use_ssl: uri.scheme == "https",
   }
   response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
   end
  end

  def brand_request(link , cookie)
   uri = URI.parse(link)
   request = Net::HTTP::Get.new(uri)
   request["Authority"] = "mobilemonster.com.au"
   request["Sec-Ch-Ua"] = "\" Not;A Brand\";v=\"99\", \"Google Chrome\";v=\"97\", \"Chromium\";v=\"97\""
   request["Sec-Ch-Ua-Mobile"] = "?0"
   request["Sec-Ch-Ua-Platform"] = "\"Linux\""
   request["Upgrade-Insecure-Requests"] = "1"
   request["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.71 Safari/537.36"
   request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
   request["Sec-Fetch-Site"] = "same-origin"
   request["Sec-Fetch-Mode"] = "navigate"
   request["Sec-Fetch-User"] = "?1"
   request["Sec-Fetch-Dest"] = "document"
   request["Referer"] = "https://mobilemonster.com.au/sell-your-phone/"
   request["Accept-Language"] = "en-US,en;q=0.9"
   request["Cookie"] = cookie
   req_options = {
    use_ssl: uri.scheme == "https",
   }
   response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
   end
  end

  def phone_request(phone_link , cookie , brand)
   uri = URI.parse(phone_link)
   request = Net::HTTP::Get.new(uri)
   request["Authority"] = "mobilemonster.com.au"
   request["Cache-Control"] = "max-age=0"
   request["Sec-Ch-Ua"] = "\" Not;A Brand\";v=\"99\", \"Google Chrome\";v=\"97\", \"Chromium\";v=\"97\""
   request["Sec-Ch-Ua-Mobile"] = "?0"
   request["Sec-Ch-Ua-Platform"] = "\"Linux\""
   request["Upgrade-Insecure-Requests"] = "1"
   request["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.71 Safari/537.36"
   request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
   request["Sec-Fetch-Site"] = "same-origin"
   request["Sec-Fetch-Mode"] = "navigate"
   request["Sec-Fetch-User"] = "?1"
   request["Sec-Fetch-Dest"] = "document"
   request["Referer"] = "https://mobilemonster.com.au/sell-your-phone/#{brand}"
   request["Accept-Language"] = "en-US,en;q=0.9"
   request["Cookie"] = cookie

   req_options = {
    use_ssl: uri.scheme == "https",
   }

   response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
   end
  end

  def prepare_gradeArray(phone_body , ind)
   array = []
   gradehash = {}
   gradehash[:condition] = nil
   price = 0
   if ind == 0
    price = phone_body.css("#condition-new a.condition-icon").attr("data-price").value.to_f
    gradehash[:condition] = "as_new"
   elsif ind == 1
    price = phone_body.css("#condition-working a.condition-icon").attr("data-price").value.to_f
    gradehash[:condition] = "working"
   elsif ind == 2
    price = phone_body.css("#condition-dead a.condition-icon").attr("data-price").value.to_f
    gradehash[:condition] = "dead"
   end
   array << gradehash
   [array , price]
  end
  def has_storage(str)
     if(str==nil)
      return 0;
     else
      return str.count("0-9")
     end
  end
  def scraper
   Buyback.where(retailers:"MobileMonster").update_all('is_visited': false)
   response = main_request
   cookie = response.response["set-cookie"]
   body = Nokogiri::HTML(response.body)
   all_brands = body.css(".brand-block").map{|e| "https://mobilemonster.com.au" + e.attr("href")}
   brands = body.css(".brand-block").map{|e| e.css(".brand-block-brand img").attr("alt").value}
   all_brands.each_with_index do |brand_link , ind|
    brand = brands[ind]
    response = brand_request(brand_link , cookie)
    brand_body = Nokogiri::HTML(response.body)
    phones = brand_body.css(".device-block").reject{|e| e.css(".device-link").text.include? "Watch" or e.css(".device-link").text.include? "Pad" or e.css(".device-link").text.include? "Pod"}
    phones_links = phones.map{|e| "https://mobilemonster.com.au" + e.css(".device-link").attr("href").value}
    phones_links.each do |phone_link|
     response = phone_request(phone_link , cookie , brand)
     phone_body = Nokogiri::HTML(response.body)
     phone = phone_body.css("#phone-step-1")
     phone_name = phone_body.css("#phone-step-1 div[align='center']").first.css("h1").first.text.squish
     3.times do |ind|
      phone_storage=phone_name.split.last.strip
      phone_model=phone_name.split(brand, 2).last.strip
      phone_model=phone_model.split(phone_storage).last.strip
      require_make=["Apple", "Google", "Huawei", "Microsoft", "Motorola", "Nokia",  "OPPO", "Samsung","Sony"]
      if(has_storage(phone_storage)==0)
        phone_storage=nil
        phone_model=phone_name.gsub(brand,"")
      end
      data_hash = {}
      data_hash[:retailers] = "MobileMonster"
      data_hash[:make] =  brand.capitalize
      data_hash[:model] = phone_model.strip
      data_hash[:storage] = phone_storage
      data_hash[:color] = nil
      data_hash[:gradeArray] , data_hash[:price] = prepare_gradeArray(phone_body , ind)
      data_hash[:gradeDetails] = nil
      data_hash[:discountedprice] = nil
      data_hash[:discountedPercentage] = nil
      data_hash[:currency] = "AUD"
      data_hash[:features] = nil
      data_hash[:link] = phone_link
      data_hash[:is_visited] = true
      data_hash[:is_deleted] = false
      search_hash={}
      search_hash[:retailers] = "MobileMonster"
      search_hash[:make] =brand.capitalize
      search_hash[:model] =phone_model.strip
      search_hash[:storage] =phone_storage
      search_hash[:gradeArray]=data_hash[:gradeArray].to_s
      data_hash[:gradeArray]=search_hash[:gradeArray]
      record = Buyback.find_by(data_hash)
      search_record = Buyback.find_by(search_hash)
      if(require_make.include? brand)
         if record
           puts 'hurrah.. already exist'
         elsif search_record
           data_hash[:lastseen] =Time.now
           search_record.update(data_hash)
         else  
           data_hash[:lastseen] =Time.now
           Buyback.create(data_hash)
         end
      end
     end
    end
  end
  Buyback.where(retailers:'MobileMonster', is_visited: false).update_all(is_deleted: true)
 end
end
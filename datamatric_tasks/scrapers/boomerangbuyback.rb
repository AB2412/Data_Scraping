
class BoomerangBuyback

	def main_request
		uri = URI.parse("https://www.boomerangbuyback.com.au/search.aspx")
		request = Net::HTTP::Get.new(uri)
		request["Connection"] = "keep-alive"
		request["Cache-Control"] = "max-age=0"
		request["Sec-Ch-Ua"] = "\" Not;A Brand\";v=\"99\", \"Google Chrome\";v=\"91\", \"Chromium\";v=\"91\""
		request["Sec-Ch-Ua-Mobile"] = "?1"
		request["Upgrade-Insecure-Requests"] = "1"
		request["User-Agent"] = "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Mobile Safari/537.36"
		request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
		request["Sec-Fetch-Site"] = "cross-site"
		request["Sec-Fetch-Mode"] = "navigate"
		request["Sec-Fetch-User"] = "?1"
		request["Sec-Fetch-Dest"] = "document"
		request["Accept-Language"] = "en-US,en;q=0.9"
		#request["Cookie"] = "ASP.NET_SessionId=sbwveflype1iuo2lujxfrm0i"
		req_options = {
		use_ssl: uri.scheme == "https",
		}
		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		http.request(request)
	end
		response
	end

	def select_mobile_category(cookie_value)
		uri = URI.parse("https://www.boomerangbuyback.com.au/SearchDropDownUpdate.aspx")
		request = Net::HTTP::Post.new(uri)
		request.content_type = "application/x-www-form-urlencoded; charset=UTF-8"
		request["Connection"] = "keep-alive"
		request["Sec-Ch-Ua"] = "\" Not;A Brand\";v=\"99\", \"Google Chrome\";v=\"91\", \"Chromium\";v=\"91\""
		request["Accept"] = "*/*"
		request["X-Requested-With"] = "XMLHttpRequest"
		request["Sec-Ch-Ua-Mobile"] = "?0"
		request["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36"
		request["Origin"] = "https://www.boomerangbuyback.com.au"
		request["Sec-Fetch-Site"] = "same-origin"
		request["Sec-Fetch-Mode"] = "cors"
		request["Sec-Fetch-Dest"] = "empty"
		request["Referer"] = "https://www.boomerangbuyback.com.au/search.aspx"
		request["Accept-Language"] = "en-US,en;q=0.9"
		request["Cookie"] = cookie_value
		request.body = "Category=Mobile Phones&Brand="
		req_options = {
		use_ssl: uri.scheme == "https",
		}

		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		http.request(request)
		end
		response
	end

	def select_mobile(mobile, cookie_value)
		uri = URI.parse("https://www.boomerangbuyback.com.au/search_listing.aspx")
		request = Net::HTTP::Post.new(uri)
		request.content_type = "application/x-www-form-urlencoded; charset=UTF-8"
		request["Connection"] = "keep-alive"
		request["Sec-Ch-Ua"] = "\" Not;A Brand\";v=\"99\", \"Google Chrome\";v=\"91\", \"Chromium\";v=\"91\""
		request["Accept"] = "*/*"
		request["X-Requested-With"] = "XMLHttpRequest"
		request["Sec-Ch-Ua-Mobile"] = "?1"
		request["User-Agent"] = "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Mobile Safari/537.36"
		request["Origin"] = "https://www.boomerangbuyback.com.au"
		request["Sec-Fetch-Site"] = "same-origin"
		request["Sec-Fetch-Mode"] = "cors"
		request["Sec-Fetch-Dest"] = "empty"
		request["Referer"] = "https://www.boomerangbuyback.com.au/search.aspx"
		request["Accept-Language"] = "en-US,en;q=0.9"
		request["Cookie"] = cookie_value
		request.body = "Category=Mobile Phones&Brand=#{mobile}&NameEx="
		req_options = {
		use_ssl: uri.scheme == "https",
	}
		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		http.request(request)
		end
		response
	end

	def mobile_details(link, cookie_value)
		uri = URI.parse("https://www.boomerangbuyback.com.au/#{link}")
		request = Net::HTTP::Get.new(uri)
		request["Connection"] = "keep-alive"
		request["Sec-Ch-Ua"] = "\" Not;A Brand\";v=\"99\", \"Google Chrome\";v=\"91\", \"Chromium\";v=\"91\""
		request["Sec-Ch-Ua-Mobile"] = "?1"
		request["Upgrade-Insecure-Requests"] = "1"
		request["User-Agent"] = "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Mobile Safari/537.36"
		request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
		request["Sec-Fetch-Site"] = "same-origin"
		request["Sec-Fetch-Mode"] = "navigate"
		request["Sec-Fetch-User"] = "?1"
		request["Sec-Fetch-Dest"] = "document"
		request["Referer"] = "https://www.boomerangbuyback.com.au/search.aspx"
		request["Accept-Language"] = "en-US,en;q=0.9"
		request["Cookie"] = cookie_value
		req_options = {
		use_ssl: uri.scheme == "https",
		}
		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		http.request(request)
		end
		response
	end

	def price_detail(condition, grades, id, cookie_value)
		uri = URI.parse("https://www.boomerangbuyback.com.au/product_pricing.aspx")
		request = Net::HTTP::Post.new(uri)
		request.content_type = "application/x-www-form-urlencoded; charset=UTF-8"
		request["Connection"] = "keep-alive"
		request["Sec-Ch-Ua"] = "\" Not;A Brand\";v=\"99\", \"Google Chrome\";v=\"91\", \"Chromium\";v=\"91\""
		request["Accept"] = "*/*"
		request["X-Requested-With"] = "XMLHttpRequest"
		request["Sec-Ch-Ua-Mobile"] = "?1"
		request["User-Agent"] = "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Mobile Safari/537.36"
		request["Origin"] = "https://www.boomerangbuyback.com.au"
		request["Sec-Fetch-Site"] = "same-origin"
		request["Sec-Fetch-Mode"] = "cors"
		request["Sec-Fetch-Dest"] = "empty"
		request["Referer"] = "https://www.boomerangbuyback.com.au/Mobile-Phones/Apple/Apple-iPhone-8-64GB"
		request["Accept-Language"] = "en-US,en;q=0.9"
		request["Cookie"] = cookie_value
		request.set_form_data(
		"Add" => "false",
		"Condition" => condition,
		"Grades" => grades,
		"ID" => id,
		)
		req_options = {
		use_ssl: uri.scheme == "https",
		}
		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		http.request(request)
		end
		response
	end

	def scraper
		Buyback.where(retailers: 'boomerangbuyback').update_all('is_visited': false)
    response = main_request()
    data = Nokogiri::HTML(response.body)
    cookie_value = response.response['set-cookie']
    response = select_mobile_category(cookie_value)
    data = Nokogiri::HTML(response.body)
    all_mobiles = data.text.gsub("^", "").split(",")
    all_mobiles.each do |mobile|
    response = select_mobile(mobile, cookie_value)
    data = Nokogiri::HTML(response.body)
    next if data.text == "No products were found with your search criteria."
    all_links = data.css(".comp-now-product-radius").map{|e| e['href']}
    final_data = []
    all_links.each_with_index do |link, ind|
      response = mobile_details(link, cookie_value)
      mobile_data = Nokogiri::HTML(response.body)
      name = mobile_data.css('.comp-now-saechRH')[0].text.strip
      model = name.split
      if name.include? "GB" or name.include? "TB"
        storage = model.delete_at(-1)
        model.delete_at(0)
        model = model.join(" ")
      else
        model.delete_at(0)
        model = model.join(" ")
      end
      id = mobile_data.css("#product_id")[0]['value']
      3.times do |ind|
        combination_hash = {}
        combination_array = []
        combination_hash[:power_on] = false
        combination_hash[:fully_functional] = false
        data_hash = {}
        option_text = nil
        if ind == 0
          combination_hash[:power_on] = true
          combination_hash[:fully_functional] = true
          option_text = mobile_data.css(".WorkingGrade")[0].next.text
          grades = mobile_data.css(".WorkingGrade")[0]['value']
          condition = "Working"
          response = price_detail(condition, grades, id, cookie_value)
          price_data = Nokogiri::HTML(response.body)
          price = price_data.text.gsub("$", "")
        elsif ind == 1
          combination_hash[:power_on] = true
          combination_hash[:fully_functional] = true
          option_text = mobile_data.css(".WorkingGrade")[1].next.text
          grades = mobile_data.css(".WorkingGrade")[1]['value']
          condition = "Working"
          response = price_detail(condition, grades, id, cookie_value)
          price_data = Nokogiri::HTML(response.body)
          price = price_data.text.gsub("$", "")
        elsif ind == 2
          combination_hash[:power_on] = true
          combination_hash[:fully_functional] = false
          combination_hash[:condition] = 'broken'
          grades = mobile_data.css(".BrokenGrade")[0]['value']
          condition = "Broken"
          response = price_detail(condition, grades, id, cookie_value)
          price_data = Nokogiri::HTML(response.body)
          price = price_data.text.gsub("$", "")
        end
        price = "0" if price == "Recycle Only"
        if option_text == "Poor"
          combination_hash[:condition] = 'poor'
        elsif option_text == "Good"
          combination_hash[:condition] = 'good'
        end
        combination_array << combination_hash
        data_hash[:retailers] = "boomerangbuyback"
        data_hash[:make] = mobile
        data_hash[:model] = model
        data_hash[:storage] = storage
        data_hash[:color] = nil
        data_hash[:gradeArray] = combination_array
        data_hash[:gradeDetails] = nil
        data_hash[:price] = price
        data_hash[:discountedprice] = nil
        data_hash[:discountedPercentage] = nil
        data_hash[:currency] = "AUD"
        data_hash[:features] = nil
        data_hash[:link] = "https://www.boomerangbuyback.com.au/#{link}"
        data_hash[:is_visited] = true
        data_hash[:is_deleted] = false
        search_hash={}
        search_hash[:model] = data_hash[:model]
        search_hash[:storage] = data_hash[:storage]
        search_hash[:gradeArray] = data_hash[:gradeArray].to_s
        if Buyback.find_by(data_hash)
          puts 'hurrah.. already exist'
        elsif Buyback.where(retailers: "boomerangbuyback").find_by(search_hash)
			puts "Record Updated"
			searched_record = Buyback.where(retailers: "boomerangbuyback").find_by(search_hash)
			searched_record.update(data_hash)
        else
          data_hash[:lastseen]=Time.now
          Buyback.create(data_hash)
        end 
      end
    end
  end
  Buyback.where(is_visited: false, retailers: "boomerangbuyback" ).update_all(is_deleted: true)
 end
end
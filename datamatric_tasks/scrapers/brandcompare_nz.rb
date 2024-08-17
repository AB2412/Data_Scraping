require 'net/http'
require 'uri'
require 'nokogiri'

class BrandcompareNz

  def landing_page(retries = 10)
    begin
      uri = URI.parse("https://www.broadbandcompare.co.nz/")
    request = Net::HTTP::Get.new(uri)
    request["Authority"] = "www.broadbandcompare.co.nz"
    request["Cache-Control"] = "max-age=0"
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
    request["Accept-Language"] = "en-US,en-GB;q=0.9,en;q=0.8"

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    response
    rescue Exception => e
      puts "Exception is #{e}"
      if retries <= 1
        raise
      end
      landing_page(retries-1)
    end
  end

  def api_call(search_query ,retries = 10)
    begin
      uri = URI.parse("https://api.nzcompare.com/v2/addresses/list?q=#{search_query}")
      request = Net::HTTP::Get.new(uri)
      request["Authority"] = "api.nzcompare.com"
      request["Sec-Ch-Ua"] = "\" Not;A Brand\";v=\"99\", \"Google Chrome\";v=\"91\", \"Chromium\";v=\"91\""
      request["Accept"] = "text/plain, */*; q=0.01"
      request["Sec-Ch-Ua-Mobile"] = "?0"
      request["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.77 Safari/537.36"
      request["X-Api-Key"] = "eb45e46093b4384432b262a286cf751f898146a6"
      request["Origin"] = "https://consumer.broadbandcompare.co.nz"
      request["Sec-Fetch-Site"] = "cross-site"
      request["Sec-Fetch-Mode"] = "cors"
      request["Sec-Fetch-Dest"] = "empty"
      request["Referer"] = "https://consumer.broadbandcompare.co.nz/"
      request["Accept-Language"] = "en-US,en;q=0.9"
      req_options = {
        use_ssl: uri.scheme == "https",
      }
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      response
    rescue StandardError => e
      puts "Exception is #{e}"
      if retries <= 1
        raise
      end
      api_call(search_query, retries - 1)
    end
  end

  def data_request(cookie_value, id, search_query, page_number, flag, retries = 10)
    begin
      ignore_address = "&f%5Bignore_address_coverage%5D=1"

      uri = URI.parse("https://www.broadbandcompare.co.nz/plan/search/index?f%5Bsave_to_session%5D=1&f%5Btracking_enabled%5D=1#{ignore_address}&f%5Baddress%5D%5Bformatted%5D=#{search_query}&f%5Baddress%5D%5Bid%5D=#{id}&f%5Bsort%5D=rating&f%5Bprice_type%5D=per_month&page=#{page_number}&per-page=20")
      
      request = Net::HTTP::Get.new(uri)
      request["Authority"] = "www.broadbandcompare.co.nz"
      request["Sec-Ch-Ua"] = "\"Google Chrome\";v=\"95\", \"Chromium\";v=\"95\", \";Not A Brand\";v=\"99\""
      request["Accept"] = "application/json, text/plain, */*"
      request["X-Requested-With"] = "XMLHttpRequest"
      request["Sec-Ch-Ua-Mobile"] = "?0"
      request["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36"
      request["Sec-Ch-Ua-Platform"] = "\"Linux\""
      request["Sec-Fetch-Site"] = "same-origin"
      request["Sec-Fetch-Mode"] = "cors"
      request["Sec-Fetch-Dest"] = "empty"

      if flag == false
        request["Referer"] = "https://www.broadbandcompare.co.nz/compare?f%5Baddress%5D%5Bid%5D=#{id}&f%5Baddress%5D%5Bformatted%5D=#{search_query}"
      else
        request["Referer"] = "https://www.broadbandcompare.co.nz/compare?per-page=20&f%5Btracking_enabled%5D=1#{ignore_address}&f%5Baddress%5D%5Bformatted%5D=#{search_query}&f%5Baddress%5D%5Bid%5D=#{id}&f%5Bsort%5D=rating&f%5Bprice_type%5D=per_month&page=#{page_number-1}"
      end
      request["Accept-Language"] = "en-US,en;q=0.9"
      request["Cookie"] = cookie_value

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      response
    rescue StandardError => e
      puts "Exception is #{e}"
      if retries <= 1
        raise
      end
      data_request(cookie_value, page_number, flag,retries-1)
    end
  end

  def individual_request(cookie_value, url, retries = 10)
    begin
      uri = URI.parse("https://www.broadbandcompare.co.nz#{url}")
      request = Net::HTTP::Get.new(uri)
      request["Authority"] = "www.broadbandcompare.co.nz"
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
      request["Referer"] = "https://www.broadbandcompare.co.nz/compare?f%5Baddress%5D%5Bid%5D=A1002349068&f%5Baddress%5D%5Bformatted%5D=2+Arizona+Grove%2C+Brooklyn%2C+Wellington"
      request["Accept-Language"] = "en-US,en-GB;q=0.9,en;q=0.8"
      request["Cookie"] = cookie_value

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      response
    rescue StandardError => e
      puts "Exception is #{e}"
      if retries <= 1
        raise
      end
      individual_request(cookie_value, url, retries - 1)
    end
  end

  def get_values(plan, key, value)
    values = plan["#{key}"].select{|e| e["name"] == "#{value}"}
    if !values.empty?
      if values[0].keys.include? "price"
        value = values[0]["price"].gsub("\r\n",  ", ") rescue ""
      else
        value = values[0]["value"].gsub("\r\n",  ", ") rescue ""
      end
    else
      value = ""
    end
    return value
  end

  def udpate_nil_to_empty data_hash
    data_hash.each do |k,v|
      data_hash[k] = "" if v == nil
    end
    data_hash
  end

  def get_brand(array, element)
    sub_string = array.select{|s| element.upcase.include? s.upcase}
    sub_string_1 = array.select{|s| element.split.join.upcase.include? s.split.join.upcase}
    matched_elements = array.select{|s| s.split.join.upcase.include? element.split.join.upcase }
    matched_elements.count > 0 ? matched_elements.first : sub_string.count > 0 ? sub_string.first : sub_string_1.count > 0 ? sub_string_1.first : false
  end

  def get_values_using_td(pp, search_text)
    value = ""
    values = pp.css("td").select{|e| e.text.downcase == "#{search_text}".downcase}
    if !values.empty?
      if values[0].text.include? "Contract options"
        contract = values[0].next_element.text.split("/")
        return contract
      elsif values[0].text.include? "Download speed"
        full_speed = values[0].next_element.text.strip.gsub(",", "")
        down_speed = full_speed.split("/")[0].scan(/\d/).join.to_i
        up_speed = full_speed.split("/")[-1].scan(/\d/).join.to_i
        return [full_speed, down_speed, up_speed]
      else
        value = values[0].next_element.text.strip
        # if search_text == "Router"
        #   if values.count >= 2
        #     value = values.select{|e| !e.text.include? "BYO" and !e.text.include? "Router delivery fee"}[0].next_element.text.strip
        #   elsif values[0].text.upcase == "Router delivery fee".upcase
        #     value = ""
        #   end
        # elsif search_text.upcase == "Router delivery fee".upcase
        #   value = values[0].next_element.text.strip
        # else
        #   value = values[0].next_element.text.strip
        # end
      end
    else
      value = ""
    end
    return value
  end

  def process_pricing(pricing, ind)
    if pricing.split('/').count > 1
      price = pricing.split("/")[ind].gsub("$","").split.select{|e| e.to_i != 0} rescue "NULL"
      if price != "NULL"
        price = price.map(&:to_f).max
        price = price.to_i if price == price.to_i
        get_index = pricing.split("/")[ind].index "$#{price}"
        if get_index == 0
          detail = ""
        else
          detail = pricing.split("/")[ind][0..(get_index-1)].gsub('then', '').strip
        end
      end
    else
      ind = 0
      if pricing.split.count > 1 and pricing.split[0].include? "$"
        price = pricing.split("/")[ind].gsub("$","").split.select{|e| e.to_i != 0} rescue "NULL"
        price = price.map(&:to_f).max
        price = price.to_i if price == price.to_i
        get_index = pricing.split("/")[ind].index "$#{price}"
        if get_index == 0
          detail = ""
        else
          detail = pricing.split("/")[ind][0..(get_index-1)].gsub('then', '').strip
        end
      else
        price = pricing.split("/")[0].strip
        price = price.to_s.gsub("$","").to_f
        detail = ""
      end
    end
    
    if price.to_i == 0
      price = pricing.split("/")[ind] ? nil? : pricing.split("/").last.gsub("$","")
      detail = ""
    end

    price = price.to_i if price == price.to_i

    [price, detail]
  end


  def main
    current_date = Date.today
    current_date_runs = NzInternetStat.where(run_date: current_date)

    return if current_date_runs.count > 0 && current_date_runs[-1][:is_completed] == true

    if current_date_runs.count > 0
      run_object = current_date_runs[-1]
    else
      run_object = NzInternetStat.create(run_date: current_date)
    end

    main_page_response = landing_page()
    page = Nokogiri::HTML(main_page_response.body)
    cookie_value = main_page_response.response['set-cookie']
    search_query = "2 Arizona Grove, Brooklyn, Wellington".gsub(" ","%20").gsub(",","%2C")
    # search_query = "125 New York Street, Martinborough".gsub(" ","%20").gsub(",","%2C")
    response = api_call(search_query)
    re = JSON.parse(response.body)
    id = re['suggestions'][0]['aid']
    flag = false
    page_number = 1

    all_brands = ["Vodafone", "Spark", "2degrees", "Sky", "Skinny", "2Talk", "Altra Internet", "Amuri.net", "Bigpipe", "Bluedoor", "Connecta", "Contact", "Countrynet", "CyberPark", "Digital Cloud", "Econofibre", "EOL", "Evolution networks", "EzyKonect", "farmside", "Freedom", "full flavour", "Get Wireless", "Gisborne Net", "Go2", "Gravity", "Greenfields", "Gulf Internet", "Hotshot", "IcoNZ", "Inspire", "Jupiter Tech", "Kiwi IT Internet", "Kiwi VOIP", "Kiwi wifi", "Lightwire Rural", "Megatel", "mynxnet", "My Republic", "NetSpeed", "Nova Energy", "Now", "Primo", "Pulse energy", "Rural Wireless" ,"Satlan Corporation", "Scorch communications", "Sinch", "Slingshot" ,"Speedster", "Strata Networks", "Stuff Fibre" , "The Packing Shed", "The Pacific Net", "Trust power", "TVC", "UBB", "Uber", "Unicom", "Unifone", "Velocity Net" ,"Vetta online", "Voyager", "Warner Telecom", "Wasp broadband", "WheroNet", "Wicked networks", "Wifi Connect", "Wireless Dynamics", "Wireless nation", "Wireless web","wizwireless", "WorldNet","WXC communications", "Yrless+","Zelan Wireless", "Kogan Mobile", "Warehouse Mobile", "Flip"]

    excluded_providers = ["Vodafone", "Spark", "2degrees", "Sky", "Skinny"]
    data_response = data_request(cookie_value, id, search_query, page_number, flag)
    data = JSON.parse(data_response.body)
    total_pages = data['meta']['page_count']
    total_count = data['meta']['total_count']
    country_id = Country.find_by(name: 'New Zealand')['id']
    InternetPlan.where(airtable_id: "").update_all('is_visited': false)
    
    puts "Total Pages are --> #{total_pages}"
    puts "Total Number of Entries are --> #{total_count}"
    
    while page_number <= total_pages
      puts "Current Page #{page_number}"

      flag = true
      all_plans = data['data']['plans']

      all_plans.each_with_index do |plan, index|
        url = plan['url']

        puts "Processing Url --> https://consumer.broadbandcompare.co.nz#{url}"

        response = individual_request(cookie_value, url)
        pp = Nokogiri::HTML(response.body)

        available_contracts = get_values_using_td(pp, "Contract options")

        available_contracts.each_with_index do |contract, contract_index|
          providers_data_hash = {}
          plans_data_hash = {}
          search_data_hash = {}
        
          plans_data_hash[:name] = pp.css("h1").text.strip
          plans_data_hash[:name] = "#{plans_data_hash[:name]} (#{contract.strip})" if available_contracts.count > 1

          plans_data_hash[:electricity] = ""
          plans_data_hash[:gas] = ""
          plans_data_hash[:bundled_electricity] = ""
          plans_data_hash[:bundled_gas] = ""
          plans_data_hash[:data_details] = ""
          plans_data_hash[:additional_urls] = ""

          provider_name = get_values_using_td(pp,"Provider").split("\n")[0]

          # next if excluded_providers.include? provider_name

          provider_name_check = all_brands.select{|e| e.upcase.include? provider_name.upcase}
          if !provider_name_check.empty?
            providers_data_hash[:name] = provider_name_check[0]
          elsif get_brand(all_brands, provider_name)
            providers_data_hash[:name] = get_brand(all_brands, provider_name)
          elsif provider_name.upcase.include? "Stratanet".upcase
            providers_data_hash[:name] = "Strata Networks"
          elsif provider_name.upcase.include? "The Virus Centre".upcase
            providers_data_hash[:name] = "TVC"
          elsif provider_name.upcase.include? "Amurinet".upcase
            providers_data_hash[:name] = "Amuri.net"
          elsif provider_name.upcase.include? "Kiwi Internet It".upcase
            providers_data_hash[:name] = "Kiwi IT Internet"
          elsif provider_name.upcase.include? "Full Flavor".upcase
            providers_data_hash[:name] = "Full Flavour"
          elsif provider_name.upcase.include? "Wxc Worldxchange".upcase
            providers_data_hash[:name] = "WXC communications"
          else
            providers_data_hash[:name] = provider_name
          end

        if excluded_providers.include? provider_name.split[0]
          provider_name = provider_name.split[0] + "_direct"
          providers_data_hash[:name] = provider_name
        end

          providers_data_hash[:country_id] = country_id
          plans_data_hash[:contract] = contract.strip

          if plans_data_hash[:contract] && (plans_data_hash[:contract].downcase.include? "open term")
            plans_data_hash[:contract] = "No Contract"
            plans_data_hash[:contract_duration] = ""
          else
            plans_data_hash[:contract] = "Contract"
            plans_data_hash[:contract_duration] = contract.strip
          end

          if pp.css("div.b-heading.b-heading_plan-page_3").count == 4
            promotion_title = pp.css("div.b-heading.b-heading_plan-page_3")[1].text.strip
            promotion_details = pp.css("div.b-heading.b-heading_plan-page_3")[1].next_element.text.strip
            plans_data_hash[:promotions] = "#{promotion_title}\n#{promotion_details}"
          else
            plans_data_hash[:promotions] = ""
          end

          if plans_data_hash[:promotions].include? 'On-peak runs from '
            promotion_value = plans_data_hash[:promotions]
            peak_start_index = promotion_value.index('On-peak runs from ')
            promotion_value = promotion_value[peak_start_index+18..-1]
            peak_end_index = promotion_value.index('(')
            promotion_value = promotion_value[0...peak_end_index].strip
            plans_data_hash[:peak_data_times] = promotion_value
          end

          if plans_data_hash[:promotions].include? 'off-peak runs from '
            promotion_value = plans_data_hash[:promotions]
            peak_start_index = promotion_value.index('off-peak runs from ')
            promotion_value = promotion_value[peak_start_index+19..-1]
            peak_end_index = promotion_value.index('(')
            promotion_value = promotion_value[0...peak_end_index].strip
            plans_data_hash[:off_peak_data_times] = promotion_value
          end

          if plans_data_hash[:promotions].include? 'Free Off Peak Data is from '
            promotion_value = plans_data_hash[:promotions]
            peak_start_index = promotion_value.index('Free Off Peak Data is from ')
            promotion_value = promotion_value[peak_start_index+27..-1]
            peak_end_index = promotion_value.index('.')
            promotion_value = promotion_value[0...peak_end_index].strip
            plans_data_hash[:off_peak_data_times] = promotion_value
          end

          if plans_data_hash[:promotions].include? 'Off Peak is '
            promotion_value = plans_data_hash[:promotions]
            peak_start_index = promotion_value.index('Off Peak is ')
            promotion_value = promotion_value[peak_start_index+12..-1]
            peak_end_index = promotion_value.index('.')
            promotion_value = promotion_value[0...peak_end_index].strip
            plans_data_hash[:off_peak_data_times] = promotion_value
          end

          if plans_data_hash[:promotions].include? "welcome credit"
            welcome_credit = plans_data_hash[:promotions].match(/[.\d]+/)[0].to_f
            welcome_credit_contract = plans_data_hash[:promotions].split("term")[0].strip.split[-1].gsub('-', ' ')
            if contract.include? welcome_credit_contract
              plans_data_hash[:discounted_price] = plans_data_hash[:price].to_f - welcome_credit
              plans_data_hash[:discounted_price] = '$0' if plans_data_hash[:discounted_price] < 0
            else
              plans_data_hash[:discounted_price] = ""
            end
          end

          plans_data_hash[:is_on_promotion] = plans_data_hash[:promotions] != "" ? "Yes" : "No"

          if (plans_data_hash[:promotions] != "") && (plans_data_hash[:promotions].include? 'Peak data')
            plans_data_hash[:data_details] = plans_data_hash[:promotions]
          end

          plans_data_hash[:data_limit] = get_values_using_td(pp, "Data")

          plans_data_hash[:connection_type] = get_values_using_td(pp, "Type")
          plans_data_hash[:connection_type] = 'Satellite' if plans_data_hash[:connection_type] == "Other"
          
          connection_type_parent = plans_data_hash[:connection_type]
          if (plans_data_hash[:connection_type].include? '3G') || (plans_data_hash[:connection_type].include? '4G') || (plans_data_hash[:connection_type].include? '5G')
            plans_data_hash[:connection_technology] = plans_data_hash[:connection_type].split('-').last
            plans_data_hash[:connection_type] = ""
          end

          if plans_data_hash[:connection_technology]
            if (plans_data_hash[:connection_technology].include? '3G') || (plans_data_hash[:connection_technology].include? '4G') || (plans_data_hash[:connection_technology].include? '5G')
              plans_data_hash[:connection_type] = "Mobile broadband"
            end
          end

          if (connection_type_parent.include? 'RBI') || (plans_data_hash[:name].include? 'RBI')
            plans_data_hash[:connection_type] = 'RBI'
          end

          if plans_data_hash[:connection_type] == ""
            plans_data_hash[:connection_type] = "Wireless" if plans_data_hash[:name].downcase.include? 'wireless'
            plans_data_hash[:connection_type] = "Satellite" if plans_data_hash[:name].downcase.include? 'satellite'
            plans_data_hash[:connection_type] = "VDSL" if plans_data_hash[:name].downcase.include? 'vdsl'
            plans_data_hash[:connection_type] = "Fibre" if plans_data_hash[:name].downcase.include? 'fibre'
            plans_data_hash[:connection_type] = "ADSL" if plans_data_hash[:name].downcase.include? 'adsl'
            plans_data_hash[:connection_type] = "RBI" if plans_data_hash[:name].downcase.include? 'rbi'
          end

          full_speed, down_speed, up_speed = get_values_using_td(pp, "Download speed")
          plans_data_hash[:speed] = full_speed.gsub(",", "")
          plans_data_hash[:speed_details] = plan["speed"]["down"]
          complete_price = get_values_using_td(pp, "Price")

          plans_data_hash[:price], plans_data_hash[:price_details] = process_pricing(complete_price, contract_index)

          if (plans_data_hash[:price_details] != "")
            if providers_data_hash[:name].downcase =='trust power'
              plans_data_hash[:discounted_price] = ""
              plans_data_hash[:discounted_period] = ""
            else
              plans_data_hash[:discounted_price] = plans_data_hash[:price_details].scan(/(\$[\d]+\.\d+)|(\$[\d]*)/).flatten.reject{|s| s == nil }[0]
              plans_data_hash[:discounted_period] = plans_data_hash[:price_details].gsub(plans_data_hash[:discounted_price], '').strip
            end
          end

          if plans_data_hash[:promotions].include? "welcome credit"
            welcome_credit = plans_data_hash[:promotions].match(/[.\d]+/)[0].to_f
            plans_data_hash[:discounted_price] = plans_data_hash[:price].to_f - welcome_credit
          end


          plans_data_hash[:recharge_period] = 'per month'
          
          plans_data_hash[:mobile] = get_values_using_td(pp, "Mobile")

          if plans_data_hash[:mobile] != ""
            if plans_data_hash[:mobile].downcase == "free" || plans_data_hash[:mobile].downcase == "available"
              plans_data_hash[:bundled_mobile] = "Included"
            else
              plans_data_hash[:bundled_mobile] = "AddOn"
            end
          end

          plans_data_hash[:landline] = get_values_using_td(pp, "Homeline")

          if plans_data_hash[:landline] != ""
            if plans_data_hash[:landline] == "free" || plans_data_hash[:landline] == "available"
              plans_data_hash[:bundled_landline] = "Included"
            else
              plans_data_hash[:bundled_landline] = "AddOn"
            end
          end

          plans_data_hash[:download] = plan["speed"]["down"].gsub(",", "")
          plans_data_hash[:upload] = plan["speed"]["up"].gsub(",", "")


          static_ip = get_values_using_td(pp, "Static IP")

          static_ip_array = static_ip.split(' / ')

          plans_data_hash[:static_ip] = static_ip_array[contract_index].strip rescue static_ip_array.last

          plans_data_hash[:modem_fee] =  ""
          plans_data_hash[:modem_postage] = ""
          plans_data_hash[:rental_router] = ""
          plans_data_hash[:termination_fee] = ""
          plans_data_hash[:installation_cost] = ""

          if get_values_using_td(pp, "Router") != ''
            modem_fee = get_values_using_td(pp, "Router")
            modem_fee_array = modem_fee.split(" / ")#.reject{|s| s == "mo"}
            plans_data_hash[:modem_fee] = modem_fee_array[contract_index].strip rescue modem_fee_array.last
          end

          if get_values_using_td(pp, "Rental router") != ''
            rental_router = get_values_using_td(pp, "Rental router")
            rental_router_array = rental_router.split(" / ")
            plans_data_hash[:rental_router] = rental_router_array[contract_index].strip rescue rental_router_array.last
          end

          if plans_data_hash[:modem_fee].include? '/mo'
            plans_data_hash[:rental_router] = plans_data_hash[:modem_fee]
            plans_data_hash[:modem_fee] = ""
          end

          modem_postage = get_values_using_td(pp, "Router delivery fee")
          modem_postage_array = modem_postage.split(" / ")
          plans_data_hash[:modem_postage] = modem_postage_array[contract_index].strip rescue modem_postage_array.last

          byo_modem = get_values_using_td(pp, "BYO Router")
          plans_data_hash[:byo_modem] = byo_modem

          termination_fee = get_values_using_td(pp, "Termination fee")

          if (termination_fee.include? 'See T&Cs') && (plan["fees"][1]["complicated_etf_comment"] != nil)
            termination_fee = termination_fee.gsub('See T&Cs', plan["fees"][1]["complicated_etf_comment"]) 
          end

          termination_fee_array = termination_fee.split(' / ')#.reject{|s| s == "mo"}

          plans_data_hash[:termination_fee] = termination_fee_array[contract_index].strip rescue termination_fee_array.last
          plans_data_hash[:termination_fee] = "" if plans_data_hash[:termination_fee] == "1"

          installation_cost = get_values_using_td(pp, "Connection fee")
          if installation_cost.present?
            installation_cost_array = installation_cost.split(' / ')#.reject{|s| s == "mo"}
            plans_data_hash[:installation_cost] = installation_cost_array[contract_index].strip rescue installation_cost_array.last
          end

          if pp.css(".b-heading.b-heading_plan-page_3").select{|e| e.text.include? "Available features"}.count != 0
            val = pp.css(".b-heading.b-heading_plan-page_3").select{|e| e.text.include? "Available features"}[0]
            get_index = pp.css(".b-heading.b-heading_plan-page_3").index val
            all_values = pp.css(".b-heading.b-heading_plan-page_3")[get_index].next_element.css("table").map{|e| e.css("tr td")}.flatten.map(&:text)
            features_array = []

            all_values.each_with_index do |value, index|
              next if index % 2 != 0
              feature_value = all_values[index+1].gsub("†" , "")
              feature_value_array = feature_value.split(' / ')
              feature_old_value = (all_values[index].gsub("†" , "") + " " + feature_value_array.last)

              features_array << (all_values[index].gsub("†" , "") + " " + feature_value_array[contract_index].strip rescue feature_old_value)
            end
            plans_data_hash[:features] = features_array.join("\n")
          else
            plans_data_hash[:features] = ""
          end

          if features_array
            plans_data_hash[:internet_security] = features_array.select{|s| (s.include? 'Family filter') || (s.include? 'security')}.join("\n")

            if features_array.select{|s| s.start_with? 'Power'}.count > 0
              plans_data_hash[:electricity] = features_array.select{|s| s.start_with? 'Power'}.join("\n")
              plans_data_hash[:bundled_electricity] = "AddOn"
            end

            if features_array.select{|s| s.start_with? 'Gas '}.count > 0
              plans_data_hash[:gas] = features_array.select{|s| s.start_with? 'Gas '}.join("\n")
              plans_data_hash[:bundled_gas] = "AddOn"
            end
          end

          plans_data_hash[:source_url] = "https://consumer.broadbandcompare.co.nz#{plan['url']}"
          plans_data_hash[:is_visited] = true
          plans_data_hash[:is_deleted] = false

          provider = Provider.find_or_create_by(providers_data_hash)
          provider_id  = provider[:id]
          plans_data_hash[:provider_id] = provider_id

          search_data_hash[:provider_id] = plans_data_hash[:provider_id]
          search_data_hash[:contract] = plans_data_hash[:contract]
          search_data_hash[:name] = plans_data_hash[:name]
          search_data_hash[:source_url] = plans_data_hash[:source_url]
       
          plans_data_hash = udpate_nil_to_empty(plans_data_hash)

          if InternetPlan.find_by(plans_data_hash)
            puts 'hurrah.. already exist'
          elsif InternetPlan.find_by(search_data_hash)
            puts  'Record Updated!'
            searched_record = InternetPlan.find_by(search_data_hash)
            searched_record.update(plans_data_hash)
          else
            InternetPlan.create(plans_data_hash)
          end
        end
      end
      page_number += 1
      puts "------------------------------------------------------"
      puts "---------- Page Number --> #{page_number} ------------"
      puts "------------------------------------------------------"
      data_response = data_request(cookie_value, id, search_query, page_number, flag)
      data = JSON.parse(data_response.body)
    end
    InternetPlan.where(airtable_id: "", is_visited: false).update_all(is_deleted: true)
    run_object.update(is_completed: true)
  end
end

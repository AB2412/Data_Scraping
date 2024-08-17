require 'net/http'
require 'nokogiri'
require 'json'
require 'selenium-webdriver'
# require 'webdrivers'

class FinderMobile_old

  def record_view_details(product, table_id, niche, site, origin, placement_type, field_set, template, category_id, category_name, retries = 3)
    begin
      uri = URI.parse("https://www.finder.com.au/wordpress/wp-admin/admin-ajax.php")
      request = Net::HTTP::Post.new(uri)
      request.content_type = "application/x-www-form-urlencoded; charset=UTF-8"
      request["Authority"] = "www.finder.com.au"
      request["Sec-Ch-Ua"] = "\"Chromium\";v=\"92\", \" Not A;Brand\";v=\"99\", \"Google Chrome\";v=\"92\""
      request["Accept"] = "*/*"
      request["Dnt"] = "1"
      request["X-Requested-With"] = "XMLHttpRequest"
      request["Sec-Ch-Ua-Mobile"] = "?0"
      request["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.107 Safari/537.36"
      request["Origin"] = "https://www.finder.com.au"
      request["Sec-Fetch-Site"] = "same-origin"
      request["Sec-Fetch-Mode"] = "cors"
      request["Sec-Fetch-Dest"] = "empty"
      request["Referer"] = "https://www.finder.com.au/mobile-plans"
      request["Accept-Language"] = "en-US,en;q=0.9"
      # request["Cookie"] = ""
      request.set_form_data(
        "action" => "get_expander_ajax",
        "id" => product,
        "niche" => niche,
        "origin" => origin,
        "redirectTrackingParams[category_id]" => category_id,
        "redirectTrackingParams[category_name]" => category_name,
        "redirectTrackingParams[fieldset]" => field_set,
        "redirectTrackingParams[placement_type]" => placement_type,
        "redirectTrackingParams[template]" => template,
        "site" => site,
        "tableId" => table_id,
        )

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      response
    rescue StandardError => e
      puts "#{e}"
      if retries <= 1
        raise
      end
      record_view_details(product ,table_id, niche, site, origin, placement_type, field_set, template, category_id, category_name, retries - 1)
    end
  end


  def get_values(page, search_text)
    values = page.css('dt').select{|e| e.text.include? search_text}
    if !values.empty?
      value = values[0].next_element.text.strip
      value = values[0].next_element.css('a')[0]['href'] if search_text == "CIS link"
    else
      value = ''
    end
    value
  end

  def clean_plan_name(plan_name, provider_complete_name, provider_matched_name)
    if plan_name.downcase.start_with? "#{provider_complete_name.downcase} mobile"
      provider_length = "#{provider_complete_name.downcase} mobile".split(' ').length
      plan_name = plan_name.split(' ')[provider_length..-1].join(' ')
    elsif plan_name.downcase.start_with? "#{provider_matched_name.downcase} mobile"
      provider_length = "#{provider_matched_name.downcase} mobile".split(' ').length
      plan_name = plan_name.split(' ')[provider_length..-1].join(' ')
    elsif plan_name.downcase.start_with? provider_complete_name.downcase
      provider_length = provider_complete_name.split(' ').length
      plan_name = plan_name.split(' ')[provider_length..-1].join(' ')
    elsif plan_name.downcase.start_with? provider_matched_name.downcase
      provider_length = provider_matched_name.split(' ').length
      plan_name = plan_name.split(' ')[provider_length..-1].join(' ')
    elsif plan_name.split(' ')[0].downcase.include? provider_matched_name.split(' ')[0].downcase 
      plan_name = plan_name.split(' ')[1..-1].join(' ')
    else
      plan_name
    end

    if plan_name.start_with? '-'
      plan_name = plan_name[1..-1]
    end
    plan_name.strip
  end

  def udpate_nil_to_empty data_hash
    data_hash.each do |k,v|
      data_hash[k] = "" if v == nil
    end
    data_hash
  end

  def data_processing(hash_array, page, available_plans, index, driver, excluded_providers, country_id, all_brands, usage_type)
    data_hash = {}
    providers_data_hash = {}
    # info
    data_hash["plan_name"] = get_values(page, "Plan name")

    provider_name = get_values(page, "Provider name")

    return hash_array if excluded_providers.select{|s| provider_name.include? s}.count > 0

    provider_name_check = all_brands.select{|e| e.upcase.include? provider_name.upcase}
    if !provider_name_check.empty?
      providers_data_hash[:name] = provider_name_check[0]
    elsif get_brand(all_brands, provider_name)
      providers_data_hash[:name] = get_brand(all_brands, provider_name)
    else
      providers_data_hash[:name] = provider_name
    end

    providers_data_hash[:name] = "Mate" if providers_data_hash[:name] == '10Mates'

    data_hash["plan_name"]  = clean_plan_name(data_hash["plan_name"], provider_name, providers_data_hash[:name]).strip

    if data_hash['plan_name'].split.select{|e| e == 'Ulti'}.count > 0
      data_hash['plan_name'] = data_hash['plan_name'].gsub('Ulti', 'Ultimate')
    end

    data_hash['plan_name'] = "$#{data_hash['plan_name']}" if providers_data_hash[:name] == 'Moose Mobile'

    providers_data_hash[:country_id] = country_id
    provider = Provider.find_or_create_by(providers_data_hash)
    provider_id  = provider[:id]
    data_hash["provider_id"] = provider_id
    data_hash["usage_type"] = usage_type
    contract_value = 'Contract'
    data_hash["contract_duration"] = get_values(page, "Plan length")
    data_hash["contract_duration_original_value"] = data_hash["contract_duration"]

    if data_hash['contract_duration'] == '1 month'
      contract_value = 'No Contract'
    else
      if data_hash['contract_duration'].downcase.include? 'day'
        contract_value = data_hash['contract_duration'].scan(/\d/).join.to_i <= 30 ? "No Contract" : "Contract"
      end
    end
    data_hash['contract_duration'] = contract_value == 'Contract' ? data_hash['contract_duration'] : ""

    data_hash["plan_type"] = get_values(page, "Plan type")
    data_hash["cost_per_GB"] = get_values(page, "Cost per GB")

    data_hash["price"] = driver.find_element(css: 'form[name="compareForm"]').find_elements(css: 'tbody tr')[index].find_elements(css: '.priceText')[-1].text
    if data_hash['price'].include? '/'
      data_hash['price'] = data_hash['price'].split('/')[0].strip
    end
    details_text_price = driver.find_element(css: 'form[name="compareForm"]').find_elements(css: 'tbody tr')[index].find_element(css: 'div[data-heading="Price"]').find_element(css: "div[class='priceText']").text
    details_text_price_text = driver.find_element(css: 'form[name="compareForm"]').find_elements(css: 'tbody tr')[index].find_element(css: 'div[data-heading="Price"]').find_element(css: "div[class='dataSubText']").text
    data_hash["price_details"] = (details_text_price + " " + details_text_price_text).gsub('View details','').split("\n").join(' ')
    # data_hash["price_details"] = driver.find('form[name="compareForm"]').find_all('tbody tr')[index].find('div[data-heading="Price"]').find("div[class='priceText']").text#.text.split("\nGo to site")[0]
    data_hash["national_calls"] = get_values(page, "Included standard national calls")
    data_hash["national_texts"] = get_values(page, "Included standard national texts")
    # Data
    data_hash["data_limit"] = get_values(page, "Included data")
    data_hash["data_features"] = get_values(page, "Data description")
    data_hash["data_rollover"] = get_values(page, "Data rollover")
    data_hash["data_sharing"] = get_values(page, "Data sharing")
    data_hash["extra_data"] = get_values(page, "Data description")


    if data_hash["extra_data"].present? && (data_hash["extra_data"].downcase.include? 'extra data')
      data_hash["extra_data"] = data_hash["extra_data"].split().select{|e| e.include? "/"}[0].gsub(',','') rescue data_hash["extra_data"]
    else
      if data_hash['extra_data'].include? 'c/MB'
        data_hash['extra_data'] = data_hash['extra_data'].split.select{|e| e.include? 'c/MB'}[0].strip
      else
        if data_hash['extra_data'].include? '$'
          data_hash['extra_data'] = data_hash['extra_data'].split.select{|e| e.include? '$'}[0]
        else
          data_hash["extra_data"] = ""
        end
      end
    end

    # international
    data_hash["international_summary"] = get_values(page, "Summary")
    data_hash["international_calls"] = get_values(page, "International calls")
    data_hash["international_texts"] = get_values(page, "International texts")
    data_hash["international_countries"] = get_values(page, "Selected countries")

    # Terms + conditions
    data_hash["terms_conditions"] = get_values(page, "Terms & conditions")
    data_hash["cis_link"] = get_values(page, "CIS link")


    # from main name section area
    # data_hash["contract_period"] = available_plans[index].css('td.comparison-table__product').css("div.categoryItem")[0].text.strip
    network_details = available_plans[index].css('td.comparison-table__product').css("div.categoryItem")[-1].text.strip
    data_hash["operator"] = network_details.split(' ')[0]
    data_hash["connection_type"] = network_details.gsub('network','').strip.split(' ').last

    # features
    # data_hash["features"] = available_plans[index].css('td.comparison-table__feature.sorter-false').css('li').map{|e| e.text.strip.gsub('\t','')}.join("\n")
    data_hash["features"] = available_plans[index].css('td.comparison-table__feature.sorter-false').css('li').select{|e| !e['class'].include? 'offerIcon'}.map{|e| e.text.strip.gsub('\t','')}.join("\n")

    if data_hash['features'].split("\n").select{|e| e.include? 'international'}.count > 0
      data_hash['international_summary'] = data_hash["features"].split("\n").select{|e| e.include? 'international'}.join("\n") unless data_hash['international_summary']
      data_hash['international_calls'] = data_hash["features"].split("\n").select{|e| e.include? 'international' and ((e.include? 'calls') || (e.include? 'mins'))}.join("\n") unless data_hash['international_calls']
      data_hash['international_texts'] = data_hash["features"].split("\n").select{|e| e.include? 'international' and e.include? 'text'}.join("\n") unless data_hash['international_texts']
      data_hash['international_countries'] = data_hash["features"].split("\n").select{|e| e.include? 'international' and e.include? 'countries'}.join("\n") unless data_hash['international_countries']

      data_hash['features'] = data_hash["features"].split("\n").reject{|e| e.include? 'international'}.join("\n")
      data_hash['features'] = data_hash["features"].split("\n").reject{|e| (e.include? 'international') && ((e.include? 'calls') || (e.include? 'mins')) }.join("\n")
      data_hash['features'] = data_hash["features"].split("\n").reject{|e| e.include? 'international' and e.include? 'text'}.join("\n")
      data_hash['features'] = data_hash["features"].split("\n").reject{|e| e.include? 'international' and e.include? 'countries'}.join("\n")

    elsif data_hash['features'].split("\n").select{|e| e.include? 'any country'}.count > 0
      data_hash['international_summary'] = data_hash["features"].split("\n").select{|e| e.include? 'any country'}.join("\n") unless data_hash['international_summary']
      data_hash['international_calls'] = data_hash["features"].split("\n").select{|e| e.include? 'any country' and ((e.include? 'calls') || (e.include? 'mins'))}.join("\n") unless data_hash['international_calls']
      data_hash['international_texts'] = data_hash["features"].split("\n").select{|e| e.include? 'any country' and e.include? 'text'}.join("\n") unless data_hash['international_texts']
      data_hash['international_countries'] = data_hash["features"].split("\n").select{|e| e.include? 'any country'}.join("\n") unless data_hash['international_countries']

      data_hash['features'] = data_hash["features"].split("\n").reject{|e| e.include? 'any country'}.join("\n")
      data_hash['features'] = data_hash["features"].split("\n").reject{|e| e.include? 'any country' and ((e.include? 'calls') || (e.include? 'mins'))}.join("\n")
      data_hash['features'] = data_hash["features"].split("\n").reject{|e| e.include? 'any country' and e.include? 'text'}.join("\n")
      data_hash['features'] = data_hash["features"].split("\n").reject{|e| e.include? 'any country'}.join("\n")
    end
#NEW entertainment_%
      data_hash['entertainment_sport'] = data_hash["features"].split("\n").select{|e| e.include? 'sport'}.join("\n") unless data_hash['entertainment_sport']
      data_hash['entertainment_gaming'] = data_hash["features"].split("\n").select{|e| (e.downcase.include? 'gaming') || (e.downcase.include? 'game') }.join("\n")
      data_hash['entertainment_music'] = data_hash["features"].split("\n").select{|e| (e.downcase.include? 'spotify') || (e.downcase.include? 'music') }.join("\n")
      data_hash['entertainment_streaming'] = data_hash["features"].split("\n").select{|e| (e.include? 'Disney') || (e.include? 'Foxtel') }.join("\n")

      if data_hash['entertainment_sport'] != '' or data_hash['entertainment_gaming'] != '' or data_hash['entertainment_music'] != '' or  data_hash['entertainment_streaming'] != ''
          data_hash['bundled_entertainment'] = 'AddOn'
      end
    data_hash["promotions"] = available_plans[index].css('td.comparison-table__feature.sorter-false').css('li span.offerText').text.strip rescue ''
    # data_hash["is_on_promotion"] = data_hash["promotions"] == "" ? "No" : "Y"

    data_hash["recharge_period"] = available_plans[index].css('div[data-heading="Price"] div[class="dataSubText"]').text.squeeze.strip


    if data_hash['price_details'].include? '/mth'
      data_hash['recharge_period'] = 'one month'
    end

    data_hash["is_on_promotion"] = data_hash["promotions"] == "" ? "No" : "Yes"


    data_hash["discounted_price"] = ''
    if data_hash["is_on_promotion"] == "Yes"
      if (data_hash['promotions'].upcase.include? 'month free'.upcase) || (data_hash['promotions'].upcase.include? 'months free'.upcase)
        data_hash["discounted_price"] = "$0"
#NEW discounted_period
        data_hash['discounted_period'] = data_hash['promotions'].split('free')[0].gsub('Get', '').gsub('the', '').strip
      elsif data_hash['promotions'].include? 'for the'
        data_hash['discounted_period'] = data_hash['promotions'].split('for the')[1].split(',')[0].split('.')[0].strip
      elsif data_hash['promotions'].include? 'month'
        data_hash['discounted_period'] = data_hash['promotions'].split('first')[1].split('. ')[0].strip rescue nil
      # elsif data_hash['promotions'].include? 'Get' and data_hash['promotions'].include? 'free'
        # data_hash['discounted_period'] =  data_hash['promotions'].split('free')[0].gsub('Get', '').strip
      end
#NEW data_promotion
      if data_hash['promotions'].include? 'bonus'
          data_hash['data_promotion'] = data_hash['promotions'].split('bonus')[0].gsub("+", '').gsub('included', '').gsub('standard', '').split[-1]
      elsif data_hash['promotions'].include? 'additional data'
          data_hash['data_promotion'] = data_hash['promotions'].split('additional data')[0].split[-1]
      elsif data_hash['data_features'].include? 'bonus'
          data_hash['data_promotion'] = data_hash['data_features'].split('bonus')[0].gsub("+", ' ').gsub('standard', '').gsub('included', '').split[1]

      elsif data_hash['promotions'].include? 'instead' and (data_hash['promotions'].include? "GB" or data_hash['promotions'].include? "TB" )
        data_hash['data_promotion'] = data_hash['promotions'].split('instead')[0].split.select{|e| e.include? "GB" or e.include? "TB"}
      end
#NEW data_promotion_period
      if !data_hash['promotions'].empty?
        if data_hash['promotions'].include? 'for'
          data_hash['data_promotion_period'] = data_hash['promotions'].split('for')[1].split('.')[0].strip
        elsif data_hash['promotions'].include? 'on the'
           data_hash['data_promotion_period'] = data_hash['promotions'].split('on the')[1].split('.')[0].strip
        elsif data_hash['promotions'].include? 'per'
            data_hash['data_promotion_period'] = data_hash['promotions'].split('per')[1].split('for')[0].strip
        elsif data_hash['promotions'].include? 'subscriptions'
            data_hash['data_promotion_period'] =  data_hash['promotions'].split('. ')[0].split(' on ')[1]

        end
      end
#<-->
      promotion_prices = data_hash['promotions'].scan(/(\$[\d]+\.\d+)|(\$[\d]*)/).flatten.reject{|s| s == nil }
      unless data_hash['promotions'].include? 'gift card'
        if promotion_prices.count == 2
          if promotion_prices[0].gsub('$', '').to_f < promotion_prices[1].gsub('$', '').to_f 
            data_hash['discounted_price'] = promotion_prices[0]
            data_hash['price'] = promotion_prices[1]
          else
            data_hash['discounted_price'] = promotion_prices[1]
            data_hash['price'] = promotion_prices[0]
          end
        elsif promotion_prices.count == 3 && (data_hash['promotions'].include? 'Save')
          data_hash["discounted_price"] = promotion_prices[-1]
          data_hash['price'] = promotion_prices[1]
        elsif promotion_prices.count == 1
          if data_hash['promotions'].include? '%'
            value = promotion_prices[0].gsub('$', '').to_f
            percentage = data_hash['promotions'].split.select{|e| e.include? '%'}[0].scan(/\d/).join.to_i
            evaluator = percentage/100.to_f * value
            data_hash['discounted_price'] = "$" + evaluator.to_s
            data_hash['price'] = promotion_prices[0]
          elsif data_hash['promotions'].include? 'credit'
            price = data_hash['price'].gsub('$','').to_f
            dollar_value = promotion_prices[0].gsub('$','').to_f
            data_hash['discounted_price'] = "$" + ((dollar_value - price).to_i).to_s
          elsif data_hash['promotions'].include? 'Online offer' and data_hash['promotions'].include? '$'
            data_hash['discounted_price'] = data_hash['promotions'].scan(/(\$[\d]+\.\d+)|(\$[\d]*)/).flatten.reject{|s| s == nil }[0]
          end
        end
      end
    end

    rollover_feature = data_hash["features"].split("\n").select{|s| s.include? 'Data banking'}
    if rollover_feature.count > 0
      data_hash['data_rollover'] = rollover_feature.first
    end

    sharing_feature = data_hash["features"].split("\n").select{|s| (s.downcase.include? 'data gifting') || (s.downcase.include? 'gifted')}

    if sharing_feature.count > 0
      data_hash['data_sharing'] = sharing_feature.first
    end
    data_hash["source_url"] = "https://www.finder.com.au/mobile-plans"
    data_hash["is_visited"] = true
    data_hash['is_deleted'] = false
    puts data_hash
    data_hash = udpate_nil_to_empty(data_hash)
    hash_array << data_hash
  end

  def db_insertion(hash_array)
    hash_array.each do |data_hash|
      record = AutraliaMobilePlan.find_by({plan_name: data_hash["plan_name"], provider_id: data_hash["provider_id"]})
      if record
        if record['contract_duration'] ==  data_hash['contract_duration']
          data_hash.except!("contract_duration_original_value")
          record.update(data_hash)
        else
          updated_plan = data_hash["plan_name"] + " (" + data_hash["contract_duration_original_value"] + ")"
          record_contract = AutraliaMobilePlan.find_by({plan_name: updated_plan, provider_id: data_hash["provider_id"]})

          data_hash["plan_name"] = updated_plan

          if record_contract
            data_hash.except!("contract_duration_original_value")
            record_contract.update(data_hash)
          else
            data_hash.except!("contract_duration_original_value")
            AutraliaMobilePlan.create(data_hash)
          end
        end
      else
        data_hash.except!("contract_duration_original_value")
        AutraliaMobilePlan.create(data_hash)
      end
    end
  end

  def get_brand(array, element)
    sub_string = array.select{|s| element.upcase.include? s.upcase}
    sub_string_1 = array.select{|s| element.split.join.upcase.include? s.split.join.upcase}
    matched_elements = array.select{|s| s.split.join.upcase.include? element.split.join.upcase }
    matched_elements.count > 0 ? matched_elements.first : sub_string.count > 0 ? sub_string.first : sub_string_1.count > 0 ? sub_string_1.first : false
  end

  def scrape_using_usage(page_num, total_pages, driver, pp, all_brands, excluded_providers, country_id, hash_array, usage_type)
    while page_num <= total_pages
      puts "Processing Page Number ---> #{page_num}\n"
      table_id = pp.css('form[name="compareForm"]')[0]['data-table-id']
      niche = pp.css('form[name="compareForm"]')[0]['data-niche']
      site = pp.css('form[name="compareForm"]')[0]['data-site']
      origin = pp.css('form[name="compareForm"]')[0]['data-origin']
      params = JSON.parse(pp.css('form[name="compareForm"]')[0]['data-redirect-tracking-params'])
      placement_type = params['placement_type']
      field_set = params['fieldset']
      template = params['template']
      category_id = params['category_id']
      category_name = params['category_name']
      available_plans = pp.css('form[name="compareForm"]').css('table tbody tr')
      product_ids = available_plans.map.with_index{|e, index| [index,e['data-product-id']]}
      puts "Total Number of Records are ---> #{product_ids.count}"

      mutex = Mutex.new
      1.times.map {
        Thread.new(product_ids) do |records|
          while product = mutex.synchronize { records.pop }
            index = product[0]
            product = product[-1]
            response = record_view_details(product, table_id, niche, site, origin, placement_type, field_set, template, category_id, category_name)
            sleep(0.5)
            page = Nokogiri::HTML(response.body)
            hash_array = data_processing(hash_array, page, available_plans, index, driver, excluded_providers, country_id, all_brands, usage_type)

          end
        end
      }.each(&:join)
      db_insertion(hash_array)
      hash_array = []
      page_num += 1
      driver.find_elements(css: 'button').select{|e| e.text.strip == 'Next'}[0].click
      sleep(5)
      pp = Nokogiri::HTML(driver.page_source)
    end
    return hash_array
  end
  
  def business_selection(driver)
    while true
      if driver.find_elements(css: "input").select{|e| e['value'] == 'Personal'}[0]['checked'] == "true"
        driver.find_elements(css: "label").select{|e| e.text == 'Business'}[0].click()
        sleep(4)
      else
        break
      end
    end
    return driver
  end

  def scraper

    current_date = Date.today
    current_date_runs = AustraliaMobileStat.where(run_date: current_date)

     return if current_date_runs.count > 0 && current_date_runs[-1][:is_completed] == true

    if current_date_runs.count > 0
      run_object = current_date_runs[-1]
    else
      run_object = AustraliaMobileStat.create(run_date: current_date)
    end
    
    # **** Local Connection ****

    # driver = Selenium::WebDriver.for :chrome

    # *****************************************


    # **** For Server ****

    system("killall -9 chromedriver")
    system("killall -9 chrome")
    Selenium::WebDriver::Chrome::Service.driver_path ='/usr/bin/chromedriver'

    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--headless")
    options.add_argument("--remote-debugging-port=9222")
    options.add_argument("--disable-infobars")
    options.add_argument("--disable-popup-blocking")
    driver = Selenium::WebDriver.for :chrome, options: options

    # *******************
    driver.manage.window.maximize
    driver.get('https://www.finder.com.au/mobile-plans')
    sleep(5)
    all_brands = ["10Mates", "Accord", "Activ8me", "AGL", "ALDImobile", "amaysim", "ANT Communications", "Aussie Broadband", "Australia Broadband", "Belong", "Bendigo Telco", "Better Life", "Boost Mobile", "Catch Connect", "Circles.Life", "Clear Networks", "Click Broadband", "Cmobile", "Coles Mobile", "Commander", "dodo", "Exetel", "felix Mobile", "Flip", "Foxtel", "Future Broadband", "Fuzenet", "gomo", "Goodtel", "gotalk Mobile", "Harbour ISP", "Hello Mobile", "iiNet", "Infinity", "Inspired Broadband", "Internode", "iPrimus", "IPSTAR", "JB Hi-Fi", "Kogan", "Lebara", "Logitel", "Lycamobile", "Mate", "Mint Telecom", "Moose Mobile", "More telecom", "MyNetFone", "MyRepublic", "Nextalk", "numobile", "Optus", "Origin", "Pennytel", "Reachnet", "Reward", "SkyMesh", "Southern Phone", "SpinTel", "Start Broadband", "Superloop", "Swoop Broadband", "Tangerine Telecom", "TeleChoice", "Telstra", "Think Mobile", "Tomi", "TPG", "Uniti", "Vaya", "Vodafone", "Westnet", "Woolworths", "Yomojo", "Zero"]

    country_id = Country.find_by(name: 'Australia')['id']

    AutraliaMobilePlan.where(source_url: 'https://www.finder.com.au/mobile-plans').update_all('is_visited': false)

    hash_array = []
    excluded_providers = ["amaysim", "Lebara", "Optus", "Southern Phone", "Telstra", "TPG", "Vodafone"]
    (0..0).each do |run|
      if run == 0
        pp = Nokogiri::HTML(driver.page_source)
        pp.css("div.intercomChatButton").remove
        pp.css("iframe.intercom-launcher-discovery-frame").remove
        total_pages = pp.css('.luna-button.comparison-table__paginationNav-number')[-1].text.to_i rescue 0
        # total_pages = total_pages - 1
        page_num = 0
        hash_array = scrape_using_usage(page_num, total_pages, driver, pp, all_brands, excluded_providers, country_id, hash_array, 'Personal')
      else
        driver.find_elements(css: "label").select{|e| e.text == 'Business'}[0].click()
        sleep(2)
        driver = business_selection(driver)
        pp = Nokogiri::HTML(driver.page_source)
        break if pp.css('h1').text.include? 'No results found'
        pp.css("div.intercomChatButton").remove
        pp.css("iframe.intercom-launcher-discovery-frame").remove 
        total_values = pp.css('.luna-button.comparison-table__paginationNav-number')[-1]['data-offset'].to_i
        total_pages = (total_values/10).to_i
        page_num = 0
        hash_array = scrape_using_usage(page_num, total_pages, driver, pp, all_brands, excluded_providers, country_id, hash_array, 'Business')
      end
    end
    AutraliaMobilePlan.where(source_url: 'https://www.finder.com.au/mobile-plans', is_visited: false).update_all(is_deleted: true)
    run_object.update(is_completed: true)
    driver.quit
  end
end
# ob = FinderMobile.new
# ob.scraper()

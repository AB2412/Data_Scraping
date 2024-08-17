require 'net/http'
require 'nokogiri'
require 'json'
require 'byebug'
require 'selenium-webdriver'

class FinderBroadband

  def get_values(page, search_text)
    values = page.css('dt').select{|e| e.text.include? search_text}
    if !values.empty?
      value = values[0].next_element.text.strip
    else
      value = ''
    end
    value
  end

  def get_plan_info(data_hash, page, index)
    plan_name_1 = page.css(".product-name").first.text
    splited_plan = plan_name_1.split
    provider_name = splited_plan.first
    data_hash["plan_name"] = plan_name_1.gsub(provider_name,"").strip
    data_hash["contract_duration"] = get_values(page, "Plan length")
    source_contract_duration = data_hash['contract_duration']
    if data_hash['contract_duration'] == '1 month'
      data_hash['contract'] = 'No Contract'
    else
      if data_hash['contract_duration'].downcase.include? 'day'
        data_hash['contract'] = data_hash['contract_duration'].scan(/\d/).join.to_i <= 30 ? "No Contract" : "Contract"
      elsif data_hash['contract_duration'].downcase.include? 'months'
        data_hash['contract'] = "Contract"
      end
    end
    data_hash['contract'] = source_contract_duration
    data_hash["connection_type"] = get_values(page, "Connection Type")

    if data_hash["plan_name"].include? "Wireless" or data_hash["plan_name"].include? "Modem"
      data_hash["connection_type"] = "Wireless"
    end
    data_hash["connection_technology"] = get_values(page, "Technology type")
    download_speed  = get_values(page, "Typical download speed (Mbps)")
    data_hash["download"] = (download_speed == "") ? get_values(page, "Shaping speed download") : download_speed
    data_hash["upload"] = get_values(page, "Typical upload speed (Mbps)")
    data_hash["peak_download_speed"]  = (get_values(page, "Maximum download speed (Mbps)") == "") ? get_values(page, "Shaping speed upload") : get_values(page, "Maximum download speed (Mbps)")
    data_hash["source_contract_duration"] = source_contract_duration
    return data_hash, provider_name
  end

  def get_data_info(data_hash, page, index)
    data_hash["data_limit"] = get_values(page, "Data Allowance")
    peak_and_off_peak = page.css(".data-desktop div")[1].text.squish rescue nil
    splited_peak = peak_and_off_peak.split(",") rescue nil
    data_hash["off_peak_data"] = ((splited_peak[0].include? "Off peak") || (splited_peak[0].include? "Off Peak")) ? splited_peak[0] : ((splited_peak[1].include? "Off peak") || (splited_peak[1].include? "Off Peak")) ? splited_peak[1] : nil rescue nil
    data_hash["anytime_data"] = (splited_peak[0].include? "Anytime") ? splited_peak[0].squish : (splited_peak[1].include? "Anytime") ? splited_peak[1].squish : nil rescue nil
    data_hash["peak_data_times"] = get_values(page, "Peak data (times)")
    return data_hash
  end

  def get_fee_info(data_hash, page, index)
    data_hash["price"] = get_values(page, "Ongoing cost")
    data_hash["minimum_total_cost"] = get_values(page, "Minimum cost")
    data_hash["installation_cost"] = get_values(page, "Setup fee")
    data_hash["modem_postage"] = get_values(page, "Modem delivery fee")

    if data_hash["modem_postage"] != "" and data_hash["modem_postage"] != nil
      if !data_hash["modem_postage"].include? '$'
        data_hash["modem_postage"] = "$ "+data_hash["modem_postage"]
      end
    end
    data_hash["modem_fee"] = get_values(page, "Modem cost")
    data_hash["modem_description"] = get_values(page, "Modem description")
    if data_hash["modem_fee"].downcase.include? 'optional' or data_hash["modem_description"].upcase.include? 'byo'.upcase
      data_hash["byo_modem"] = 'BYO Modem' 
    end

    return data_hash
  end

  def get_bundle_tag_info(data_hash, page, index)
    foxtel_plus = get_values(page, "Foxtel Plus") rescue nil
    if data_hash['entertainment_streaming'] != ''
      data_hash['entertainment_streaming'] = data_hash['entertainment_streaming'] + "\n" + foxtel_plus
    else
      data_hash['entertainment_streaming'] = foxtel_plus
    end
    sports = get_values(page, "Sports HD") rescue nil
    if data_hash['entertainment_sport'] != ''
      data_hash['entertainment_sport'] = data_hash['entertainment_sport'] + "\n" + sports
    else
      data_hash['entertainment_sport'] = sports
    end
    data_hash
  end

  def get_bundle_info(data_hash, page, index)
    home_phone =  get_values(page, "Home phone included")
    if home_phone.present?
      data_hash['landline'] = home_phone
    end
    data_hash
  end

  def get_brand(array, element)
    sub_string = array.select{|s| element.upcase.include? s.upcase}
    sub_string_1 = array.select{|s| element.split.join.upcase.include? s.split.join.upcase}
    matched_elements = array.select{|s| s.split.join.upcase.include? element.split.join.upcase }
    matched_elements.count > 0 ? matched_elements.first : sub_string.count > 0 ? sub_string.first : sub_string_1.count > 0 ? sub_string_1.first : false
  end

  def clean_plan_name(plan_name, provider_complete_name, provider_matched_name)
    if plan_name.downcase.start_with? "#{provider_complete_name.downcase} broadband"
      provider_length = "#{provider_complete_name.downcase} broadband".split(' ').length
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

  def scrape_using_usage(driver, usage_type, target_elements, last_page_visited, current_date)
    pp = Nokogiri::HTML(driver.page_source)
    total_pages = (usage_type == "Personal") ? pp.css('button.comparison-table__paginationNav__button')[-2].text.to_i : pp.css('.luna-button.comparison-table__paginationNav-number')[-1].text.to_i
    puts "Total Number of Plans are --> #{total_pages}"
    page_num = 1
    skip_pages = 0
    hash_array = []
    country_id = Country.find_by(name: 'Australia')['id'] rescue nil
    all_provider_plans = []
    all_brands = ["10Mates", "Accord", "Activ8me", "AGL", "ALDImobile", "amaysim", "ANT Communications", "Aussie Broadband", "Australia Broadband", "Belong", "Bendigo Telco", "Better Life", "Boost Mobile", "Catch Connect", "Circles.Life", "Clear Networks", "Click Broadband", "Cmobile", "Coles Mobile", "Commander", "dodo", "Exetel", "felix Mobile", "Flip", "Foxtel", "Future Broadband", "Fuzenet", "gomo", "Goodtel", "gotalk Mobile", "Harbour ISP", "Hello Mobile", "iiNet", "Infinity", "Inspired Broadband", "Internode", "iPrimus", "IPSTAR", "JB Hi-Fi", "Kogan", "Lebara", "Logitel", "Lycamobile", "Mate", "Mint Telecom", "Moose Mobile", "More telecom", "MyNetFone", "MyRepublic", "Nextalk", "numobile", "Optus", "Origin", "Pennytel", "Reachnet", "Reward", "SkyMesh", "Southern Phone", "SpinTel", "Start Broadband", "Superloop", "Swoop Broadband", "Tangerine Telecom", "TeleChoice", "Telstra", "Think Mobile", "Tomi", "TPG", "Uniti", "Vaya", "Vodafone", "Westnet", "Woolworths", "Yomojo", "Zero"]
    starter_index = 0
    index_count = 0
    flag_1 = true
    while flag_1 == true
      puts "Processing Page Number ---> #{page_num}\n"
      if page_num >= last_page_visited
        pp = Nokogiri::HTML(driver.page_source)
        sleep(5)
        target_elements_new = driver.find_elements(css: 'span').select{ |e| e.text == 'View details'}
        sleep(10)
        target_elements_new.each_with_index do |target_element, index|
          begin
            target_element.click
            sleep(5)
          rescue Exception => e
            driver.execute_script("window.scrollBy(0, -500)")
            sleep(5)
            begin
              target_element.click()
            rescue Exception => e 
              driver.execute_script('arguments[0].scrollIntoView(true)', target_element)
              sleep(5)
              driver.execute_script("window.scrollBy(0, -500)")
              sleep(5)
              target_element.click()
            end
          end
        end
        sleep(5) 
        pp = Nokogiri::HTML(driver.page_source)
        all_articles_temp = pp.css('form[name="compareForm"]').css('table tbody tr')
        available_plans = pp.css('form[name="compareForm"]').css('table tbody tr')
        all_articles = available_plans.map.with_index{|e, index| [index,e['data-product-id']]}
        temp = (skip_pages * 10) + index_count
        flag_count = 0
        all_articles = [] if page_num <= skip_pages
        puts "all_articles count ---> #{all_articles.count}"
      
        available_plans.each_with_index do |article, index|
          break if flag_count >=10
          data_hash = {}
          search_data_hash = {}
          providers_data_hash = {}
          if page_num > 1
            starter_index = temp + index
          else
            starter_index = index
          end
          puts "STARTER INDX ---> #{starter_index}"
          flag_count+=1
          index_count +=1
          begin
            data_hash, provider_name = get_plan_info(data_hash, article, starter_index)
          rescue Exception => e
            break if driver.find_elements(css: 'span').select{ |e| e.text == 'View details'}.count == 0
          end
          provider_name_check = all_brands.select{|e| e.upcase.include? provider_name.upcase}
          if !provider_name_check.empty?
            providers_data_hash[:name] = provider_name_check[0]
          elsif get_brand(all_brands, provider_name)
            providers_data_hash[:name] = get_brand(all_brands, provider_name)
          else
            providers_data_hash[:name] = provider_name.downcase
          end
          providers_data_hash[:country_id] = country_id
          provider = Provider.find_or_create_by(providers_data_hash)
          provider_id  = provider[:id]
          data_hash["provider_id"] = provider_id
          data_hash["plan_name"]  = clean_plan_name(data_hash["plan_name"], provider_name, providers_data_hash[:name])
          data_hash['usage_type'] = usage_type
          data_hash['recharge_period'] =  article.css(".price-desktop").children[1].text
          if !driver.find_elements(css: '.modal-body.modal-body--geoip').empty?
            driver.find_elements(css: '.modal-body.modal-body--geoip')[0].find_elements(css: 'button.btn-link.geoip__close')[0].click
          end
          data_hash = get_data_info(data_hash, article, starter_index)
          data_hash = get_fee_info(data_hash, article, index)
          features = article.css('.offer-details').text.gsub("OFFER:","").squish
          data_hash = get_bundle_info(data_hash, article, index)
          data_hash["features"] = features
          if article.css('.offer-details').count != 0
            data_hash["promotions"] = article.css('.offer-details').text.gsub("SPECIAL OFFER ","").strip
          else
            if article.css('div[class="fbb__couponText"]').count != 0
              data_hash['promotions'] = article.css('div[class="fbb__couponText"]')[0].text.strip
            else
              data_hash["promotions"] = ''
            end
          end
          data_hash["is_on_promotion"] = data_hash["promotions"] == "" ? "No" : "Yes"
          if (data_hash['is_on_promotion'] == "Yes") && (!data_hash['promotions'].upcase.include? 'Online Offer:'.upcase) && (!data_hash['promotions'].upcase.include? 'AGL Energy'.upcase)
            if data_hash['promotions'].downcase.include? 'promo code to get your first month free' or data_hash['promotions'].downcase.include? 'use coupon to get your first month free'
              data_hash['discounted_price'] = "$0"
              #NEW discountedPeriod
            data_hash['discounted_period'] = 'first month free'
            elsif data_hash["promotions"].downcase.include? "off for ".downcase
              off_value = data_hash["promotions"].split(" ").select{|e| e.include? '$'}[0].match(/[-+]?\d*\.\d+|\d+/)[0].to_f
              total_value = data_hash["price"].gsub('$','').to_i
              compute_value = total_value - off_value
              data_hash["discounted_price"] = compute_value
              if !data_hash["promotions"].include? 'new orders'
                data_hash['discounted_period'] = data_hash["promotions"].split('off for ')[1]
              end
            elsif data_hash["promotions"].downcase.include? "for the ".downcase or data_hash['promotions'].downcase.include? 'for first'.downcase
              data_hash["discounted_price"] = data_hash["promotions"].split("for the first")[0].split("/")[0].strip.split[-1].strip
              #NEW discountedPeriod
            data_hash['discounted_period'] = data_hash["promotions"].split('for')[1].split(',')[0].split('then')[0].split('instead')[0].gsub('the', '').strip
              split_promotion = data_hash["promotions"].split("for the first")[-1].split('then')[-1]
              if split_promotion.include? "/"
                post_discount_price = split_promotion.split('/')[0].strip.split[-1].strip 
              else
                post_discount_price = split_promotion.match(/[-+]?\d*\.\d+|\d+/)[0] rescue []
              end
              data_hash['price'] = post_discount_price
            elsif data_hash['promotions'].include? 'get this plan at'
              data_hash["discounted_price"] = data_hash['promotions'].split.select{|e| e.include? '$'}[0].gsub('/mth','').gsub('.','')
              post_discount_price = data_hash['promotions'].split.select{|e| e.include? '$'}[-1].gsub('/mth','').gsub('.','')
              data_hash['price'] = post_discount_price
            else
              if (data_hash['promotions'].include? 'month free') || (data_hash['promotions'].include? 'months free')
                data_hash['discounted_price'] = "$0"
                data_hash['discounted_period'] = data_hash['promotions'].gsub(',', '.').split('.')[0].gsub('Get', '').strip
              else
                if data_hash['promotions'].upcase.include? 'pay'.upcase
                  data_hash["discounted_price"] = data_hash['promotions'].split('. ')[0].split.select{|e| e.include? '$'}[0]
                  post_discount_price = data_hash['promotions'].split('. ')[0].split.select{|e| e.include? '$'}[-1]
                  data_hash['price'] = post_discount_price
                else
                  data_hash["discounted_price"] = ''
                end
              end
            end
          else
            data_hash["discounted_price"] = ''
          end
          if data_hash['discounted_price'] != '' and data_hash['discounted_price'] != nil
            if !data_hash['discounted_price'].to_s.include? '$'
              data_hash['discounted_price'] = "$" + data_hash['discounted_price'].to_s
            end
          end
          #NEW GAS and ELECTRICITY
          if data_hash['promotions'].include? 'Energy'
            data_hash['electricity'] = data_hash['promotions']
            data_hash['gas'] = data_hash['promotions']
          else
            energy_feature = features.select{|e| e.include? "energy"}.join("\n") rescue ""
            data_hash['electricity'] = energy_feature
            data_hash['gas'] = energy_feature
          end
          data_hash['bundled_electricity'] = data_hash['bundled_gas'] = 'AddOn' if data_hash['electricity'] != ""
          data_hash['price'] = "$#{data_hash['price']}" unless data_hash['price'].include? '$'
          if (features.class == Array)
            data_hash['static_ip'] = features.select{|e| e.upcase.include? 'static'.upcase}.count != 0 ? features.select{|e| e.upcase.include? 'static'.upcase}.join("\n") : ""
            data_hash['mobile'] = features.select{|e| e.upcase.include? 'mobile'.upcase}.count != 0 ? features.select{|e| e.upcase.include? 'mobile'.upcase}.join("\n") : ""
            data_hash['entertainment_hardware'] =  features.select{|s| (s.downcase.include? "channel") or (s.downcase.include? "tv") or (s.downcase.include? "optional fetch")}.join('\n') rescue ""
            data_hash['entertainment_disney'] = features.select{|s| s.downcase.include? 'disney'}.join("\n")
            data_hash['entertainment_gaming'] = features.select{|s| (s.downcase.include? 'gaming') || (s.downcase.include? 'game') }.join("\n")
            data_hash['entertainment_sport'] = features.select{|s| s.downcase.include? 'sport'}.join("\n")
            data_hash['entertainment_streaming'] = features.select{|s| (s.downcase.include? 'netflix') || (s.downcase.include? 'amazon')}.join('\n')
            data_hash['entertainment_music'] = features.select{|e| (e.downcase.include? 'spotify') || (e.downcase.include? 'music') }.join("\n")
            data_hash['data_details'] = features.select { |e| (e.include? 'off-peak') || (e.downcase.include? 'data')}.join("\n")
          else
            data_hash['static_ip'] = ""
            data_hash['mobile'] = ""
            data_hash['entertainment_hardware'] = ""
            data_hash['entertainment_disney'] = ""
            data_hash['entertainment_gaming'] = ""
            data_hash['entertainment_sport']  = ""
            data_hash['entertainment_streaming'] = ""
            data_hash['entertainment_music'] = ""
            data_hash['data_details'] = ""
          end
          data_hash["source_url"] = "https://www.finder.com.au/broadband-plans"
          data_hash['termination_fee'] = ""
          data_hash['terms_conditions'] = ""
          if data_hash['entertainment_disney'] != '' or data_hash['entertainment_gaming'] != '' or data_hash['entertainment_sport'] != '' or data_hash['entertainment_streaming'] != '' or data_hash['entertainment_music'] != ''
              data_hash['bundled_entertainment'] = 'AddOn'
          end
          if data_hash['landline'].present? && data_hash['mobile'].present?
            if data_hash['mobile'] == data_hash['landline']
              data_hash['mobile'] = ""
            end
          end
          if data_hash['landline'].present?
            if (data_hash['landline'].include? '$') && (data_hash['landline'].include? 'call pack for')
              data_hash['bundled_landline'] = "Included"
            else
              data_hash['bundled_landline'] = ((data_hash['landline'].include? '$') || (data_hash['landline'].downcase.include? 'pay ') || (data_hash['landline'].include? 'PAYG')) ? 'AddOn' : 'Included'
            end
          end
          if data_hash['mobile'].present? && data_hash['connection_type'] != "Mobile Broadband"
            data_hash['bundled_mobile'] = ((data_hash['mobile'].include? '$')  || (data_hash['mobile'].downcase.include? 'pay ')) ? 'AddOn' : 'Included'
          end
          data_hash = get_bundle_tag_info(data_hash, article, index)
          data_hash['is_visited'] = true
          data_hash['is_deleted'] = false
          if driver.window_handles.count > 1
            td = driver.window_handles[-1] 
            driver.switch_to.window(td)
            driver.close()
            td = driver.window_handles[-1] 
            driver.switch_to.window(td)
          end
          hash_array << data_hash
          data_hash = udpate_nil_to_empty(data_hash)
          search_data_hash[:provider_id] =    data_hash["provider_id"]
          search_data_hash[:contract]    =    data_hash['contract']
          search_data_hash[:plan_name]   =    data_hash["plan_name"]
          record = AustraliaInternetPlan.find_by({plan_name: data_hash["plan_name"], provider_id: data_hash["provider_id"]})
          source_contract_duration = data_hash['source_contract_duration']
          data_hash = data_hash.except('source_contract_duration')
          if record
            if record['contract_duration'] ==  data_hash['contract_duration']
              record.update(data_hash)
            else
              updated_plan = data_hash["plan_name"] + " (" + source_contract_duration + ")"
              record_contract = AustraliaInternetPlan.find_by({plan_name: updated_plan, provider_id: data_hash["provider_id"]})
              original_plan_name = data_hash["plan_name"]
              data_hash["plan_name"] = updated_plan
              if record_contract
                record_contract.update(data_hash)
              else
                if record['contract_duration'] != "" && data_hash['contract_duration'] == ""
                  record.update(plan_name: "#{record['plan_name']} (#{record['contract_duration']})")
                  data_hash["plan_name"] = original_plan_name
                end
                AustraliaInternetPlan.create(data_hash)
              end
            end
          else
            AustraliaInternetPlan.create(data_hash)
          end
        end
        if usage_type == "Personal"
          AustraliaInternetStat.where(run_date: current_date).update(personal_page: page_num)
        else
          AustraliaInternetStat.where(run_date: current_date).update(business_page: page_num)
        end
        page_num += 1
        if usage_type == "Personal"
          next_btn = driver.find_elements(css: "button.comparison-table__paginationNav__button.comparison-table__paginationNav__button-number").select {|e| e.text == page_num.to_s}.first rescue nil
          sleep(5)
          flag_1 = (next_btn.nil?) ? false : true 
          break if flag_1 == false
          next_btn.click()
          sleep(5)
        else
          flag_1 = (driver.find_element(css: ".comparison-table__paginationNav-next")['data-offset'] == "null") ? false : true
          break if flag_1 == false
          driver.find_element(css: ".comparison-table__paginationNav-next").click()
          sleep(5)
        end
      else
        page_num += 1
        if usage_type == "Personal"
          next_btn = driver.find_elements(css: "button.comparison-table__paginationNav__button.comparison-table__paginationNav__button-number").select {|e| e.text == page_num.to_s}.first rescue nil
          sleep(5)
          flag_1 = (next_btn.nil?) ? false : true 
          break if flag_1 == false
          next_btn.click()
          sleep(5)
        else
          begin
            driver.find_element(css: ".comparison-table__paginationNav-next").click()
            sleep(5)
          rescue Exception => e
            next_element = driver.find_element(css: ".comparison-table__paginationNav-next")
            driver.execute_script('arguments[0].scrollIntoView(true)', next_element)
            sleep(5)
            next_element.click()
            sleep(5)
          end
        end
      end
    end
  end

  def scraper
    current_date = Date.today
    current_date_runs = AustraliaInternetStat.where(run_date: current_date)
    if current_date_runs.count > 0
      run_object = current_date_runs[-1]
    else
      run_object = AustraliaInternetStat.create(run_date: current_date)
    end

    # # **** For Server ****
    
    # system("killall -9 chromedriver")
    # system("killall -9 chrome")

    # Selenium::WebDriver::Chrome::Service.driver_path ="#{Dir.pwd}/chromedriver"

    # options = Selenium::WebDriver::Chrome::Options.new
    # options.add_argument("--no-sandbox")
    # options.add_argument("--disable-dev-shm-usage")
    # options.add_argument("--headless")
    # options.add_argument("--headless")
    # options.add_argument("--remote-debugging-ip=#{proxy_array.sample}")
    # options.add_argument("--remote-debugging-port=8000")
    # options.add_argument("--disable-infobars")
    driver = Selenium::WebDriver.for :firefox

    # wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    driver.get('https://www.finder.com.au/broadband-plans')
    sleep(10)
    driver.find_elements(css:'#accept-cookies-button')[1].click() rescue nil
    sleep(5)
    target_elements = driver.find_elements(css: 'span').select{ |e| e.text == 'View details'}
    last_run_personal = AustraliaInternetStat.pluck(:personal_run).last
    last_run_business = AustraliaInternetStat.pluck(:business_run).last
    (0..1).each do |run|
      if run == 0
        if last_run_personal == false
          last_page_visited = AustraliaInternetStat.pluck(:personal_page).last
          driver.find_elements(css: 'button').select{ |e| e.text == 'Clear all'}[0].click()
          sleep(4)
          driver.find_elements(css: 'span').select{ |e| e.text == 'Only show products with direct links & enquiry options'}[0].click()
          sleep(2)
          # driver.find_elements(css: 'span').select{ |e| e.text == 'All providers'}[0].click()
          sleep(2)
          if last_page_visited == 0
            AustraliaInternetPlan.where(source_url: 'https://www.finder.com.au/broadband-plans', usage_type: 'Personal').update_all('is_visited': false)
          end
          scrape_using_usage(driver, 'Personal', target_elements, last_page_visited, current_date)
          sleep(4)
          AustraliaInternetPlan.where(source_url: 'https://www.finder.com.au/broadband-plans', usage_type: 'Personal', is_visited: false).update_all(is_deleted: true)
          AustraliaInternetStat.where(run_date: current_date).update(personal_run: true)
        end
      else
        if last_run_business == false
          last_page_visited = AustraliaInternetStat.pluck(:business_page).last
          driver.get("https://www.finder.com.au/broadband-plans/business-broadband-plans")
          sleep(5)
          driver.find_elements(css: '.luna-label').select{ |e| e.text == 'Only show products with direct links & enquiry options'}[0].click()
          sleep(5)
          if last_page_visited == 0
            AustraliaInternetPlan.where(source_url: 'https://www.finder.com.au/broadband-plans', usage_type: 'Business').update_all('is_visited': false)
          end
          scrape_using_usage(driver, 'Business', target_elements, last_page_visited, current_date)
          AustraliaInternetPlan.where(source_url: 'https://www.finder.com.au/broadband-plans', usage_type: 'Business', is_visited: false).update_all(is_deleted: true)
          AustraliaInternetStat.where(run_date: current_date).update(business_run: true)
        end
      end
    end
    run_object.update(is_completed: true)
    driver.quit
  end
end

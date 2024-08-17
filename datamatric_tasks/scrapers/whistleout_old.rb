require 'net/http'
require 'nokogiri'
require 'json'
require 'byebug'
require 'mechanize'
require 'selenium-webdriver'
# require "capybara"

class WhistleoutOld

  def get_values(page, search_text)
    values = page.css('div[class="col-sm-6"]').select{|e| e.text.include? search_text}
    if !values.empty?
      if search_text == 'Total Price'
        value = values[-1].next_element.text.split('per')[0].strip
          return [value, '']
      else
        if search_text == 'Modem'
          value = values[-1].text.strip
        else
          value = values[-1].next_element.text.strip
        end
      end

      if search_text == 'Data'
        data = values[-1].next_element.css('strong').text.strip
        data_details = values[-1].next_element.css('li').map(&:text).join(' \n')
        return [data, data_details]
      end
    else
      value = ''
    end
    value
  end

  def get_plan_details(plan_details, search_text)
    values = plan_details.css('h3').select{|e| e.text.include? search_text}
    if !values.empty?
      value = values[0].next_element.text.strip
    else
      value = ''
    end
    value
  end

  def get_brand(array, element)
    sub_string = array.select{|s| element.upcase.include? s.upcase}
    sub_string_1 = array.select{|s| element.split.join.upcase.include? s.split.join.upcase}
    matched_elements = array.select{|s| s.split.join.upcase.include? element.split.join.upcase }
    matched_elements.count > 0 ? matched_elements.first : sub_string.count > 0 ? sub_string.first : sub_string_1.count > 0 ? sub_string_1.first : false
  end

  def clean_plan_name(plan_name, provider_complete_name, provider_matched_name)
    if plan_name.downcase.include? "#{provider_complete_name.downcase} broadband"
      provider_length = "#{provider_complete_name.downcase} broadband".split(' ').length
      plan_name = plan_name.split(' ')[provider_length..-1].join(' ')
    elsif plan_name.downcase.include? provider_complete_name.downcase
      provider_length = provider_complete_name.split(' ').length
      plan_name = plan_name.split(' ')[provider_length..-1].join(' ')
    elsif plan_name.downcase.include? provider_matched_name.downcase
      provider_length = provider_matched_name.split(' ').length
      plan_name = plan_name.split(' ')[provider_length..-1].join(' ')
    elsif plan_name.downcase.include? provider_matched_name.split(' ')[0].downcase
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


  def download(download_speed, features_array)
    #for all
    if download_speed.include? "Download"
      download = download_speed.split.select{|e| e.include? "Mbps"}[0]
    else
      download_speed_feature = features_array.select{|e| e.include? "download"}
        if !download_speed_feature.empty?
          download = features_array.select{|e| e.include? "download"}[0].split.select{|e| e.include? "Mbps"}[0]
        end
    end
    download
  end


  def scraper()
    agent = Mechanize.new
    agent.user_agent_alias = "Windows Mozilla"
    agent.set_proxy(ENV['PROXY_HOST'], ENV['PROXY_PORT'], "#{ENV['PROXY_USER']}:#{ENV['PROXY_PASSWORD']}")
    agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    hash_array = []
    excluded_providers = ["amaysim", "Lebara", "Optus", "Southern Phone", "Telstra", "TPG", "Vodafone"]
    all_brands = ["10Mates", "Accord", "Activ8me", "AGL", "ALDImobile", "amaysim", "ANT Communications", "Aussie Broadband", "Australia Broadband", "Belong", "Bendigo Telco", "Better Life", "Boost Mobile", "Catch Connect", "Circles.Life", "Clear Networks", "Click Broadband", "Cmobile", "Coles Mobile", "Commander", "dodo", "Exetel", "felix Mobile", "Flip", "Foxtel", "Future Broadband", "Fuzenet", "gomo", "Goodtel", "gotalk Mobile", "Harbour ISP", "Hello Mobile", "iiNet", "Infinity", "Inspired Broadband", "Internode", "iPrimus", "IPSTAR", "JB Hi-Fi", "Kogan", "Lebara", "Logitel", "Lycamobile", "Mate", "Mint Telecom", "Moose Mobile", "More telecom", "MyNetFone", "MyRepublic", "Nextalk", "numobile", "Optus", "Origin", "Pennytel", "Reachnet", "Reward", "SkyMesh", "Southern Phone", "SpinTel", "Start Broadband", "Superloop", "Swoop Broadband", "Tangerine Telecom", "TeleChoice", "Telstra", "Think Mobile", "Tomi", "TPG", "Uniti", "Vaya", "Vodafone", "Westnet", "Woolworths", "Yomojo", "Zero"]
    country_id = Country.find_by(name: 'Australia')['id']

    AustraliaInternetPlan.where("source_url LIKE (?)", "https://www.whistleout.com.au%").update_all('is_visited': false)

    tabs = ['homewireless', 'mobileall', 'other']
    usage_type = ['Personal', 'Business']

    tabs.each_with_index do |tab, tab_index_no|
      usage_type.each do |type|
        counter = 0
        url = "https://www.whistleout.com.au/Broadband/Search?tab=#{tab}&supplier=Tangerine-Telecom,SpinTel,Telstra,Superloop,TPG,Aussie-Broadband,iiNet,Optus,Dodo,Internode,MyRepublic,Vodafone,SkyMesh,Exetel,Kogan-Internet,Mate,Belong,Activ8me,iPrimus,Southern-Phone,ALDImobile,Moose-Mobile,IPSTAR,amaysim,Kogan-Mobile,Lebara-Mobile&customer=#{type}"
        puts "Processing URL --------> #{url}"
        response = agent.get(url)
        pp = Nokogiri::HTML(response.body)
        if tab == 'homewireless'
          total_records = pp.css('button').select{|e| e.css('strong').text.include? 'Wireless'}[0].css('span[class="hidden-md"]')[-1].text.scan(/\d/).join.to_i
        elsif tab == 'other'
          total_records = pp.css('button').select{|e| e.css('strong').text.include? 'Other'}[0].css('span[class="hidden-md"]')[-1].text.scan(/\d/).join.to_i
        else
          total_records = pp.css('button').select{|e| e.css('strong').text.include? 'Mobile'}[0].css('span[class="hidden-md"]')[-1].text.scan(/\d/).join.to_i
        end
        next if total_records == 0
        if total_records == "NULL"
          total_pages = 1
        else
          total_pages = (total_records / 20)+ 1
        end
        
        page_number = 1
        while page_number <= total_pages
          puts "Page Number ---> #{page_number}"

          if page_number == 1
            table_data =  pp.css("div##{tabs[tab_index_no]}")[0].css('div.results-list')[0].css('div.results-item.row.pad-y-4.sep-b-1.bor-a-8-xs.bg-white-xs.mar-y-6-xs.bor-b-1.rounded-3.position-relative').reject{|e| e.text.include? "Ad "} rescue "NULL"
          else
            table_data =  pp.css('div.results-item.row.pad-y-4.sep-b-1.bor-a-8-xs.bg-white-xs.mar-y-6-xs.bor-b-1.rounded-3.position-relative').reject{|e| e.text.include? "Ad "} rescue "NULL"
          end

          break if table_data == "NULL"

          all_features = table_data.map{|e| e.css('div[class="col-xs-24"]').css('li').map{|e| e.text.strip}.join("\n")}

          # all_dowload_speeds = table_data.map{|e| e.css('div[class="c-gray-darker font-feature font-700"]').text.split.join(' ')}

          if tab == "other"
            all_dowload_speeds = table_data.map{|e| e.css('div[class="c-gray-darker font-feature font-700 mar-b-2 mar-b-0-xs"]').text.squish}
          else
            all_dowload_speeds = table_data.map{|e| e.css('.col-xs-12')[1].css('span')[-1].text.strip.squish}
          end

          all_entries = table_data.map{|e| e.css('a[data-action="ProductClick"]')[0]['href']}

          break if all_entries.count == 0

          all_entries.each_with_index do |link, index|
            data_hash = {}
            search_data_hash = {}
            providers_data_hash = {}

            complete_link = 'https://www.whistleout.com.au'+link

            puts "Processing Link --> #{complete_link}"
            response = agent.get(complete_link)
            page = Nokogiri::HTML(response.body)

            data_hash['plan_name'] = page.css('h1').text
            provider_name = page.css('div[class="[ mar-y-2 ]"]').text.strip

            next if excluded_providers.select{|s| provider_name.include? s}.count > 0
            
            provider_name_check = all_brands.select{|e| e.upcase == provider_name.upcase}

            if provider_name_check.count == 0
              provider_name_check = all_brands.select{|e| e.upcase.include? provider_name.upcase}
            end

            if !provider_name_check.empty?
              providers_data_hash[:name] = provider_name_check[0]
            elsif get_brand(all_brands, provider_name)
              providers_data_hash[:name] = get_brand(all_brands, provider_name)
            else
              providers_data_hash[:name] = provider_name
            end

            providers_data_hash[:country_id] = country_id
            provider = Provider.find_or_create_by(providers_data_hash)

            provider_id  = provider[:id]
            data_hash["provider_id"] = provider_id

            data_hash["plan_name"]  = clean_plan_name(data_hash["plan_name"], provider_name, providers_data_hash[:name])

            data_hash['usage_type'] = type

            data_hash['price'], data_hash['price_details'] = get_values(page, "Total Price")

            data_hash['speed_details'] = get_values(page, 'Speed').split.join(' ').gsub('Guide to nbn™ Speeds', '').strip

            data_hash['features'] = all_features[index]
            features_array = all_features[index].split("\n")

            download_speed = all_dowload_speeds[index]
            if tab == "other"
              if download_speed.include? "Mbps"
                delete_memorry = download_speed.split
                delete_memorry.delete_at(-1)
                data_hash['download'] = delete_memorry.join(" ")
              end
            else
              data_hash['download'] = download(download_speed, features_array)
            end

            data_hash["data_limit"], data_hash["data_details"] = get_values(page, 'Data')

            if data_hash['data_limit'].include? 'Unlimited'
              data_hash['recharge_period'] = data_hash['data_limit'].split('Unlimited').join(' ').strip
              data_hash['data_limit'] = data_hash['data_limit'].split.select{|e| e == 'Unlimited'}[0]
            else
              data_hash['recharge_period'] = data_hash['data_limit'].split('GB')[-1].strip
              data_hash['data_limit'] =  data_hash['data_limit'].split('GB')[0] + "GB"
            end

            if data_hash['data_details'].downcase.include? 'peak'
              splited_array = data_hash["data_details"].split("\n")
              data_hash['peak_data_times'] = splited_array.select{|e| e.include? ' peak'}[0].split('(')[-1].gsub(')','').strip
            else
              data_hash['peak_data_times'] = ''
            end

            data_hash["connection_type"] = get_values(page, 'Connection').split.join(' ')
            data_hash["contract"] = get_values(page, 'Type').split.join(' ')

            unless data_hash['contract'].include? 'No Contract Term'
              data_hash['contract_duration'] = data_hash['contract'].split(' ')[0..1].join(' ')
              data_hash['contract'] = 'Contract'
            else
              data_hash['contract'] = "No Contract"
              data_hash['contract_duration'] = ''
            end

            if data_hash['contract_duration'] == '1 month'
              data_hash['contract'] = 'No Contract'
            else
              if data_hash['contract_duration'].downcase.include? 'day'
                data_hash['contract'] = data_hash['contract_duration'].scan(/\d/).join.to_i <= 30 ? "No Contract" : "Contract"
              end
            end

            source_contract_duration = data_hash['contract_duration']

            if get_values(page, 'Type').split.join(' ').include? 'Prepaid'
              contract_details = get_values(page, 'Type').split.join(' ')
              data_hash['contract'] = 'Prepaid'
              ind = contract_details.split.index 'Days'
              data_hash['contract_duration'] = contract_details.split[0..ind].join(" ")
            end

            data_hash['promotions'] = get_values(page , 'Current Deal').split.join(' ').gsub('Discount offer: ', '')
            if data_hash["promotions"].include? 'Download speeds up to'
              data_hash['download'] = data_hash['promotions'].split('Download speeds up to')[-1].split[0]
              data_hash['upload'] = data_hash['promotions'].split('upload speeds up to')[-1].split[0]
              data_hash['peak_download_speed'] = data_hash['download']
            else
              data_hash['upload'] = ''
              data_hash['peak_download_speed'] = ''
            end

            data_hash["is_on_promotion"] = data_hash["promotions"] == "" ? "No" : "Yes"

            data_hash["price_details"] = page.css('div[class="text-center mar-x-2"]').css('strong').text + " " + page.css('div[class="text-center mar-x-2"]').css('div[class="font-4 mar-y-2"]').text.strip.split.join(' ') rescue '-'
            
            unless (data_hash['recharge_period'].downcase.include? 'day') || (data_hash['recharge_period'].downcase.include? 'month')
              if (data_hash['price_details'].downcase.include? 'day') || (data_hash['price_details'].downcase.include? 'month')
                data_hash['recharge_period'] = "Per #{data_hash['price_details'].split('Per').last.strip}"
              else
                data_hash['recharge_period'] = get_values(page, 'Type').text.split(' ')[0..-2].join(' ')
              end
            end

            data_hash["minimum_total_cost"] = page.css('div[class="text-center mar-x-2"]').css('div[class="font-3"]').text.strip.split.join(' ')
            data_hash['minimum_total_cost'] = data_hash["minimum_total_cost"].split.select{|e| e.include? '$'}[0]
            if data_hash['is_on_promotion'] == 'Yes'
              if data_hash['promotions'].include? 'Enjoy' and data_hash['promotions'].include? 'off this'
                data_hash["discounted_price"] = data_hash['price']
                data_hash["price"] = data_hash["promotions"].split.select{|e| e.include? '/'}[0].gsub('/mth.','')
              elsif data_hash["promotions"].downcase.include? 'special price'
                data_hash["discounted_price"] = data_hash['price']
                data_hash["price"] = data_hash["promotions"].split('Special Price')[-1].split.select{|e| e.include? '$'}.max
              elsif  data_hash['promotions'].scan(/for the first \d+ months/).count > 0 && (data_hash['promotions'].include? data_hash['price'])
                arr = data_hash['promotions'].scan(/for the first \d+ months/)
                ind = data_hash['promotions'].index arr[0]
                data_hash['discounted_price'] = data_hash['promotions'][0..ind].split.select{|e| e.include? '$'}[0].gsub('/mth','')
                new_ind = data_hash['promotions'].index arr[1]
                data_hash['price'] = data_hash['promotions'][ind..new_ind].split.select{|e| e.include? '$'}[0].gsub('/mth','')
              else
                data_hash["discounted_price"] = ''
              end
            else
              data_hash["discounted_price"] = ''
            end

            if data_hash["discounted_price"] != "" && data_hash["discounted_price"] != nil
              if !data_hash["discounted_price"].include? '$'
                data_hash["discounted_price"] = "$ "+ data_hash["discounted_price"]
              end
            end

            if data_hash["discounted_price"] != "" and data_hash["promotions"].include? 'month'
              if data_hash["promotions"].downcase.include? 'first month'
                data_hash["discounted_period"] = 'first month'
              elsif data_hash["promotions"].scan(/first \d+ month/).count > 0
                data_hash["discounted_period"] = data_hash["promotions"].scan(/first \d+ month/)[0]
              elsif data_hash["promotions"].scan(/up to \d+ month/).count > 0
                data_hash["discounted_period"] = data_hash["promotions"].data_hash["promotions"].scan(/up to \d+ month/)[0]
              elsif data_hash["promotions"].scan(/\d+-month/).count > 0
                data_hash["discounted_period"] = data_hash["promotions"].scan(/\d+-month/)[0]
              end
            end


            all_options = page.css('div#modems').css('div[class="[ row ] [ pad-y-3 bor-b-1 ]"]')
            options_array = []
            all_options.each do |option|
              option_hash = {}
              option_hash['description'] = option.css('h4').text
              option_hash['device'] = option.css('div[class="text-muted font-3 mar-y-2"]').text.strip
              option_hash['price'] = option.css('div[class="font-700"]').text.strip.gsub("\r\n","").split.join(" ")
              options_array << option_hash
            end

            data_hash['modem_postage'] = options_array[0]['price']
            if data_hash["modem_postage"] != "" and data_hash["modem_postage"] != nil
              if !data_hash["modem_postage"].include? '$'
                data_hash["modem_postage"] = "$ "+data_hash["modem_postage"]
              end
            end
            
            data_hash['modem_fee'] = options_array[-1]['price']
            data_hash['modem_description'] = options_array[-1]['device']
            data_hash['byo_modem'] = "BYO Modem" if data_hash['modem_description'].include? "BYO"


            data_hash['landline'] = features_array.select{|e| (e.downcase.include? 'calls') || (e.downcase.include? 'phone ')}.join(' \n ')

            data_hash['mobile']   = features_array.select{|e| e.upcase.include? 'mobile'.upcase}.count != 0 ? features_array.select{|e| e.upcase.include? 'mobile'.upcase}.join("\n") : ""

            if data_hash['landline'].present?
              data_hash['bundled_landline'] = ((data_hash['landline'].include? '$') || (data_hash['landline'].include? 'pay ')) ? 'AddOn' : 'Included'
            end

            if data_hash['mobile'].present?
              data_hash['bundled_mobile'] = ((data_hash['mobile'].include? '$')  || (data_hash['mobile'].include? 'pay ')) ? 'AddOn' : 'Included'
            end

            if data_hash["connection_type"].include? 'Mobile Broadband'
              if features_array.join(" ").split.select{|e| e == '4G' or e== '5G' or e=='3G'}.count > 0
                data_hash['connection_technology'] = features_array.join(" ").split.select{|e| e == '4G' or e== '5G' or e=='3G'}.join(" ")
              end
            end

            data_hash["source_url"] = complete_link
            data_hash["is_visited"] = true
            data_hash = udpate_nil_to_empty(data_hash)

            search_data_hash[:provider_id] =    data_hash["provider_id"]
            search_data_hash[:contract]    =    data_hash['contract']
            search_data_hash[:plan_name]   =    data_hash["plan_name"]

            record = AustraliaInternetPlan.find_by({plan_name: data_hash["plan_name"], provider_id: data_hash["provider_id"]})

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
          counter = 20 + counter
          response = agent.get("https://www.whistleout.com.au/Ajax/Broadband/SearchResults/PagedResults?tab=#{tab}&supplier=Tangerine-Telecom,SpinTel,Telstra,Superloop,TPG,Aussie-Broadband,iiNet,Optus,Dodo,Internode,MyRepublic,Vodafone,SkyMesh,Exetel,Kogan-Internet,Mate,Belong,Activ8me,iPrimus,Southern-Phone,ALDImobile,Moose-Mobile,IPSTAR,amaysim,Kogan-Mobile,Lebara-Mobile&customer=#{type}&current=#{counter}")
          pp = Nokogiri::HTML(response.body)
          page_number += 1
        end
      end
    end
    AustraliaInternetPlan.where("source_url LIKE (?)", "https://www.whistleout.com.au%").where(is_visited: false).update_all(is_deleted: true)
    # hash_array = hash_array.uniq
  end
end

# ob = Whistleout.new
# ob.scraper()

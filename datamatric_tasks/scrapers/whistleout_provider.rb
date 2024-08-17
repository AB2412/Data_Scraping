require 'net/http'
require 'nokogiri'
require 'json'
require 'byebug'
require 'mechanize'

class WhistleoutProvider

	def get_value(buttons, value)
		values = buttons.select{|e| e.text.include? value}
		if !values.empty?
			return values[0].css('b')[0].text + " " + values[0].css('span')[-1].text.strip
		else
			return  ''
		end
	end

	def mobile_phones(agent)
		url = 'https://www.whistleout.com.au/MobilePhones/Carriers'
		puts "Processing URL --------> #{url}"
    hash_array = []
		response = agent.get(url)
		pp = Nokogiri::HTML(response.body)
		total_plans = pp.css("#tab-personal").css('div[class="[ row ] [ mar-y-3  pad-y-3  sep-b-1  bor-b-1  bor-b-5-xs  position-relative ]"]')
		total_plans.each_with_index do |plan, index|
			data_hash = {}
			data_hash['brand'] = plan.css('h2').text.strip
			buttons = plan.css('div[class="[ col-xs-12 ] [ pad-x-4 ] [ position-static ] [ text-center ]"]')
			data_hash['number_of_mobile_plans'] = get_value(buttons, 'Plans')
			data_hash['number_of_phones'] = get_value(buttons, 'Phones')

			hash_array << data_hash
		end
		hash_array = hash_array.uniq
	end

	def internet(agent)
		url = 'https://www.whistleout.com.au/Broadband/Providers'
		puts "Processing URL --------> #{url}"
    hash_array = []
		response = agent.get(url)
		pp = Nokogiri::HTML(response.body)
		total_plans = pp.css("#tab-personal").css('div[class="[ row ] [ mar-y-3  pad-y-3  sep-b-1  bor-b-1  bor-b-5-xs  position-relative ]"]')
		total_plans.each_with_index do |plan, index|
			data_hash = {}
			
			data_hash['brand'] = plan.css('h2').text.strip
			buttons = plan.css('div[class="[ col-xs-24 ] [ pad-x-4 ] [ position-static ] [ text-center ]"]')
			data_hash['number_of_internet_plans'] = get_value(buttons, 'Plans')
			data_hash['plan_types'] = plan.css('div.pad-t-4').map{|e| e.css('a').map(&:text)}.flatten.join(', ')
			
			hash_array << data_hash
		end
		hash_array = hash_array.uniq
	end

	def get_brand(array, element)
    sub_string = array.select{|s| element.upcase.include? s.upcase}
    sub_string_1 = array.select{|s| element.split.join.upcase.include? s.split.join.upcase}
    matched_elements = array.select{|s| s.split.join.upcase.include? element.split.join.upcase }
    matched_elements.count > 0 ? matched_elements.first : sub_string.count > 0 ? sub_string.first : sub_string_1.count > 0 ? sub_string_1.first : false
  end

	def scraper()
		agent = Mechanize.new
		agent.user_agent_alias = "Windows Mozilla"
		agent.set_proxy(ENV['PROXY_HOST'], ENV['PROXY_PORT'], "#{ENV['PROXY_USER']}:#{ENV['PROXY_PASSWORD']}")
    country_id = Country.find_by(name: 'Australia')['id']
		agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    all_brands = ["10Mates", "Accord", "Activ8me", "AGL", "ALDImobile", "amaysim", "ANT Communications", "Aussie Broadband", "Australia Broadband", "Belong", "Bendigo Telco", "Better Life", "Boost Mobile", "Catch Connect", "Circles.Life", "Clear Networks", "Click Broadband", "Cmobile", "Coles Mobile", "Commander", "dodo", "Exetel", "felix Mobile", "Flip", "Foxtel", "Future Broadband", "Fuzenet", "gomo", "Goodtel", "gotalk Mobile", "Harbour ISP", "Hello Mobile", "iiNet", "Infinity", "Inspired Broadband", "Internode", "iPrimus", "IPSTAR", "JB Hi-Fi", "Kogan", "Lebara", "Logitel", "Lycamobile", "Mate", "Mint Telecom", "Moose Mobile", "More telecom", "MyNetFone", "MyRepublic", "Nextalk", "numobile", "Optus", "Origin", "Pennytel", "Reachnet", "Reward", "SkyMesh", "Southern Phone", "SpinTel", "Start Broadband", "Superloop", "Swoop Broadband", "Tangerine Telecom", "TeleChoice", "Telstra", "Think Mobile", "Tomi", "TPG", "Uniti", "Vaya", "Vodafone", "Westnet", "Woolworths", "Yomojo", "Zero"]
		excluded_providers = ["amaysim", "Lebara", "Optus", "Southern Phone", "Telstra", "TPG", "Vodafone"]
		mobie_providers = mobile_phones(agent)
		internet_providers = internet(agent)
		total_brands = all_brands + excluded_providers

    mobie_providers.each do |provider|
    	provider_name = provider['brand']
    	provider_name_check = total_brands.select{|e| e.upcase.include? provider_name.upcase}
    	if !provider_name_check.empty?
      	provider['brand'] = provider_name_check[0]
    	elsif get_brand(total_brands, provider_name)
      	provider['brand'] = get_brand(total_brands, provider_name)
    	else
      	provider['brand'] = provider_name
    	end

	    provider_record = Provider.find_by(name: provider['brand'], country_id: country_id)
	    if provider_record
	      provider_record.update(number_of_mobile_plans: provider['number_of_mobile_plans'], number_of_phones: provider['number_of_phones'])
	    else
	      byebug
	      puts 'check adeel'
	    end
		end

    internet_providers.each do |provider|
    	provider_name = provider['brand']
    	provider_name_check = total_brands.select{|e| e.upcase.include? provider_name.upcase}
    	if !provider_name_check.empty?
      	provider['brand'] = provider_name_check[0]
    	elsif get_brand(total_brands, provider_name)
      	provider['brand'] = get_brand(total_brands, provider_name)
    	else
      	provider['brand'] = provider_name
    	end
      provider_record = Provider.find_by(name: provider['brand'], country_id: country_id)
      if provider_record
        provider_record.update(number_of_internet_plans: provider['number_of_internet_plans'], plan_types: provider['plan_types'])
      else
        byebug
        puts 'check adeel'
      end
    end
	end
end

# ob = WhistleoutProvider.new
# ob.scraper()
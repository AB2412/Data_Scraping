require 'mechanize'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE


class MobileMonster

  def create_md5_hash(data_hash)
    data_string = ''
    data_hash.values.each do |val|
      data_string += val.to_s
    end
    Digest::MD5.hexdigest(data_string)
  end

  def create_hash(make, model, storage, price, gradeArray, url)
    data_hash = {}
    data_hash[:retailers] = 'MobileMonster'
    data_hash[:make] = make
    data_hash[:model] = model
    data_hash[:storage] = storage
    data_hash[:color] = nil
    data_hash[:gradeArray] = gradeArray
    data_hash[:gradeDetails] = nil
    data_hash[:price] = price
    data_hash[:discountedprice] = nil
    data_hash[:link] = url
    data_hash[:md5_hash] = create_md5_hash(data_hash)
    @old_records = @old_records.reject { |e| e == data_hash[:md5_hash] }
    unless @already_inserted_hashes.include?(data_hash[:md5_hash])
      @already_inserted_hashes << data_hash.delete(:md5_hash)
      data_hash[:discountedPercentage] = nil
      data_hash[:currency] = 'USD'
      data_hash[:features] = nil
      data_hash[:is_visited] = true
      data_hash[:is_deleted] = false
      data_hash[:lastseen] = Time.now
      Buyback.create(data_hash)
    end
  end

  def create_grade_array(phone_model_body, dead_phone_price, working_price)
    device_id = phone_model_body.css('#hks-BubbleTableId').text
    url = "https://portal.mobilemonster.com.au//api/1.1/wf/get_faults_data?device_id=#{device_id}"
          #  https://portal.mobilemonster.com.au//api/1.1/wf/get_faults_data?device_id=1639405748646x276849622988063040
    response = @agent.get(url)
    response.body.gsub("\"", '').gsub('\\n', '').gsub("\\", '').split('[')[1].split(']')[0]
  end

  def scraper
    @already_inserted_hashes = Buyback.where("retailers = 'MobileMonster'").pluck(:md5_hash)
    @old_records = @already_inserted_hashes.clone
    Buyback.where(retailers: 'MobileMonster').update_all('is_visited': false)
    @agent = Mechanize.new
    # @agent.set_proxy(ENV['PROXY_HOST'], ENV['PROXY_PORT'], "#{ENV['PROXY_USER']}:#{ENV['PROXY_PASSWORD']}")
    response = @agent.get("https://mobilemonster.com.au/sell-your-phone")
    cookie = response.header['set-cookie']
    body = Nokogiri::HTML(response.body)
    brand_links = body.css(".collection-item-8").map { |e| 'https://mobilemonster.com.au' + e.css('a')[0]['href'] }
    brand_links.each do |brand_url|
      brand_response = @agent.get(brand_url)
      brand_body = Nokogiri::HTML(brand_response.body)
      phone_links = brand_body.css('#phones-section div.collection-model').map { |e| 'https://mobilemonster.com.au' + e.css('a')[0]['href'] }
      phone_links.each do |phone_url|
        phone_response = @agent.get(phone_url)
        phone_body = Nokogiri::HTML(phone_response.body)
        phone_model_links = phone_body.css('div.collection-list-wrapper-17 div.w-dyn-item').map { |e| 'https://mobilemonster.com.au' + e.css('a')[0]['href'] }
        phone_model_links.each do |phone_model_url|
          puts '====================================================================================================='
          puts phone_model_url
          puts '===================================================================================================='
          phone_model_response = @agent.get(phone_model_url)
          phone_model_body = Nokogiri::HTML(phone_model_response.body)
          general_info = phone_model_body.css('#DisplayName').text
          make = general_info.split('|')[0].squish rescue nil
          model = general_info.split('|')[1].squish  rescue nil
          storage = general_info.split('|')[2].squish  rescue nil
          dead_phone_price = phone_model_body.css('#hks-DeadPrice').text
          new_price = phone_model_body.css('#NewPricing').text
          working_price = phone_model_body.css('#per_unit_final_pricing').text
          gradeArray = create_grade_array(phone_model_body, dead_phone_price, working_price)
          create_hash(make, model, storage, dead_phone_price, [], phone_model_url)
          create_hash(make, model, storage, new_price, [], phone_model_url)
          create_hash(make, model, storage, working_price, gradeArray, phone_model_url)
        end
      end
    end
    Buyback.where(retailers: 'MobileMonster', md5_hash: @old_records).update_all(is_deleted: true)
  end
end
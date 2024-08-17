class MauzmaMobileBuyback
  MAIN_URL = "https://www.mazumamobile.com.au"

  def scrape
    @url = "https://www.mazumamobile.com.au/sell-my-mobile"
    @agent = Mechanize.new
    @agent.set_proxy(ENV['PROXY_HOST'], ENV['PROXY_PORT'], "#{ENV['PROXY_USER']}:#{ENV['PROXY_PASSWORD']}")
    main_page = @agent.get(@url)
    @already_inserted_hashes = Buyback.where("retailers = 'Mazuma'").pluck(:md5_hash)
    @old_records = @already_inserted_hashes.clone
    # total_pages = main_page.css("#tiledManufacturers a").map{ |a| brands(a["href"].split("/").last) }
    total_pages = main_page.css("#popularModelTypes a").map{ |a| brands(a["href"].split("/").last) }
    Buyback.where(retailers:'Mazuma', md5_hash: @old_records).update_all(is_deleted: true)
  end

  def has_storage(str)
    if(str == nil)
      return 0;
    elsif(str.include? "GB" or str.include? "TB" )
      return str.count("0-9")
    else
      return 0
    end
  end

  def brands(brand)
    # byebug
    # brand_url = @url +"/"+brand+"/phones/"
    brand_url = "https://www.mazumamobile.com.au/" + brand
    page = @agent.get(brand_url)
    page.css('div.storage a').map{|a| main_page(a["href"])}
  end

  def main_page(url)
    # byebug
    page_url = MAIN_URL + url
    page = @agent.get(page_url)
    get_data(page, page_url)
  end

  def get_grade_array(condition)
    grade = {"condition" => nil}
    grade["condition"] = condition
    return grade
  end
  
  def create_md5_hash(data_hash)
    data_string = ''
    data_hash.values.each do |val|
      data_string += val.to_s
    end
    Digest::MD5.hexdigest data_string
  end

  def get_data(data, url)
    puts url
    data_hash = {}
    storage = (has_storage(data.css('h1').text.split(" ").last) > 0) ? data.css('h1').text.split(" ").last : ""
    data.css("#conditions-tabs ul li a").each do |k|
      data_hash = {}
      data_hash[:retailers] = "Mazuma"
      data_hash[:make] = data.css('h1').text.split(" ").first
      data_hash[:model] = data.css('h1').text.split(" ")[1..-1].join(" ").gsub(storage, "").split('-')[0]
      data_hash[:storage] = storage.split(")").last
      data_hash[:color] = nil
      data_hash[:gradeArray]= get_grade_array(k.values.last).to_s
      data_hash[:gradeDetails] = nil
      data_hash[:price] = k.values.first
      data_hash[:discountedprice] = nil
      data_hash[:link] = url
      data_hash[:md5_hash] = create_md5_hash(data_hash)
      @old_records = @old_records.reject { |e| e == data_hash[:md5_hash] }
      next if @already_inserted_hashes.include? data_hash[:md5_hash]
      @already_inserted_hashes << data_hash.delete(:md5_hash)
      data_hash[:discountedPercentage] = nil
      data_hash[:currency] = "AUD"
      data_hash[:features] = nil
      data_hash[:is_visited] = true
      data_hash[:is_deleted] = false
      data_hash[:lastseen] = Time.now
      Buyback.create(data_hash)
    end
  end
end
    
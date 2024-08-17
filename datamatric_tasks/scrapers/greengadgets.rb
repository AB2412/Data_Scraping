
class Greengadgets
  def initialize
    super
    @DOMAIN = 'https://shop.greengadgets.net.au'
  end

  def create_md5_hash(data_hash)
    data_string = ''
    data_hash.values.each do |val|
      data_string += val.to_s
    end
    Digest::MD5.hexdigest data_string
  end
  
  def cat_request(cat,page)
    uri = URI.parse("https://shop.greengadgets.net.au/collections/#{cat}?page=#{page.to_s}")
    @agent.get(uri)
    # puts uri
    # request = Net::HTTP::Get.new(uri)
    # request["Authority"] = "shop.greengadgets.net.au"
    # request["Sec-Ch-Ua"] = "\"Google Chrome\";v=\"95\", \"Chromium\";v=\"95\", \";Not A Brand\";v=\"99\""
    # request["Sec-Ch-Ua-Mobile"] = "?0"
    # request["Sec-Ch-Ua-Platform"] = "\"Linux\""
    # request["Upgrade-Insecure-Requests"] = "1"
    # request["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36"
    # request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
    # request["Sec-Fetch-Site"] = "same-origin"
    # request["Sec-Fetch-Mode"] = "navigate"
    # request["Sec-Fetch-User"] = "?1"
    # request["Sec-Fetch-Dest"] = "document"
    # request["Referer"] = "https://shop.greengadgets.net.au/collections/apple?page=2"
    # request["Accept-Language"] = "en-US,en;q=0.9"
    # req_options = {
    #   use_ssl: uri.scheme == "https",
    # }
    # response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    #   http.request(request)
    # end
  end

  def inner_request(link)
    @agent.get(link)
    # uri = URI.parse(link)
    # request = Net::HTTP::Get.new(uri)
    # request["Authority"] = "shop.greengadgets.net.au"
    # request["Sec-Ch-Ua"] = "\"Google Chrome\";v=\"95\", \"Chromium\";v=\"95\", \";Not A Brand\";v=\"99\""
    # request["Sec-Ch-Ua-Mobile"] = "?0"
    # request["Sec-Ch-Ua-Platform"] = "\"Linux\""
    # request["Upgrade-Insecure-Requests"] = "1"
    # request["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36"
    # request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
    # request["Sec-Fetch-Site"] = "none"
    # request["Sec-Fetch-Mode"] = "navigate"
    # request["Sec-Fetch-User"] = "?1"
    # request["Sec-Fetch-Dest"] = "document"
    # request["Accept-Language"] = "en-US,en;q=0.9"

    # req_options = {
    #   use_ssl: uri.scheme == "https",
    # }

    # response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    #   http.request(request)
    # end
  end
  
  def process_links(links)
    links.each do |link|
      link = link.gsub("/collections/samsung","")
      # response = inner_request(link)
      response = @agent.get(link)
      document = Nokogiri::HTML(response.body)
      # next if document.text.include? ''
      make = document.css(".product-meta__title.heading.h1").first.text.split[0].strip
      model =  document.css(".product-meta__title.heading.h1").first.text.split("(").first.split[1..-1].join(" ").strip
      model = model.split("|").first.strip
      main_condition = document.css(".product-meta__title.heading.h1").first.text.split("(").last.gsub(")","").strip
      options = document.css("select[id*='product-select-'] option")
      options.each do |option|
        instock = 'yes'
        instock = 'no' if option['disabled'] == "disabled"
        variant = option["value"]
        link = link.split('?variant=')[0]
        v_link = link + "?variant=" + variant
        puts v_link
        next if @already_inserted_links.include? v_link
        response = inner_request(v_link)
        document = Nokogiri::HTML(response.body)
        prices = document.css("div.price-list > span")
        if prices.count == 2
          price = document.css("div.price-list > span.price.price--compare").first.text.split("$").last
          discountPrice = document.css("div.price-list > span.price.price--highlight").first.text.split("$").last
        elsif prices.count == 1
          dsicountPrice = nil
          price = document.css("div.price-list > span").first.text.split("$").last
        else
         
          # puts "see no price"
        end
        if price.nil? or price.empty?
          price = (option.text.split('-').last.include? '$') ?  option.text.split('-').last.strip : price
        end
        option = option.text.strip
        grade = option.split("/").last.split("-").first.strip
        make = make.capitalize
        make = "Google" if make == "Google-pixel"
        data_hash = {}
        data_hash = {
          retailers: 'greengadgets',
          make:make,
          model: model,
          storage: option.split("/").first.strip,
          colour: option.split("/")[1].strip.split("-")[0],
          grade: grade,
          mainCondition: main_condition,
          inStock: instock,
          price: price,
          discount_price: discountPrice,
          link: v_link
        }
        data_hash[:md5_hash] = create_md5_hash(data_hash)
        puts data_hash
        @old_records = @old_records.reject {|e| e == data_hash[:md5_hash]}
        next if @already_inserted_hashes.include? data_hash[:md5_hash]
        @already_inserted_hashes << data_hash.delete(:md5_hash)
        data_hash[:shippingcost] = nil
        data_hash[:currency]  =  'AUD'
        data_hash[:is_visited] = true
        data_hash[:is_deleted] = false
        data_hash[:lastseen] =Time.now
        Retailer.create(data_hash)
      end
    end
  end
 
  def scraper
    @agent = Mechanize.new
    @agent.set_proxy('zproxy.lum-superproxy.io','22225', 'brd-customer-hl_b9c73d95-zone-businessprofiles','apx2ojz8d16p')

    @already_inserted_hashes = Retailer.where("retailers = 'greengadgets'").pluck(:md5_hash)
    @already_inserted_links = Retailer.where("retailers = 'greengadgets'").pluck(:link)

    @old_records = @already_inserted_hashes.clone
    data_array = []
    header_flag = false
    phone_categories = ['samsung','google-pixel','apple', 'smartphones']
    phone_categories.each do |cat|
      page = 1
      while true
        cat_url = "https://shop.greengadgets.net.au/collections/#{cat}?page=#{page.to_s}"
        response = @agent.get(cat_url)

        document = Nokogiri::HTML(response.body)
        mobile_links = document.css(".product-item.product-item--vertical > a").map{|e| @DOMAIN + e['href']} rescue []
        break if mobile_links.empty?
        process_links(mobile_links)
        page += 1
      end
    end
    Retailer.where(retailers:'greengadgets', md5_hash: @old_records).update_all(is_deleted: true)
  end
end


class DecluttrMobileOld
  
  def proxy(link)
   agent = Mechanize.new
   agent.user_agent_alias = "Windows Mozilla"
   agent.set_proxy(ENV['PROXY_HOST'], ENV['PROXY_PORT'], "#{ENV['PROXY_USER']}:#{ENV['PROXY_PASSWORD']}")
   agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
   return  agent.get(link)
  end

  def has_storage(str)
   str=str.gsub(/[()]/, "")
   str=str.upcase
   if(str==nil)
    return 0;
   elsif(str.include? "GB" or str.include? "TB" )
    return str.count("0-9")
   else
    return 0 
   end 
  end

  def visit_url(url , retries = 5)
   begin
    @agent = Mechanize.new
    page = @agent.get(url)
    rescue Exception => e
    puts "----------#{e}"
    if retries <= 1
     raise
    end
    visit_url(url , retries - 1)
   end
  end

  def parse_data(link,brand)
   data_array = []
   url="https://www.decluttr.com"
   link=url+link
   page = visit_url(link)
   sleep(3)
   phone_id=link.split("=")[-1]
   if(page==nil)
    page=proxy(link)
   end

   if page.css("ul.mobile-networks li a[title='Unlocked']").empty?
    return nil
   else
    network_id=page.css("ul.mobile-networks li a[title='Unlocked']")[0]["data-networkid"]
   end

   name=page.css("h1.desktop-header").text.split("\n")[1]
   storage=nil;
   test_name=name.split(" ")
   model=nil

   if(test_name.length>1)
    str=name.split.last.strip
   else
    str=nil
   end
   
   if(has_storage(str)>0)
    storage=name.split.last.strip
    model=name.split(storage)
    model=model[0]
    storage=storage.delete"()"
   else
    model=name
   end
   i=0
   while(i<3)
    url="https://www.decluttr.com/Umbraco/Surface/Products/GetProductPrices?barcode=#{phone_id}&networkId=#{network_id}&website=decluttr"
    page = @agent.get(url)
    data=JSON.parse(page.body)
    condition=nil;
    price=nil;
    if(i==0)
     price=data["faulty"]
     condition="faulty"
    elsif(i==1)
     price=data["poor"]
     condition="poor"
    elsif(i==2)
     price=data["good"]
     condition="good"
    end
    i+=1
    require_make=["Apple", "Google", "Huawei", "Microsoft", "Motorola", "Nokia",  "OPPO", "Samsung","Sony"]
    data_hash = {}
    data_hash[:retailers] = "Decluttr"
    data_hash[:make] =brand
    data_hash[:model] =model.strip
    data_hash[:storage] =storage
    data_hash[:color] = nil
    data_hash[:gradeArray]=get_grade_array(condition).to_s
    data_hash[:gradeDetails] =nil
    data_hash[:price] = price
    data_hash[:discountedprice] = nil
    data_hash[:discountedPercentage] = nil
    data_hash[:currency] = "USD"
    data_hash[:features] = nil
    data_hash[:link] = link
    data_hash[:is_visited] = true
    data_hash[:is_deleted] = false
    search_hash={}
    search_hash[:retailers] = "Decluttr"
    search_hash[:make] =brand
    search_hash[:model] =model.strip
    search_hash[:storage] =storage
    search_hash[:gradeArray]=data_hash[:gradeArray].to_s
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

  def get_grade_array(condition)
   grade = {"condition" => nil}
   grade["condition"] = condition
   return grade
  end

  def phone_per_brand(link,brand)
   url="https://www.decluttr.com/"
   link=url+link
   @agent = Mechanize.new
   page = @agent.get(link)
   total_phone_count=page.css("div.products-grid .row")[0].css("div.grid-item").count
   i=0
   while(i<total_phone_count)
    link_count=page.css("div.products-grid .row")[0].css("div.grid-item")[i].css("div.grid-item-options a").count
    j=0
     while(j<link_count)
      link=page.css("div.products-grid .row")[0].css("div.grid-item")[i].css("div.grid-item-options a")[j]["href"]
      parse_data(link,brand)
      j+=1
     end
    i+=1
   end
  end

  def samsung_series_brand(link,brand)
   url="https://www.decluttr.com/"
   link=url+link
   @agent = Mechanize.new
   page = @agent.get(link)
   total_series_count=page.css("div.products-grid .row")[0].css("div.grid-item").count
   i=0
   while(i<total_series_count)
    link=page.css("div.products-grid .justify-content-center div.grid-item-options a")[i]['href']
    phone_per_brand(link,brand)
    i+=1
   end
  end

  def scraper()
   Buyback.where(retailers:"Decluttr").update_all('is_visited': false)
   url="https://www.decluttr.com/sell-my-cell-phone/"
   @agent = Mechanize.new
   page = @agent.get(url)
   total_brand_count=page.css("div.products-grid .justify-content-center div.grid-item-options a").count
   i=0
   while(i<10)
    brand=page.css("div.products-grid .justify-content-center div.grid-item-options a")[i].text
    brand=brand.split(" ")[1]
    if(brand=="iPhones")
     brand="Apple"
    end
    if(brand=="Samsung")
     link=page.css("div.products-grid .justify-content-center div.grid-item-options a")[i]['href']
     samsung_series_brand(link,brand)
    end
    link=page.css("div.products-grid .justify-content-center div.grid-item-options a")[i]['href']
    phone_per_brand(link,brand)
    i+=1
   end
   Buyback.where(retailers:'Decluttr', is_visited: false).update_all(is_deleted: true)
  end
 end
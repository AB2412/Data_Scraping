class GazelleMobileBuybackold

  def cookie_request
   uri = URI.parse("https://www.gazelle.com/")
   request = Net::HTTP::Get.new(uri)
   request.content_type = "text/plain;charset=UTF-8"
   request["Connection"] = "keep-alive"
   request["Cache-Control"] = "max-age=0"
   request["Sec-Ch-Ua"] = "\" Not;A Brand\";v=\"99\", \"Google Chrome\";v=\"97\", \"Chromium\";v=\"97\""
   request["Sec-Ch-Ua-Mobile"] = "?0"
   request["Sec-Ch-Ua-Platform"] = "\"Linux\""
   request["Upgrade-Insecure-Requests"] = "1"
   request["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.99 Safari/537.36"
   request["Accept"] = "image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8"
   request["Sec-Fetch-Site"] = "cross-site"
   request["Sec-Fetch-Mode"] = "no-cors"
   request["Sec-Fetch-User"] = "?1"
   request["Sec-Fetch-Dest"] = "image"
   request["Referer"] = "https://www.gazelle.com/"
   request["Accept-Language"] = "en-US,en;q=0.9,ur;q=0.8"
   request["Cookie"] = "_swnid=5gvra1uim0zh; _swauth=n"
   request["If-None-Match"] = "W/\"5eb63415fb79ff32f0e4eeed1ec94b1e\""
   request["Authority"] = "px.spiceworks.com"
   request["Origin"] = "https://www.gazelle.com"
   request["Intervention"] = "<https://www.chromestatus.com/feature/5718547946799104>; level=\"warning\""
   request["X-Client-Data"] = "CIa2yQEIorbJAQipncoBCNGgygEInvnLAQi1/8sBCOaEzAEYjp7LAQ=="
   req_options = {
     use_ssl: uri.scheme == "https",
   }
   response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
     http.request(request)
   end
  end

  def selectcompany(cookie)
   uri = URI.parse("https://www.gazelle.com/sell/cell-phone")
   request = Net::HTTP::Get.new(uri)
   request["Connection"] = "keep-alive"
   request["Cache-Control"] = "max-age=0"
   request["Sec-Ch-Ua"] = "\" Not;A Brand\";v=\"99\", \"Google Chrome\";v=\"97\", \"Chromium\";v=\"97\""
   request["Sec-Ch-Ua-Mobile"] = "?0"
   request["Sec-Ch-Ua-Platform"] = "\"Linux\""
   request["Upgrade-Insecure-Requests"] = "1"
   request["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.99 Safari/537.36"
   request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
   request["Sec-Fetch-Site"] = "same-origin"
   request["Sec-Fetch-Mode"] = "navigate"
   request["Sec-Fetch-User"] = "?1"
   request["Sec-Fetch-Dest"] = "document"
   request["Referer"] = "https://www.google.com/"
   request["Accept-Language"] = "en-US,en;q=0.9,ur;q=0.8"
   request["Cookie"] = cookie
   request["If-None-Match"] = "W/\"21496ed26ebe0db68b43ac75ea226047\""
   req_options = {
     use_ssl: uri.scheme == "https",
   }
   response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
     http.request(request)
   end
  end

  def iphone_select()
   @agent = Mechanize.new
   @agent.user_agent_alias = "Windows Mozilla"
   @agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
   document = @agent.get("https://www.gazelle.com/iphone")
   total_count=document.css("div.transition-container li").count
   links=document.css("div.transition-container li").children.map { |link| link['href'] }
   i=0
   url="https://www.gazelle.com"
   while(i<total_count)
    select_carrier(url+links[i],url)
    i+=1
   end
  end

  def otherphone_select(name)
   url="https://www.gazelle.com"
   @agent = Mechanize.new
   @agent.user_agent_alias = "Windows Mozilla"
   @agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
   document = @agent.get("https://www.gazelle.com/sell/cell-phone/#{name}/unlocked")
   link=document.css("li.item-unlocked a")[0]['href']
   page=@agent.get(url+link)
   count=page.css("ul.products li").count
   links=page.css("ul.products  li  a.btn-orange").map { |link| link['href']}
   i=0;
   while(i<links.length)
    if(name=='google'&&i<4)
      pixel_phone(url+links[i],1)
      pixel_phone(url+links[i],2)
      pixel_phone(url+links[i],3)
    else
      otherphone_mainpage(url+links[i],1)
      otherphone_mainpage(url+links[i],2)
      otherphone_mainpage(url+links[i],3)
    end
    i+=1
   end
  end

  def select_carrier(link,url)
   @agent = Mechanize.new
   @agent.user_agent_alias = "Windows Mozilla"
   @agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
   document = @agent.get(link)
   link=document.css("li.item-unlocked a")[0]['href']
   page=@agent.get(url+link)
   count=page.css("ul.products li").count
   links=page.css("ul.products  li  a.btn-orange").map { |link| link['href'] }
   i=0;
   
   while(i<links.length)
    iphone_mainpage(url+links[i],1)
    iphone_mainpage(url+links[i],2)
    iphone_mainpage(url+links[i],3,)
    i+=1
   end
  end

  def pixel_phone(url,k)
   power=nil
   function=nil
   if(k==1)
    power=combination_one()[0]
    function=combination_one()[1]
   elsif(k==2)
    power=combination_two()[0]
    function=combination_two()[1]
   elsif(k==3)
    power=combination_three()[0]
    function=combination_three()[1]
   end
   @agent = Mechanize.new
   id=url.split("/")
   id=id[-1].delete("^0-9")
   document = @agent.get(url)
   test=document.css("#body_container .js-react-on-rails-component")[0]
   data=JSON.parse(test)
   power_on_id=data['initState']['questions'][0]['id']
   function_id=data['initState']['questions'][2]['id']
   carier=data['initState']['questions'][1]['defaultResponse']
   carier_id=data['initState']['questions'][1]['id']
   killswitch=data['initState']['questions'][3]['defaultResponse']
   killswitch_id=data['initState']['questions'][3]['id']
   call=data['initState']['questions'][4]['defaultResponse']
   call_id=data['initState']['questions'][4]['id']
   condition_id=data['initState']['questions'][5]['id']
   condition_status=data['initState']['questions'][5]['options'][0]['id']
   condition_type=data['initState']['questions'][5]['options'][0]['content']
   if(function=="Yes"&&power=="Yes")
    condition_id=data['initState']['questions'][5]['id']
    poweron=data['initState']['questions'][0]['options'][0]['id']
    power_type=data['initState']['questions'][0]['options'][0]['content']
    function_work=data['initState']['questions'][2]['options'][0]['id']
    function_type=data['initState']['questions'][2]['options'][0]['content']
    i=0
    while(i<4)
     condition_status=data['initState']['questions'][5]['options'][i]['id']
     condition_type=data['initState']['questions'][5]['options'][i]['content']
     i+=1
     data_scrape_pixel(id,call,poweron,carier,function_work,condition_id,condition_status,url,condition_type,function_type,power_type,call_id,power_on_id,carier_id,function_id,killswitch_id,killswitch)
    end
    elsif(power=="Yes"&&function=="No")
     poweron=data['initState']['questions'][0]['options'][0]['id']
     power_type=data['initState']['questions'][0]['options'][0]['content']
     function_work=data['initState']['questions'][2]['options'][1]['id']
     function_type=data['initState']['questions'][2]['options'][1]['content']
     data_scrape_pixel(id,call,poweron,carier,function_work,condition_id,condition_status,url,condition_type,function_type,power_type,call_id,power_on_id,carier_id,function_id,killswitch_id,killswitch)
    elsif(power=="No"&&function=="Yes")
     poweron=data['initState']['questions'][0]['options'][1]['id']
     power_type=data['initState']['questions'][0]['options'][1]['content']
     function_work=data['initState']['questions'][2]['options'][0]['id']
     function_type=data['initState']['questions'][2]['options'][0]['content']
     data_scrape_pixel(id,call,poweron,carier,function_work,condition_id,condition_status,url,condition_type,function_type,power_type,call_id,power_on_id,carier_id,function_id,killswitch_id,killswitch)
    end
  end

  def data_scrape_pixel(id,call,poweron,carier,function_work,condition_id,condition_status,url,condition_type,function_type,power_type,call_id,power_on_id,carier_id,function_id,killswitch_id,killswitch)
   data_array = []
   data_hash = {}
   newurl="https://www.gazelle.com/products/#{id}/calculation.json?product_id=#{id}&calculator_answers%5B#{call_id}%5D=#{call}&calculator_answers%5B#{power_on_id}%5D=#{poweron}&calculator_answers%5B#{carier_id}%5D=#{carier}&calculator_answers%5B#{killswitch_id}%5D=#{killswitch}&calculator_answers%5B#{condition_id}%5D=#{condition_status}&calculator_answers%5B#{function_id}%5D=#{function_work}"
   @agent = Mechanize.new
   json_parse = @agent.get(newurl)
   data=JSON.parse(json_parse.body)
   retailer="Gazelle"
   make=data['product']['brand']
   model=data['product']['model']
   storage=data['product']['size']
   price=data['product']['price']
   colour=data['product']['color']
   gradedetails=
   discountprice=0
   discountpercentage=0
   features=nil
   lastseen=Time.now
   link=url
   isonpromotion="No"
   promotion_text=nil
   data_hash[:retailers] = "Gazelle"
   data_hash[:make] =make
   data_hash[:model] =model
   data_hash[:storage] =storage
   data_hash[:color] = nil
   data_hash[:gradeArray]=get_grade_array(function_type,power_type,condition_type).to_s
   data_hash[:gradeDetails] = get_grade(condition_type)
   data_hash[:price] = data['product']['price']
   data_hash[:discountedprice] = nil
   data_hash[:discountedPercentage] = nil
   data_hash[:currency] = "USD"
   data_hash[:features] = features
   data_hash[:link] = url
   data_hash[:is_visited] = true
   data_hash[:is_deleted] = false
 
   search_hash={}
   search_hash[:retailers] = "Gazelle"
   search_hash[:make] =make
   search_hash[:model] =model
   search_hash[:storage] =storage
   search_hash[:gradeArray]=data_hash[:gradeArray]
   search_hash[:gradeDetails]=data_hash[:gradeDetails]
   record = Buyback.find_by(data_hash)
   search_record = Buyback.find_by(search_hash)
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

  def otherphone_mainpage(url,k)
   @agent = Mechanize.new
   document = @agent.get(url)
   test=document.css("#body_container .js-react-on-rails-component")[0]
   data=JSON.parse(test)
   json_element=data['initState']['questions'].count
   if(json_element>5)
    pixel_phone(url,k)
   else
    power=nil
    function=nil
    if(k==1)
     power=combination_one()[0]
     function=combination_one()[1]
    elsif(k==2)
     power=combination_two()[0]
     function=combination_two()[1]
    elsif(k==3)
     power=combination_three()[0]
     function=combination_three()[1]
   end
    id=url.split("/")
    id=id[-1].delete("^0-9")
    power_on_id=data['initState']['questions'][0]['id']
    function_id=data['initState']['questions'][2]['id']
    carier=data['initState']['questions'][1]['defaultResponse']
    carier_id=data['initState']['questions'][1]['id']
    call=data['initState']['questions'][3]['defaultResponse']
    call_id=data['initState']['questions'][3]['id']
    condition_id=data['initState']['questions'][4]['id']
    condition_status=data['initState']['questions'][4]['options'][0]['id']
    condition_type=data['initState']['questions'][4]['options'][0]['content']
    if(function=="Yes"&&power=="Yes")
     condition_id=data['initState']['questions'][4]['id']
     poweron=data['initState']['questions'][0]['options'][0]['id']
     power_type=data['initState']['questions'][0]['options'][0]['content']
     function_work=data['initState']['questions'][2]['options'][0]['id']
     function_type=data['initState']['questions'][2]['options'][0]['content']
     i=0
     while(i<4)
      condition_status=data['initState']['questions'][4]['options'][i]['id']
      condition_type=data['initState']['questions'][4]['options'][i]['content']
      i+=1
      data_scrape_otherphone(id,call,poweron,carier,function_work,condition_id,condition_status,url,condition_type,function_type,power_type,call_id,power_on_id,carier_id,function_id)
     end
    elsif(power=="Yes"&&function=="No")
     poweron=data['initState']['questions'][0]['options'][0]['id']
     power_type=data['initState']['questions'][0]['options'][0]['content']
     function_work=data['initState']['questions'][2]['options'][1]['id']
     function_type=data['initState']['questions'][2]['options'][1]['content']
     data_scrape_otherphone(id,call,poweron,carier,function_work,condition_id,condition_status,url,condition_type,function_type,power_type,call_id,power_on_id,carier_id,function_id)
    elsif(power=="No"&&function=="Yes")
     poweron=data['initState']['questions'][0]['options'][1]['id']
     power_type=data['initState']['questions'][0]['options'][1]['content']
     function_work=data['initState']['questions'][2]['options'][0]['id']
     function_type=data['initState']['questions'][2]['options'][0]['content']
     data_scrape_otherphone(id,call,poweron,carier,function_work,condition_id,condition_status,url,condition_type,function_type,power_type,call_id,power_on_id,carier_id,function_id)
    end
   end
  end

  def iphone_mainpage(url,k)
   power=nil
   function=nil
   if(k==1)
   power=combination_one()[0]
   function=combination_one()[1]
   elsif(k==2)
   power=combination_two()[0]
   function=combination_two()[1]
   elsif(k==3)
   power=combination_three()[0]
   function=combination_three()[1]
   end
   @agent = Mechanize.new
   id=url.split("/")
   id=id[-1].delete("^0-9")
   document = @agent.get(url)
   test=document.css("#body_container .js-react-on-rails-component")[0]
   data=JSON.parse(test)
   power_on_id=data['initState']['questions'][0]['id']
   function_id=data['initState']['questions'][2]['id']
   carier_id=data['initState']['questions'][1]['id']
   carier=data['initState']['questions'][1]['defaultResponse']
   call_id=data['initState']['questions'][3]['id']
   call=data['initState']['questions'][3]['defaultResponse']
   apple_account=data['initState']['questions'][5]['id']
   appleid=data['initState']['questions'][5]['defaultResponse']
   condition_id=data['initState']['questions'][4]['id']
   condition_status=data['initState']['questions'][4]['options'][0]['id']
   condition_type=data['initState']['questions'][4]['options'][0]['content']
   if(function=="Yes"&&power=="Yes")
    condition_id=data['initState']['questions'][4]['id']
    poweron=data['initState']['questions'][0]['options'][0]['id']
    power_type=data['initState']['questions'][0]['options'][0]['content']
    function_work=data['initState']['questions'][2]['options'][0]['id']
    function_type=data['initState']['questions'][2]['options'][0]['content']
    i=0
    while(i<4)
    condition_status=data['initState']['questions'][4]['options'][i]['id']
    condition_type=data['initState']['questions'][4]['options'][i]['content']
    i+=1
    data_scrape_iphone(id,call,appleid,poweron,carier,function_work,condition_id,condition_status,url,condition_type,function_type,power_type,call_id,power_on_id,carier_id,function_id,apple_account)
    k+=1
    end
    elsif(power=="Yes"&&function=="No")
     poweron=data['initState']['questions'][0]['options'][0]['id']
     power_type=data['initState']['questions'][0]['options'][0]['content']
     function_work=data['initState']['questions'][2]['options'][1]['id']
     function_type=data['initState']['questions'][2]['options'][1]['content']
     data_scrape_iphone(id,call,appleid,poweron,carier,function_work,condition_id,condition_status,url,condition_type,function_type,power_type,call_id,power_on_id,carier_id,function_id,apple_account)
    elsif(power=="No"&&function=="Yes")
     poweron=data['initState']['questions'][0]['options'][1]['id']
     power_type=data['initState']['questions'][0]['options'][1]['content']
     function_work=data['initState']['questions'][2]['options'][0]['id']
     function_type=data['initState']['questions'][2]['options'][0]['content']
     data_scrape_iphone(id,call,appleid,poweron,carier,function_work,condition_id,condition_status,url,condition_type,function_type,power_type,call_id,power_on_id,carier_id,function_id,apple_account)
    end
  end

  def data_scrape_otherphone(id,call,poweron,carier,function_work,condition_id,condition_status,url,condition_type,function_type,power_type,call_id,power_on_id,carier_id,function_id)
   data_array = []
   data_hash = {}
   newurl="https://www.gazelle.com/products/#{id}/calculation.json?product_id=#{id}&calculator_answers%5B#{call_id}%5D=#{call}&calculator_answers%5B#{power_on_id}%5D=#{poweron}&calculator_answers%5B#{carier_id}%5D=#{carier}&calculator_answers%5B#{condition_id}%5D=#{condition_status}&calculator_answers%5B#{function_id}%5D=#{function_work}"
   @agent = Mechanize.new
   json_parse = @agent.get(newurl)
   data=JSON.parse(json_parse.body)
   retailer="Gazelle"
   make=data['product']['brand']
   model=data['product']['model']
   storage=data['product']['size']
   price=data['product']['price']
   colour=data['product']['color']
   gradedetails=
   discountprice=0
   discountpercentage=0
   features=nil
   lastseen=Time.now
   link=url
   if(storage==nil)
    new_storage=model.split(" ")
    storage=new_storage[-1]
    model=model.gsub(new_storage[-1],"")
   end
   isonpromotion="No"
   promotion_text=nil
   data_hash[:retailers] = "Gazelle"
   data_hash[:make] =make
   data_hash[:model] =model
   data_hash[:storage] =storage
   data_hash[:color] = nil
   data_hash[:gradeArray]=get_grade_array(function_type,power_type,condition_type).to_s
   data_hash[:gradeDetails] = get_grade(condition_type)
   data_hash[:price] = data['product']['price']
   data_hash[:discountedprice] = nil
   data_hash[:discountedPercentage] = nil
   data_hash[:currency] = "USD"
   data_hash[:features] = features
   data_hash[:link] = url
   data_hash[:is_visited] = true
   data_hash[:is_deleted] = false
   search_hash={}
   search_hash[:retailers] = "Gazelle"
   search_hash[:make] =make
   search_hash[:model] =model
   search_hash[:storage] =storage
   search_hash[:gradeArray]=data_hash[:gradeArray]
   search_hash[:gradeDetails]=data_hash[:gradeDetails]
   record = Buyback.find_by(data_hash)
   search_record = Buyback.find_by(search_hash)
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

  def data_scrape_iphone(id,call,appleid,poweron,carier,function_work,condition_id,condition_status,url,condition_type,function_type,power_type,call_id,power_on_id,carier_id,function_id,apple_account)
   data_array = []
   data_hash = {}
   newurl="https://www.gazelle.com/products/#{id}/calculation.json?product_id=#{id}&calculator_answers%5B#{call_id}%5D=#{call}&calculator_answers%5B#{apple_account}%5D=#{appleid}&calculator_answers%5B#{power_on_id}%5D=#{poweron}&calculator_answers%5B#{carier_id}%5D=#{carier}&calculator_answers%5B#{function_id}%5D=#{function_work}&calculator_answers%5B#{condition_id}%5D=#{condition_status}"
   @agent = Mechanize.new
   json_parse = @agent.get(newurl)
   data=JSON.parse(json_parse.body)
   retailer="Gazelle"
   make=data['product']['brand']
   model=data['product']['model']
   storage=data['product']['size']
   price=data['product']['price']
   colour=data['product']['color']
   if(storage==nil)
    new_storage=model.split(" ")
    storage=new_storage[-1]
    model=model.gsub(new_storage[-1],"")
   end
   discountprice=0
   discountpercentage=0
   features=nil
   lastseen=Time.now
   isonpromotion="No"
   promotion_text=nil
   data_hash[:retailers] = "Gazelle"
   data_hash[:make] =make
   data_hash[:model] =model
   data_hash[:storage] =storage
   data_hash[:color] = nil
   data_hash[:gradeArray]=get_grade_array(function_type,power_type,condition_type).to_s
   data_hash[:gradeDetails] = get_grade(condition_type)
   data_hash[:price] = data['product']['price']
   data_hash[:discountedprice] = nil
   data_hash[:discountedPercentage] = nil
   data_hash[:currency] = "USD"
   data_hash[:features] = features
   data_hash[:link] = url
   data_hash[:is_visited] = true
   data_hash[:is_deleted] = false
   search_hash={}
   search_hash[:retailers] = "Gazelle"
   search_hash[:make] =make
   search_hash[:model] =model
   search_hash[:storage] =storage
   search_hash[:gradeArray]=data_hash[:gradeArray]
   search_hash[:gradeDetails]=data_hash[:gradeDetails]
   record = Buyback.find_by(data_hash)
   search_record = Buyback.find_by(search_hash)
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

  def get_grade_array(function_type,power_on,condition_type)
    grade = {"power_on" => false , "fully_functional" => false , "crack" => false, "cosmeticCondition" =>nil}
    if(function_type=="working"&&power_on=="yes")
     grade["power_on"] = true
     grade["fully_functional"]=true
     grade["crack"]=false
     if(condition_type=="poor")
      grade["cosmeticCondition"]="Heavy signs of use or damage"
     elsif(condition_type=="fair")
      grade["cosmeticCondition"]="Normal signs of use"
     elsif(condition_type=="good")
      grade["cosmeticCondition"]="Light signs of use"
     elsif(condition_type=="perfect")
      grade["cosmeticCondition"]="Looks like new"
     end
    elsif(function_type=="working"&& power_on=="no")
     grade["power_on"] = false
     grade["fully_functional"]=nil
     grade["crack"]=nil
     grade["cosmeticCondition"]=nil
    elsif(function_type=="broken"&&power_on=="yes")
     grade["power_on"] = true
     grade["fully_functional"]=false
     grade["crack"]=nil
     grade["cosmeticCondition"]=nil
    elsif(function_type=="broken"&&power_on=="no")
     grade["power_on"] = false
     grade["fully_functional"]=false
     grade["crack"]=true
     grade["cosmeticCondition"]=nil
    end
    return grade
  end

  def get_grade(condition_type)
    if(condition_type=="poor")
     return"Poor Condition"
    elsif(condition_type=="fair")
     return"Fair Condition"
    elsif(condition_type=="good")
     return"Good Condition"
    elsif(condition_type=="perfect")
     return"Excellent Condition"
    end
  end

  def getdata(cookie)
    response=selectcompany(cookie)
    parsed_data = Nokogiri::HTML.parse(response.body)
    company=parsed_data.css("div.transition-container li").count
    links=parsed_data.css("div.transition-container li").children.map { |link| link['href']}
    i=0
    name=[]
    while(i<company)
      name[i]=parsed_data.css("div.transition-container li a")[i].text
      if(links[i].include?"iphone")
        iphone_select();
      else
        name=links[i].split("/")
        name=name[-1]
        otherphone_select(name)
      end
      i+=1
    end
  end

  def combination_one()
    poweron="Yes"
    function="Yes"
    return [poweron,function]
  end

  def combination_two()
    poweron="Yes"
    function="No"
    return [poweron,function]
  end

  def combination_three()
    poweron="No"
    function="Yes"
    return [poweron,function]
  end

  def scraper()
    Buyback.where(retailers:"Gazelle").update_all('is_visited': false) 
    response = cookie_request
    cookie = response.response["set-cookie"]
    getdata(cookie)
    Buyback.where(retailers:'Gazelle', is_visited: false).update_all(is_deleted: true)

  end
 end
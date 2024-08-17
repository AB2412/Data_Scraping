class Scraper <  Hamster::Scraper

  def main_page(url)
    connect_to(url)
  end

  def inner_page_request(row, page, state)
    url = "https://www.medicare.gov/api/care-compare/nursing-home/#{row[0]}?lat=#{row[1]}&lon=#{row[2]}"
    headers = {}
    headers["Content-Type"] = "application/json"
    headers["Referer"] = "https://www.medicare.gov/care-compare/results?searchType=NursingHome&page=#{page}&state=#{state}&sort=alpha&tealiumEventAction=Landing%20Page%20-%20Search&tealiumSearchLocation=search%20bar"
    connect_to(url: url, headers: headers)
  end

  def json_request(state, cookie, page)
    url = "https://www.medicare.gov/api/care-compare/provider"
    headers = get_headers(cookie)
    body = get_body(state, page)
    connect_to(url: url, req_body: body, headers: headers, method: :post)
  end

  def get_body(state, page)
    JSON.dump({"type" => "NursingHome","filters" => {"stateSearch" => {"states" => ["#{state}"]}},"page" => page,"limit" => 15,"returnAllResults" => false,"sort" => ["alpha"]})
  end

  def get_headers(cookie)
    {
      "Authority" => "www.medicare.gov",
      "Accept" => "application/json, text/plain, */*",
      "Content-Type": "application/json",
      "Cookie" => cookie,
      "Origin" => "https://www.medicare.gov",
      "Referer" => "https://www.medicare.gov/care-compare/?redirect=true&providerType=NursingHome",
      "X-Newrelic-Id" => "undefined"
    }
  end

  def connect_to(*arguments, &block)
    response = nil
    10.times do
      response = super(*arguments, &block)
      break if response&.status && [200, 304 ,302].include?(response.status)
    end
    response
  end
end
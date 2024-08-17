require 'net/http'
require 'net/imap'
require 'byebug'
require 'date'
require 'time'

def request_verification
  uri = URI('https://quickstart.sos.nh.gov/online')
  req = Net::HTTP::Get.new(uri)
  req['accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7'
  req['accept-language'] = 'en-US,en;q=0.9'
  # req['cookie'] = '__RequestVerificationToken=1TSoMry8TOEA86s8uwIObOnNHMs39Aaq7ywm5GfvnHjE9IDvjF4HAy43W4hR0FxMsuKFBoj8iduoIZzf4jEXc4Tu_d441U9Hzrz3gvT6tLc1; ASP.NET_SessionId=cvfb0svjkiszr1hmaqkrdfx2; menuCollapsed=1'
  req['priority'] = 'u=0, i'
  req['sec-ch-ua'] = '"Google Chrome";v="125", "Chromium";v="125", "Not.A/Brand";v="24"'
  req['sec-ch-ua-mobile'] = '?0'
  req['sec-ch-ua-platform'] = '"Linux"'
  req['sec-fetch-dest'] = 'document'
  req['sec-fetch-mode'] = 'navigate'
  req['sec-fetch-site'] = 'none'
  req['sec-fetch-user'] = '?1'
  req['upgrade-insecure-requests'] = '1'
  req['user-agent'] = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36'

  req_options = {
    use_ssl: uri.scheme == 'https'
  }
  res0 = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(req)
  end
  byebug
  cookie = res0.header.to_hash["set-cookie"].first
  uri = URI('https://quickstart.sos.nh.gov/online/Account/OTPVerification')
  req = Net::HTTP::Post.new(uri)
  req.content_type = 'application/x-www-form-urlencoded'
  req['accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7'
  req['accept-language'] = 'en-US,en;q=0.9'
  req['cache-control'] = 'max-age=0'
  req['cookie'] = cookie
  req['origin'] = 'https://quickstart.sos.nh.gov'
  req['priority'] = 'u=0, i'
  req['referer'] = 'https://quickstart.sos.nh.gov/online/Account/SingleFactorAuthentication'
  req['sec-ch-ua'] = '"Google Chrome";v="125", "Chromium";v="125", "Not.A/Brand";v="24"'
  req['sec-ch-ua-mobile'] = '?0'
  req['sec-ch-ua-platform'] = '"Linux"'
  req['sec-fetch-dest'] = 'document'
  req['sec-fetch-mode'] = 'navigate'
  req['sec-fetch-site'] = 'same-origin'
  req['sec-fetch-user'] = '?1'
  req['upgrade-insecure-requests'] = '1'
  req['user-agent'] = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36'

  req.set_form_data({
    'LoginType' => 'Email'
  })

  req_options = {
    use_ssl: uri.scheme == 'https'
  }
  res1 = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(req)
  end
  byebug
  code = email_reader
  uri = URI('https://quickstart.sos.nh.gov/online/Account/VerifyAuthenticateCode')
  req = Net::HTTP::Post.new(uri)
  req.content_type = 'application/x-www-form-urlencoded'
  req['accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7'
  req['accept-language'] = 'en-US,en;q=0.9'
  req['cache-control'] = 'max-age=0'
  # req['cookie'] = '__RequestVerificationToken=1TSoMry8TOEA86s8uwIObOnNHMs39Aaq7ywm5GfvnHjE9IDvjF4HAy43W4hR0FxMsuKFBoj8iduoIZzf4jEXc4Tu_d441U9Hzrz3gvT6tLc1; ASP.NET_SessionId=cvfb0svjkiszr1hmaqkrdfx2'
  req['origin'] = 'https://quickstart.sos.nh.gov'
  req['priority'] = 'u=0, i'
  req['referer'] = 'https://quickstart.sos.nh.gov/online/Account/OTPVerification'
  req['sec-ch-ua'] = '"Google Chrome";v="125", "Chromium";v="125", "Not.A/Brand";v="24"'
  req['sec-ch-ua-mobile'] = '?0'
  req['sec-ch-ua-platform'] = '"Linux"'
  req['sec-fetch-dest'] = 'document'
  req['sec-fetch-mode'] = 'navigate'
  req['sec-fetch-site'] = 'same-origin'
  req['sec-fetch-user'] = '?1'
  req['upgrade-insecure-requests'] = '1'
  req['user-agent'] = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36'
  
  req.set_form_data({
    'txtDig1' => code[0],
    'txtDig2' => code[1],
    'txtDig3' => code[2],
    'txtDig4' => code[3],
    'txtDig5' => code[4],
    'txtDig6' => code[5],
    'hdnError' => ''
  })
  
  req_options = {
    use_ssl: uri.scheme == 'https'
  }
  res2 = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(req)
  end
  byebug
end

def email_reader
  # Email account details
  email = 'areeba@agilekode.com'
  password = 'ibds enfc slyb vkch'
  imap_server = 'imap.gmail.com'
  imap_port = 993
  imap_ssl = true

  start_time = Time.now
  timeout = 120
  imap = Net::IMAP.new(imap_server, imap_port, imap_ssl)
  imap.login(email, password)
  # Select the inbox
  imap.select('INBOX')
  sleep(1)
  # byebug
  # Search for new emails from the specific sender
  emails = imap.search(['FROM', 'quickstart@sos.nh.gov'])
  if emails.empty?
    puts "No emails found from quickstart@sos.nh.gov"
  else
    # Sort emails by arrival time (ascending order)
    sorted_emails = emails.sort_by do |message_id|
      envelope = imap.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
      Time.parse(envelope.date).to_datetime
    end
    latest_email_id = sorted_emails.last
    envelope = imap.fetch(latest_email_id, "ENVELOPE")[0].attr["ENVELOPE"]
    body = imap.fetch(latest_email_id, "BODY[TEXT]")[0].attr["BODY[TEXT]"]

    # Print email details
    puts "From: #{envelope.from[0].name} <#{envelope.from[0].mailbox}@#{envelope.from[0].host}>"
    puts "Subject: #{envelope.subject}"
    puts "Date: #{envelope.date}"
    puts "---------------------------------"
    sleep(2)
    auth_code = extract_auth_code(body)
    puts "Authentication Code: #{auth_code}" if auth_code
    puts "---------------------------------"
    imap.logout
    imap.disconnect
    end
  auth_code
end

def extract_auth_code(body)
  match = body.match(/\b\d{6}\b/)
  match ? match[0] : nil
end

request_verification

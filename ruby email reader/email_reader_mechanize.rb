require 'mechanize'
require 'net/http'
require 'byebug'
require 'date'
require 'time'
require 'selenium-webdriver'


ZYTE_PROXY_CA = '/home/areeba/zype-ca.crt'
# @browser = Net::HTTP.new(uri.host, uri.port, TINY_PROXY["OC_PROXY"], TINY_PROXY["OC_PROXY_PORT"])
# , '188433.crawlera.com', '8011', 'b13af5acc0be4bd7b93f16d426158359'

def browser
  if @browser.nil?
    uri = URI.parse('https://quickstart.sos.nh.gov')
    @browser = Net::HTTP.new(uri.host, uri.port)
    @browser.use_ssl = true
    @browser.ssl_version = :TLSv1_2
    @browser.open_timeout = 60
    @browser.read_timeout = 60
    @browser.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
  @browser
end
ZYTE_PROXY_HOST = ENV['OC_PROXY'] || '188433.crawlera.com'
ZYTE_PROXY_PORT = ENV['OC_PROXY_PORT'] || 8011
ZYTE_PROXY_KEY = ENV['OC_PROXY_KEY'] || 'dc199c28a02e4affb5b4af3634294551'


# def setup_zyte_proxy(browser)
#   browser.read_timeout = 60
#   browser.max_history = 1
#   browser.pluggable_parser.default = Mechanize::Page
#   # browser.set_proxy CREDENTIALS["ZYTE_PROXY_HOST"], CREDENTIALS["ZYTE_PROXY_PORT"], CREDENTIALS["ZYTE_PROXY_KEY"], ''
#   browser.set_proxy ZYTE_PROXY_HOST, ZYTE_PROXY_PORT, ZYTE_PROXY_KEY, ''
#   browser.agent.http.ca_file = ZYTE_PROXY_CA
#   browser
# end

# def login_request
#   byebug
#   Mechanize.start do |browser|
#     browser = setup_zyte_proxy(browser)
#     browser.read_timeout = 15
#     main_page = browser.get("https://quickstart.sos.nh.gov/online")
#     verification_code = main_page.at('input[name="__RequestVerificationToken"]')['value']
#     payload = "__RequestVerificationToken=#{verification_code}&hdnRedirection=&hdnUccSerch=&hdnsearchCriteria=&hdnDebtorSearched=&hdnSelectedStatus=&hdnddlTimeFrame=&hdnWrongEntries=&txtUsername=areeba&hdnError=&hdnErrorMsg="
#     # payload = "hdnRedirection=&hdnUccSerch=&hdnsearchCriteria=&hdnDebtorSearched=&hdnSelectedStatus=&hdnddlTimeFrame=&hdnWrongEntries=&txtUsername=areeba&hdnError=&hdnErrorMsg="
#     byebug
#     login_page = browser.post("https://quickstart.sos.nh.gov/online/Account/SingleFactorAuthentication", payload)
#     auth_payload = "LoginType=Email"
#     headers = {
#       'accept'=> 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
#       'accept-language'=> 'en-US,en;q=0.9',
#       'cache-control'=> 'max-age=0',
#       # 'cookie'=> '__RequestVerificationToken=-3RydqBsxJBjwg3Tb6pRpjVVdfP3kzPj3X7__xZQ405d8Ngtl7G3dDUoM6ERFUr6xCUXNxyAOmxOfOgQTvv7j8zvZrLO7p8dmw4JzSaJTYU1; ASP.NET_SessionId=ofm32iuqdswgyncnrlh5yhcy; menuCollapsed=1'
#       'origin'=> 'https://quickstart.sos.nh.gov',
#       'priority'=> 'u=0, i',
#       'referer'=> 'https://quickstart.sos.nh.gov/online/Account/SingleFactorAuthentication',
#       'sec-ch-ua'=> '"Google Chrome";v="125", "Chromium";v="125", "Not.A/Brand";v="24"',
#       'sec-ch-ua-mobile'=> '?0',
#       'sec-ch-ua-platform'=> '"Linux"',
#       'sec-fetch-dest'=> 'document',
#       'sec-fetch-mode'=> 'navigate',
#       'sec-fetch-site'=> 'same-origin',
#       'sec-fetch-user'=> '?1',
#       'upgrade-insecure-requests'=> '1',
#       'user-agent'=> 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36'
#     }
#     byebug
#     auth_req = browser.post("https://quickstart.sos.nh.gov/online/Account/OTPVerification", auth_payload)
#     byebug
#     code = email_reader
#     byebug
#     auth_verify_payload = "txtDig1=#{code[0]}&txtDig2=#{code[1]}&txtDig3=#{code[2]}&txtDig4=#{code[3]}&txtDig5=#{code[4]}&txtDig6=#{code[5]}&hdnError="
#     auth_verify_req = browser.post("https://quickstart.sos.nh.gov/online/Account/VerifyAuthenticateCode", auth_verify_payload)
#     browser.get("https://quickstart.sos.nh.gov/online/BusinessInquire")
#     %x[curl -v -u #{ZYTE_PROXY_KEY}: #{ZYTE_SESSION_API}#{session_id} -X DELETE]
#   end
# end

def webshare_browser
  if @webshare_browser.nil?
    @webshare_browser = Mechanize.new
    @webshare_browser.set_proxy "84.21.189.173", 5820, "kvazgnqo", "oiyn94r33scm"
    # @zyte_browser.agent.http.ca_file = CREDENTIALS["OC_CERT_FILE"]
    @webshare_browser.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
  @webshare_browser
end

def login_request
  byebug
  main_page = browser.get("https://quickstart.sos.nh.gov/online")
  verification_code = Nokogiri::HTML(main_page.body).at('input[name="__RequestVerificationToken"]')['value']
  payload = "__RequestVerificationToken=#{verification_code}&hdnRedirection=&hdnUccSerch=&hdnsearchCriteria=&hdnDebtorSearched=&hdnSelectedStatus=&hdnddlTimeFrame=&hdnWrongEntries=&txtUsername=areeba&hdnError=&hdnErrorMsg="
  # payload = "hdnRedirection=&hdnUccSerch=&hdnsearchCriteria=&hdnDebtorSearched=&hdnSelectedStatus=&hdnddlTimeFrame=&hdnWrongEntries=&txtUsername=areeba&hdnError=&hdnErrorMsg="
  login_page = webshare_browser.post("https://quickstart.sos.nh.gov/online/Account/SingleFactorAuthentication", payload)
  byebug
  auth_payload = "LoginType=Email"
  headers = {
    'accept'=> 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
    'accept-language'=> 'en-US,en;q=0.9',
    'cache-control'=> 'max-age=0',
    # 'cookie'=> '__RequestVerificationToken=-3RydqBsxJBjwg3Tb6pRpjVVdfP3kzPj3X7__xZQ405d8Ngtl7G3dDUoM6ERFUr6xCUXNxyAOmxOfOgQTvv7j8zvZrLO7p8dmw4JzSaJTYU1; ASP.NET_SessionId=ofm32iuqdswgyncnrlh5yhcy; menuCollapsed=1'
    'origin'=> 'https://quickstart.sos.nh.gov',
    'priority'=> 'u=0, i',
    'referer'=> 'https://quickstart.sos.nh.gov/online/Account/SingleFactorAuthentication',
    'sec-ch-ua'=> '"Google Chrome";v="125", "Chromium";v="125", "Not.A/Brand";v="24"',
    'sec-ch-ua-mobile'=> '?0',
    'sec-ch-ua-platform'=> '"Linux"',
    'sec-fetch-dest'=> 'document',
    'sec-fetch-mode'=> 'navigate',
    'sec-fetch-site'=> 'same-origin',
    'sec-fetch-user'=> '?1',
    'upgrade-insecure-requests'=> '1',
    'user-agent'=> 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36'
  }
  byebug
  auth_req = browser.post("https://quickstart.sos.nh.gov/online/Account/OTPVerification", auth_payload)
  byebug
  code = email_reader
  byebug
  auth_verify_payload = "txtDig1=#{code[0]}&txtDig2=#{code[1]}&txtDig3=#{code[2]}&txtDig4=#{code[3]}&txtDig5=#{code[4]}&txtDig6=#{code[5]}&hdnError="
  auth_verify_req = browser.post("https://quickstart.sos.nh.gov/online/Account/VerifyAuthenticateCode", auth_verify_payload)
  browser.get("https://quickstart.sos.nh.gov/online/BusinessInquire")
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


login_request
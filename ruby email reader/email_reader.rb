require 'net/imap'
require 'byebug'
require 'date'
require 'time'
require 'selenium-webdriver'


def login_request
  setup_driver
  @driver.navigate.to "https://quickstart.sos.nh.gov/online"
  sleep(2)
  @driver.find_element(id: 'flip', class: 'btn btn-secondary').click
  sleep(2)
  @driver.find_element(id: 'txtUsername').send_keys "areeba"
  sleep(2)
  @driver.find_element(:xpath, '//button[contains(@class, "btn-primary") and contains(@class, "btn-block")]').click
  sleep(2)
  @driver.find_element(:xpath, '//button[@id="login" and contains(@class, "btn-primary") and contains(@class, "btn-block")]').click
  sleep(2)
  code = email_reader
  @driver.find_elements(css: 'input[id^="txtDig"]').each_with_index { |input, index| input.send_keys(code[index]) }
  @driver.find_element(css: 'button#login.btn.btn-block.btn-primary.ms-sm-3').click
  @driver.navigate.to "https://quickstart.sos.nh.gov/online/BusinessInquire"
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

def setup_driver
  options = Selenium::WebDriver::Chrome::Options.new
  # proxy = Selenium::WebDriver::Proxy.new(
  #   http: '188433.crawlera.com:8011', # Replace with your proxy address and port
  #   ssl: '188433.crawlera.com:8011'   # Replace with your proxy address and port
  # )
  # options.proxy = proxy
  # options.add_argument('--headless')
  # options.add_argument("--proxy-server=http://{188433.crawlera.com}:#{proxy_pass}@#{proxy_host}:#{proxy_port}:#")
  proxy = Selenium::WebDriver::Proxy.new(
    http: "bfa9f7e8a6df44e6843d60697b989a06@188433.crawlera.com:8011",
    ssl: "bfa9f7e8a6df44e6843d60697b989a06@188433.crawlera.com:8011"
  )
  options.add_argument('--disable-gpu')
  options.add_argument('--ignore-certificate-errors')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--no-sandbox')
  options.add_argument('--ignore-ssl-errors')
  options.proxy = proxy
  byebug
  # capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(proxy: proxy)
  @driver = Selenium::WebDriver.for :chrome, options: options
end

def extract_auth_code(body)
  match = body.match(/\b\d{6}\b/)
  match ? match[0] : nil
end

login_request
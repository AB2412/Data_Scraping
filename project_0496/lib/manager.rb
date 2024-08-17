require_relative '../lib/parser'
require_relative '../lib/keeper'
require_relative '../lib/scraper'

class Manager <  Hamster::Harvester
  def initialize
    super
    @parser = Parser.new
    @keeper = Keeper.new
    @scraper = Scraper.new
  end

  def download
    all_states = keeper.usa_administrative_division_states
    downloaded_state = peon.list(subfolder: "#{keeper.run_id}").sort.last rescue []
    states = (downloaded_state.empty?) ? get_states_array(all_states, "AL") : get_states_array(all_states, downloaded_state)
    states.each do |state|
      main_page_request = scraper.main_page("https://www.medicare.gov/care-compare/?redirect=true&providerType=NursingHome")
      cookie = main_page_request.headers['set-cookie']
      downloaded_pages = peon.list(subfolder: "#{keeper.run_id}/#{state}")  rescue []
      page = (downloaded_pages.empty?) ? 1 : downloaded_pages.map{|e| e.split("_")[1].to_i}.sort.last
      while true
        json_response = scraper.json_request(state, cookie, page)
        json_parse = parser.parse_json(json_response.body)
        break if json_parse["results"].empty?
        save_file("#{keeper.run_id}/#{state}/Page_#{page}", json_response.body, "json_page_#{page}")
        process_inner_links(json_parse["results"], page, state)
        page += 1
      end
    end
  end

  def store
    states = peon.list(subfolder: "#{keeper.run_id}")
    states.each do |state|
      pages = peon.list(subfolder: "#{keeper.run_id}/#{state}")
      pages.each do |page|
        main_page = peon.give(subfolder: "#{keeper.run_id}/#{state}/#{page}", file: "json_#{page.downcase}")
        main_page_parser = parser.parse_json(main_page)
        results = main_page_parser["results"]
        rows = results.map{|e| e["providerId"]}
        data_array = process_rows(rows, page, state)
        keeper.insert_records(data_array)
      end
    end
  end

  private
  attr_accessor :keeper, :parser, :scraper

  def process_rows(rows, page, state)
    data_array = []
    rows.each do |row|
      row_json = peon.give(subfolder: "#{keeper.run_id}/#{state}/#{page}", file: "#{row}.gz") rescue nil
      next if row_json.nil?
      row_data_hash = parser.get_data(row_json, "#{keeper.run_id}", state, row)
      data_array << row_data_hash
    end
    data_array
  end

  def get_states_array(states, key)
    idx = states.find_index(key)
    states[idx..]
  end

  def process_inner_links(results, page, state)
    rows = results.map{|e| [e["providerId"], e["lat"], e["lon"]]}
    rows.each do |row|
      already_downloaded_files = peon.give_list(subfolder: "#{keeper.run_id}/#{state}/Page_#{page}")
      next if already_downloaded_files.include? "#{row[0]}.gz"

      inner_link_response = scraper.inner_page_request(row, page, state)
      save_file("#{keeper.run_id}/#{state}/Page_#{page}", inner_link_response.body, "#{row[0]}")
    end
  end

  def save_file(sub_folder, body, file_name)
    peon.put(content: body, file: file_name, subfolder: sub_folder)
  end
end

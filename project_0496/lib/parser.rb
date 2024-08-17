class Parser <  Hamster::Parser

  def parse_json(body)
    JSON.parse(body)
  end

  def get_data(json_data, run_id, state, row)
    data = parse_json(json_data)
    hash_data = data["locations"]
    data_hash = {}
    data_hash[:nursing_home_name]    = data["name"]
    data_hash[:nursing_home_address] = get_value(hash_data, "addressLine1")
    data_hash[:nursing_home_city]    = get_value(hash_data, "addressCity")
    data_hash[:nursing_home_state]   = get_value(hash_data, "addressState")
    data_hash[:nursing_home_zip_code]     = get_value(hash_data, "addressZipcode")
    data_hash[:certified_beds_number]     =  data["numberOfCertifiedBeds"]
    data_hash = mark_empty_as_nil(data_hash)
    data_hash[:md5_hash]                  = create_md5_hash(data_hash)
    data_hash[:nursing_home_phone_number] = get_value(hash_data, "phone")
    data_hash[:data_source_url]           = "https://www.medicare.gov/care-compare/details/nursing-home/#{row}?state=#{state}"
    data_hash[:run_id]         = run_id
    data_hash[:touched_run_id] = run_id
    data_hash
  end

  private

  def mark_empty_as_nil(data_hash)
    data_hash.transform_values{|value| ((value.to_s.empty?) || (value == "null") || (value == "")) ? nil : value}
  end

  def get_value(array, key)
    array[0][key] rescue nil
  end

  def create_md5_hash(data_hash)
    data_string = ''
    data_hash.each_value do |val|
      data_string += val.to_s
    end
    Digest::MD5.hexdigest data_string
  end

end

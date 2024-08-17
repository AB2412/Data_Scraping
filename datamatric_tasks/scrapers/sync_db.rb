require "google/cloud/storage"
require 'zip'

class SyncDb

  def initialize
    api_key = ENV['AIRTABLE_API_KEY']
    @base_key = ENV['AIRTABLE_BASE_KEY']
    @australia_key = ENV['AIRTABLE_AUSTRALIA_KEY']
    @client = Airtable::Client.new(api_key)
  end


  def sync_providers_data
    @table = @client.table(@base_key, "Providers")
    @records = @table.all
    county_id = Country.find_by(name: 'New Zealand')['id']

    @records.each do |record|
      provider_record = Provider.find_or_create_by(name: record.name, country_id: county_id)
      unless provider_record.airtable_id.present?
        provider_record.update(airtable_id: record.id)
      end
    end
  end

  def udpate_nil_to_empty data_hash
    data_hash.each do |k,v|
      data_hash[k] = "" if v == nil
    end
    data_hash
  end

  def sync_mobile_data
    providers_records = Provider.pluck(:airtable_id, :id).to_h
    @table = @client.table(@base_key, "Mobile_plans")
    @records = @table.all
    nz_mobile_processed_ids = []
    @records.each do |record|
      plans_data_hash = {}
      search_data_hash = {}
      plans_data_hash[:provider_id] = providers_records[record["provider"].first]
      plans_data_hash[:name] = record.plan_name
      plans_data_hash[:plan_type] = record.plan_type
      plans_data_hash[:connection_type] = record['connection_type']
      plans_data_hash[:usage_type] = record.usage_type
      plans_data_hash[:operator] = record.operator
      plans_data_hash[:contract_period] = record.contract_period
      plans_data_hash[:contract_duration] = record.contract_duration
      # plans_data_hash[:contract] = record.contract
      # plans_data_hash[:standard_inclusions] = record.standard_inclusions
      plans_data_hash[:data_limit] = record.data_limit
      plans_data_hash[:data_features] = record.data_features
      plans_data_hash[:data_rollover] = record['data_rollover']
      plans_data_hash[:data_social] = record.data_social
      plans_data_hash[:data_social_limit] = record.data_social_limit
      plans_data_hash[:data_sharing] = record.data_sharing
      plans_data_hash[:extra_data] = record['extra_data']
      plans_data_hash[:data_promotion] = record.data_promotion rescue ""
      plans_data_hash[:data_promotion_period] = record.data_promotion_period rescue ""
      plans_data_hash[:price] = record.price
      plans_data_hash[:discounted_price] = record.discounted_price.present? ? "$#{record.discounted_price.to_s}" : ""
      plans_data_hash[:discounted_period] = record.discounted_period
      plans_data_hash[:price_details] = record.price_details
      plans_data_hash[:national_calls] = record.national_calls
      plans_data_hash[:national_texts] = record.national_texts
      plans_data_hash[:international_summary] = record.international_summary
      plans_data_hash[:international_calls] = record.international_calls
      plans_data_hash[:international_texts] = record.international_texts
      plans_data_hash[:international_countries] = record.international_countries
      plans_data_hash[:international_roaming] = record.international_roaming
      # plans_data_hash[:roaming] = record.roaming
      plans_data_hash[:shared_account] = record['shared_account']
      plans_data_hash[:num_plans_allowed] = record['num_plans_allowed']
      plans_data_hash[:recharge_period] = record.recharge_period
      plans_data_hash[:features] = record['features']
      plans_data_hash[:is_on_promotion] = record.is_on_promotion
      plans_data_hash[:promotions] = record.promotions
      plans_data_hash[:video_calls] = record.video_calls  
      plans_data_hash[:hotspot] = record['hotspot']
      plans_data_hash[:bundled_entertainment] = record.bundled_entertainment rescue ""
      plans_data_hash[:entertainment_music] = record.entertainment_music rescue ""
      plans_data_hash[:entertainment_gaming] = record.entertainment_gaming rescue ""
      plans_data_hash[:entertainment_sport] = record.entertainment_sport rescue ""
      plans_data_hash[:entertainment_streaming] = record.entertainment_streaming rescue ""
      
      # plans_data_hash[:max_rollover] = record['max_rollover']
      plans_data_hash[:roaming] = record['roaming']
      
      plans_data_hash[:source_url] = record.source_url
      plans_data_hash[:airtable_id] = record.id
      plans_data_hash[:is_deleted] = record.is_deleted == true ? true : false

      plans_data_hash = udpate_nil_to_empty(plans_data_hash)

      search_data_hash[:provider_id] = plans_data_hash[:provider_id]
      search_data_hash[:name] = plans_data_hash[:name]

      nz_mobile_processed_ids << plans_data_hash[:airtable_id]

      if MobilePlan.find_by(plans_data_hash)
        puts 'hurrah.. already exist'
      elsif MobilePlan.find_by(airtable_id: record.id)#MobilePlan.find_by(search_data_hash)
        puts  'Record Updated!'
        searched_record = MobilePlan.find_by(airtable_id: record.id)
        searched_record.update(plans_data_hash)
      else
        MobilePlan.create(plans_data_hash)
      end
    end
    nz_mobile_db_airtable_ids = MobilePlan.where("airtable_id != ''").pluck(:airtable_id)
    deleted_ids = nz_mobile_db_airtable_ids - nz_mobile_processed_ids
    MobilePlan.where(:airtable_id => deleted_ids).destroy_all
    puts "*********** Mobile Plan Completed ***************"
  end

  def sync_internet_data
    providers_records = Provider.pluck(:airtable_id, :id).to_h
    @table = @client.table(@base_key, "Internet_plans")
    @records = @table.all
    nz_internet_processed_ids = []
    @records.each do |record|
      plans_data_hash = {}
      search_data_hash = {}
      plans_data_hash[:provider_id] = providers_records[record["provider"].first]
      plans_data_hash[:name] = record.plan_name#.strip
      plans_data_hash[:usage_type] = record.usage_type
      # plans_data_hash[:standard_inclusions] = record.standard_inclusions
      plans_data_hash[:contract] = record.contract
      plans_data_hash[:contract_duration] = record.contract_duration
      plans_data_hash[:connection_type] = record.connection_type
      plans_data_hash[:connection_technology] = record.connection_technology
      plans_data_hash[:data_limit] = record.data_limit#.strip
      plans_data_hash[:peak_data_times] = record.peak_data_times rescue ""
      plans_data_hash[:price] = record.price
      plans_data_hash[:discounted_price] = record.discounted_price.present? ? "$#{record.discounted_price.to_s}" : ""
      plans_data_hash[:discounted_period] = record.discounted_period
      plans_data_hash[:price_details] = record.price_details
      plans_data_hash[:installation_cost] = record.installation_cost
      plans_data_hash[:modem_fee] = record.modem_fee
      plans_data_hash[:modem_postage] = record.modem_postage
      plans_data_hash[:is_on_promotion] = record.is_on_promotion
      plans_data_hash[:promotions] = record.promotion
      plans_data_hash[:recharge_period] = record.recharge_period
      plans_data_hash[:termination_fee] = record.termination_fee
      plans_data_hash[:static_ip] = record.static_ip rescue ""
      plans_data_hash[:internet_security] = record.internet_security rescue ""
      plans_data_hash[:mobile] = record.mobile
      plans_data_hash[:landline] = record.landline
      plans_data_hash[:features] = record.features
      plans_data_hash[:data_details] = record.data_details
      plans_data_hash[:source_url] = record.source_url
      plans_data_hash[:bundled_entertainment] = record.bundled_entertainment rescue ""
      plans_data_hash[:entertainment_music] = record.entertainment_music rescue ""
      plans_data_hash[:entertainment_gaming] = record.entertainment_gaming rescue ""
      plans_data_hash[:entertainment_sport] = record.entertainment_sport rescue ""
      plans_data_hash[:entertainment_hardware] = record.entertainment_hardware rescue ""
      plans_data_hash[:airtable_id] = record.id
      plans_data_hash[:additional_urls] = record.additional_urls
      plans_data_hash[:is_deleted] = record[:is_deleted] == true ? true : false
      speed = ''
      download = ''
      upload = ''
      if record.speed.present?
        plans_data_hash[:speed] = record.speed
        speed_details = plans_data_hash[:speed].split(' ').first.split('/')
        plans_data_hash[:download] = speed_details[0]
        plans_data_hash[:upload] = speed_details[-1]
        plans_data_hash[:speed_details] = speed_details
      end

      plans_data_hash = udpate_nil_to_empty(plans_data_hash)

      search_data_hash[:provider_id] = plans_data_hash[:provider_id]
      search_data_hash[:name] = plans_data_hash[:name]


      # if InternetPlan.find_by(airtable_id: record.id)
      nz_internet_processed_ids << plans_data_hash[:airtable_id]

      if InternetPlan.find_by(plans_data_hash)
        puts 'hurrah.. already exist'
      elsif InternetPlan.find_by(airtable_id: record.id) #InternetPlan.find_by(search_data_hash)
        puts  'Record Updated!'
        searched_record = InternetPlan.find_by(airtable_id: record.id)
        searched_record.update(plans_data_hash)
      else
        InternetPlan.create(plans_data_hash)
      end
    end
    nz_internet_db_airtable_ids = InternetPlan.where("airtable_id != ''").pluck(:airtable_id)
    deleted_ids = nz_internet_db_airtable_ids - nz_internet_processed_ids
    InternetPlan.where(:airtable_id => deleted_ids).destroy_all
    puts "*********** Internet Plan Completed ***************"
  end

  def sync_entertainment_data
    providers_records = Provider.pluck(:airtable_id, :id).to_h
    @table = @client.table(@base_key, "Entertainment_plans")
    @records = @table.all
    nz_entertainment_processed_ids = []

    @records.each do |record|
      plans_data_hash = {}
      search_data_hash = {}
      plans_data_hash[:provider_id] = providers_records[record["provider"].first]
      plans_data_hash[:name] = record.plan_name
      plans_data_hash[:plan_type] = record.plan_type
      plans_data_hash[:operator] = record.operator
      plans_data_hash[:contract] = record.contract_period
      plans_data_hash[:standard_inclusions] = record.standard_inclusions
      plans_data_hash[:data_limit] = record.data_limit
      plans_data_hash[:promotions] = record.promotions
      plans_data_hash[:connection_type] = record.connection_type
      plans_data_hash[:price] = record.price
      plans_data_hash[:price_details] = record.price_details
      plans_data_hash[:category] = record.category
      plans_data_hash[:brand] = record.brand
      plans_data_hash[:type_of_content] = record.type_of_content
      plans_data_hash[:other] = record.other
      plans_data_hash[:features] = record.features
      plans_data_hash[:source_url] = record.source_url
      plans_data_hash[:is_deleted] = record.is_deleted == true ? true : false
      plans_data_hash[:airtable_id] = record.id
      nz_entertainment_processed_ids << plans_data_hash[:airtable_id]

      plans_data_hash = udpate_nil_to_empty(plans_data_hash)

      search_data_hash[:provider_id] = plans_data_hash[:provider_id]
      search_data_hash[:name] = plans_data_hash[:name]

      if EntertainmentPlan.find_by(plans_data_hash)
        puts 'hurrah.. already exist'
      elsif EntertainmentPlan.find_by(airtable_id: record.id)
        puts  'Record Updated!'
        EntertainmentPlan.find_by(airtable_id: record.id)
        searched_record.update(plans_data_hash)
      else
        EntertainmentPlan.create(plans_data_hash)
      end
    end
    nz_entertainment_db_airtable_ids = EntertainmentPlan.where("airtable_id != ''").pluck(:airtable_id)
    deleted_ids = nz_entertainment_db_airtable_ids - nz_entertainment_processed_ids
    EntertainmentPlan.where(:airtable_id => deleted_ids).destroy_all
    puts "*********** Entertainment Plan Completd ***************"
  end

  def sync_australia_providers_data
    @table = @client.table(@australia_key, "Providers")
    @records = @table.all
    county_id = Country.find_by(name: 'Australia')['id']
    @records.each do |record|
      provider_record = Provider.find_or_create_by(name: record.name, country_id: county_id)
      unless (provider_record.airtable_id.nil?) || (provider_record.airtable_id == "")
        Provider.where(name: provider_record.name).update_all(key_provider: true)
      end
      unless provider_record.airtable_id.present?
        provider_record.update(airtable_id: record.id)
      end
    end
  end

  def sync_australia_internet_data
    providers_records = Provider.pluck(:airtable_id, :id).to_h
    @table = @client.table(@australia_key, "Internet_plans")
    @records = @table.all
    au_internet_processed_ids = []
    @records.each do |record|
      plans_data_hash = {}
      search_data_hash = {}
      provider_id = providers_records[record["provider"].first] rescue nil
      if provider_id.nil?
        providers_records = Provider.where.not( airtable_id: nil).pluck(:name, :id).to_h
        plans_data_hash[:provider_id] = providers_records[record["provider"]]
      else
        plans_data_hash[:provider_id] = providers_records[record["provider"]]
      end
      plans_data_hash[:plan_name] = record.plan_name#.strip
      plans_data_hash[:usage_type] = record.usage_type
      plans_data_hash[:contract] = record.contract
      plans_data_hash[:contract_duration] = record.contract_duration
      plans_data_hash[:connection_type] = record.connection_type
      plans_data_hash[:connection_technology] = record.connection_technology
      plans_data_hash[:download] = record.download
      plans_data_hash[:upload] = record.upload
      plans_data_hash[:speed_details] = record.speed_details
      plans_data_hash[:peak_download_speed] = record.peak_download_speeds
      plans_data_hash[:data_limit] = record.data_limit
      plans_data_hash[:data_details] = record.data_details
      plans_data_hash[:peak_data_times] = record.peak_data_times
      plans_data_hash[:peak_data] = record.peak_data
      plans_data_hash[:off_peak_data_times] = record.off_peak_data_times
      plans_data_hash[:off_peak_data] = record.off_peak_data
      plans_data_hash[:discounted_price] = record.discounted_price.present? ? "$#{record.discounted_price.to_s}" : ""
      plans_data_hash[:discounted_period] = record.discounted_period
      plans_data_hash[:price] = "$" + record.price.to_s
      plans_data_hash[:minimum_total_cost] = record.minimum_total_cost
      plans_data_hash[:installation_cost] = record.installation_cost
      plans_data_hash[:modem_fee] = record.modem_fee
      plans_data_hash[:modem_postage] = record.modem_postage
      plans_data_hash[:byo_modem] = record.byo_modem
      plans_data_hash[:modem_description] = record.modem_description
      plans_data_hash[:is_on_promotion] = record.is_on_promotion
      plans_data_hash[:promotions] = record.promotions
      plans_data_hash[:speed] = record.speed
      plans_data_hash[:price_details] = record.price_details
      plans_data_hash[:recharge_period] = record.recharge_period
      plans_data_hash[:termination_fee] = record.termination_fee rescue ""
      plans_data_hash[:internet_security] = record.internet_security rescue ""
      plans_data_hash[:terms_conditions] = record.terms_conditions
      plans_data_hash[:features] = record.features
      plans_data_hash[:entertainment_other] = record.entertainment_other rescue ""
      plans_data_hash[:entertainment_gaming] = record.entertainment_gaming rescue ""
      plans_data_hash[:entertainment_music] = record.entertainment_music rescue ""
      plans_data_hash[:entertainment_sport] = record.entertainment_sport rescue ""
      plans_data_hash[:entertainment_streaming] = record.entertainment_streaming rescue ""
      plans_data_hash[:entertainment_hardware] = record.entertainment_hardware rescue ""
      plans_data_hash[:bundled_entertainment] = record.bundled_entertainment rescue ""
      plans_data_hash[:static_ip] = record.static_ip
      plans_data_hash[:bundled_mobile] = record.bundled_mobile rescue ""
      plans_data_hash[:mobile] = record.mobile rescue ""
      plans_data_hash[:landline] = record.landline rescue ""
      plans_data_hash[:bundled_landline] = record.bundled_landline rescue ""
      plans_data_hash[:international_calls] = record.international_calls rescue ""
      plans_data_hash[:electricity] = record.electricity rescue ""
      plans_data_hash[:gas] = record.gas rescue ""
      plans_data_hash[:bundled_electricity] = record.bundled_electricity rescue ""
      plans_data_hash[:bundled_gas] = record.bundled_gas rescue ""
      plans_data_hash[:cis_link] = record['cis_link'] rescue ""
      # # plans_data_hash[:promotional_image_id] = record['promotion_image_id']
      plans_data_hash[:source_url] = record.source_url
      plans_data_hash[:airtable_id] = record.id
      plans_data_hash[:is_deleted] = record.is_deleted == true ? true : false
      plans_data_hash = udpate_nil_to_empty(plans_data_hash)
      search_data_hash[:provider_id] = plans_data_hash[:provider_id]
      search_data_hash[:plan_name] = plans_data_hash[:plan_name]
      au_internet_processed_ids << plans_data_hash[:airtable_id]
      if AustraliaInternetPlan.find_by(plans_data_hash)
        puts 'hurrah.. already exist'
      elsif AustraliaInternetPlan.find_by(airtable_id: record.id)#AustraliaInternetPlan.find_by(search_data_hash)
        puts  'Record Updated!'
        searched_record = AustraliaInternetPlan.find_by(airtable_id: record.id)
        searched_record.update(plans_data_hash)
      else
        AustraliaInternetPlan.create(plans_data_hash)
      end
    end
    au_internet_db_airtable_ids = AustraliaInternetPlan.where("airtable_id != ''").pluck(:airtable_id)
    deleted_ids = au_internet_db_airtable_ids - au_internet_processed_ids
    AustraliaInternetPlan.where(:airtable_id => deleted_ids).destroy_all
  end

  def sync_australia_mobile_data
    providers_records = Provider.pluck(:airtable_id, :id).to_h
    @table = @client.table(@australia_key, "Mobile_plans")
    @records = @table.all
    au_mobile_processed_ids = []
    @records.each do |record|
      plans_data_hash = {}
      search_data_hash = {}
      provider_id = providers_records[record["provider"].first] rescue nil
      if provider_id.nil?
        providers_records = Provider.where.not( airtable_id: nil).pluck(:name, :id).to_h
        plans_data_hash[:provider_id] = providers_records[record["provider"]]
      else
        plans_data_hash[:provider_id] = providers_records[record["provider"]]
      end
      plans_data_hash[:plan_name] = record.plan_name
      plans_data_hash[:plan_type] = record.plan_type
      plans_data_hash[:usage_type] = record.usage_type
      plans_data_hash[:price] = "$" + record.price.to_s
      plans_data_hash[:promotions] = record.promotions
      plans_data_hash[:data_features] = record.data_features
      plans_data_hash[:data_promotion] = record.data_promotion
      plans_data_hash[:data_promotion_period] = record.data_promotion_period
      plans_data_hash[:terms_conditions] = record.terms_conditions
      plans_data_hash[:contract_duration] = record.contract_duration
      plans_data_hash[:operator] = record.operator
      plans_data_hash[:source_url] = record.source_url
      plans_data_hash[:data_rollover] = record.data_rollover
      plans_data_hash[:is_on_promotion] = record.is_on_promotion
      plans_data_hash[:recharge_period] = record.recharge_period
      plans_data_hash[:national_calls] = record.national_calls
      plans_data_hash[:national_texts] = record.national_texts
      plans_data_hash[:discounted_price] = record.discounted_price.present? ? "$#{record.discounted_price.to_s}" : "" 
      plans_data_hash[:discounted_period] = record.discounted_period
      plans_data_hash[:connection_type] = record['connection_type']
      plans_data_hash[:features] = record['features']
      plans_data_hash[:data_limit] = record.data_limit
      plans_data_hash[:data_sharing] = record.data_sharing
      # plans_data_hash[:data_rollover] = record['data_rollover']
      plans_data_hash[:extra_data] = record['extra_data']
      plans_data_hash[:international_summary] = record['international_summary']
      plans_data_hash[:international_calls] = record.international_calls
      plans_data_hash[:international_texts] = record.international_texts
      plans_data_hash[:international_countries] = record.international_countries
      plans_data_hash[:international_roaming] = record.international_roaming
      plans_data_hash[:price_details] = record.price_details
      plans_data_hash[:shared_account] = record['shared_account']
      plans_data_hash[:num_plans_allowed] = record['num_plans_allowed']
      plans_data_hash[:hotspot] = record.hotspot
      plans_data_hash[:entertainment_music] = record.entertainment_music rescue ""
      plans_data_hash[:entertainment_sport] = record.entertainment_sport rescue ""
      plans_data_hash[:entertainment_streaming] = record.entertainment_streaming rescue ""
      plans_data_hash[:entertainment_gaming] = record.entertainment_gaming rescue ""
      plans_data_hash[:bundled_entertainment] = record.bundled_entertainment rescue ""
      plans_data_hash[:cis_link] = record['cis_link']
      plans_data_hash[:airtable_id] = record.id
      plans_data_hash[:is_deleted] = record.is_deleted == true ? true : false
      plans_data_hash = udpate_nil_to_empty(plans_data_hash)

      search_data_hash[:provider_id] = plans_data_hash[:provider_id]
      search_data_hash[:plan_name] = plans_data_hash[:plan_name]
      au_mobile_processed_ids << plans_data_hash[:airtable_id]
      if AutraliaMobilePlan.find_by(plans_data_hash)
        puts 'hurrah.. already exist'
      elsif AutraliaMobilePlan.find_by(airtable_id: record.id)
        puts  'Record Updated!'
        searched_record = AutraliaMobilePlan.find_by(airtable_id: record.id)
        searched_record.update(plans_data_hash)
      else
        AutraliaMobilePlan.create(plans_data_hash)
      end
    end
    au_mobile_db_airtable_ids = AutraliaMobilePlan.where("airtable_id != ''").pluck(:airtable_id)
    deleted_ids = au_mobile_db_airtable_ids - au_mobile_processed_ids
    AutraliaMobilePlan.where(:airtable_id => deleted_ids).destroy_all
  end

  def sync_airtable
    self.sync_providers_data
    self.sync_mobile_data
    self.sync_internet_data
    self.sync_entertainment_data
  end

  def sync_au_airtable
    self.sync_australia_providers_data
    self.sync_australia_mobile_data
    self.sync_australia_internet_data
  end
end

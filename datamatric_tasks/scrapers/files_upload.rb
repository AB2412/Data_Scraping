require "google/cloud/storage"
require 'zip'

class FilesUpload

  def self.upload_files
    storage = Google::Cloud::Storage.new(project_id: "sourse-ai-platform-prod", credentials: "datametrics-data-ingest.json")
    bucket = storage.bucket "cde-sourse-ai-platform-prod-nz-telco-market-data-ingest", skip_lookup: true
    files_uploaded = bucket.files
    uploaded_files = Dir["public/uploaded_files/*_#{Time.now.strftime('%Y%m%d')}*.json"]

    uploaded_files.each do |uploaded_file|
      uploaded_file_name = uploaded_file.split('/').last
      bucket.create_file uploaded_file, uploaded_file_name
    end
  end

  def self.make_zip
    folder = "public/uploaded_files"
    uploaded_files = Dir["public/uploaded_files/*_#{Time.now.strftime('%Y%m%d')}*.json"]
    input_filenames = uploaded_files.map{|s| s.split('/').last }
    zipfile_name = "#{folder}/NZ Market Data for #{Time.now.strftime("%d %B %Y")}.zip"

    Zip::File.open(zipfile_name, create: true) do |zipfile|
      input_filenames.each do |filename|
        zipfile.add(filename, File.join(folder, filename))
      end
    end
  end

  def self.make_au_zip
    folder = "public/australia_files"
    uploaded_files = Dir["#{folder}/*_#{Time.now.strftime('%Y%m%d')}*.json"]
    input_filenames = uploaded_files.map{|s| s.split('/').last }
    zipfile_name = "#{folder}/Aus Market Data for #{Time.now.strftime("%d %B %Y")}.zip"

    Zip::File.open(zipfile_name, create: true) do |zipfile|
      input_filenames.each do |filename|
        zipfile.add(filename, File.join(folder, filename))
      end
    end
  end

  def self.upload_AU_files
    storage = Google::Cloud::Storage.new(project_id: "sourse-ai-platform-prod", credentials: "au-data-ingest-service-account-json-key.json")
    bucket = storage.bucket "cde-sourse-ai-platform-prod-telco-market-data-ingest", skip_lookup: true
    files_uploaded = bucket.files

    uploaded_files = Dir["public/australia_files/*_#{Time.now.strftime('%Y%m%d')}*.json"]
    uploaded_files.each do |uploaded_file|
      uploaded_file_name = uploaded_file.split('/').last
      bucket.create_file uploaded_file, uploaded_file_name
    end
  end
end

# frozen_string_literal: true
require_relative '../lib/manager'

def scrape(options)
  begin
    manager = Manager.new
    if options[:download]
      manager.download(ARGV.last)
    elsif options[:store]
      manager.store
    end
  rescue Exception => e
    Hamster.logger.error.e(full_message)
    Hamster.report(to: 'U03HBFA4P3M', message: "#{Hamster::PROJECT_DIR_NAME}_#{@project_number}:\n#{e.full_message}", use: :slack)
  end
end

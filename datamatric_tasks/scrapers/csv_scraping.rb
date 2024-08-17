class CsvScraping  
  def csv_read()
    path=Rails.root.join('app','scrapers','links.csv')
    table = CSV.table(path)[:url]
    all_links = Retailer.pluck(:link)
    un_inserted_links = table - all_links
    data_hash={}
    un_inserted_links.map { |link|
      if(link.include?'greengadgets')
        data_hash[:retailers]="greengadgets"
      elsif(link.include?'ozmobiles')
        data_hash[:retailers]="ozmobiles"  
      end
      data_hash[:link]= link
      data_hash[:is_visited]=false
      Retailer.create(data_hash)
      data_hash={}
    }
  end
end
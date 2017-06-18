require 'csv'
require 'open-uri'
require 'time'

namespace 'vyapari' do
  namespace 'import' do

    desc "Import all data in sequence"
    task 'all' => :environment do

      import_list = ["countries", "exchange_rates"]
      
      import_list.each do |item|
        print "Importing #{item.titleize} \t".yellow
        begin
          Rake::Task["vyapari:import:#{item}"].invoke
        rescue ArgumentError => e
            puts "Loading #{item} - Failed - #{e.message}".red
        rescue Exception => e
          puts "Importing #{item.titleize} - Failed - #{e.message}".red
          puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
        end
      end
      puts " "
    end

    ["Country", "Region", "ExchangeRate", "Supplier", "Store", "Brand", "Category", "Terminal"].each do |cls_name|
      name = cls_name.underscore.pluralize
      desc "Import #{cls_name.pluralize}"
      task name => :environment do
        verbose = true
        verbose = false if ["false", "f","0","no","n"].include?(ENV["verbose"].to_s.downcase.strip)
        path = ENV['path']
        cls_name.constantize.import_data(Vyapari::Engine, path, false, verbose)
      end
    end

    namespace 'dummy' do
      
      desc "Import all dummy data in sequence"
      task 'all' => :environment do

        import_list = ["dummy:countries", "dummy:regions", "dummy:exchange_rates", "dummy:suppliers", "dummy:stores", "dummy:brands", "dummy:categories", "dummy:terminals"]
        
        import_list.each do |item|
          print "Loading #{item.split(':').last.titleize} \t".yellow
          begin
            Rake::Task["vyapari:import:#{item}"].invoke
          rescue ArgumentError => e
            puts "Loading #{item} - Failed - #{e.message}".red
          rescue Exception => e
            puts "Loading #{item} - Failed - #{e.message}".red
            puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
          end
        end
        puts " "
      end

      ["Country", "Region", "ExchangeRate", "Supplier", "Store", "Brand", "Category", "Terminal"].each do |cls_name|
        name = cls_name.underscore.pluralize
        desc "Load Dummy #{cls_name.pluralize}"
        task name => :environment do
          verbose = true
          verbose = false if ["false", "f","0","no","n"].include?(ENV["verbose"].to_s.downcase.strip)
          cls_name.constantize.import_data(Vyapari::Engine, nil, true, verbose)                
        end
      end
      
    end

  end
end
    
namespace :fixtures do
  desc "Create YAML fixtures from data in the development database."
  task :extract => :environment do
    ActiveRecord::Base.establish_connection
    tables = ["genres_tracks"]
    tables.each do |table_name|
      puts "Dumping table: #{table_name}."
      i = "0000"
      records = ActiveRecord::Base.connection.select_all "SELECT * FROM #{table_name}"
      File.open("#{RAILS_ROOT}/spec/fixtures/#{table_name}.yml", "w") do |file|
        yaml = records.inject({}) do |hash, record|
          hash["#{table_name}_#{i.succ!}"] = record
          hash
        end.to_yaml
        file.write yaml
      end
    end
  end
end

namespace :radio do
  desc "Installs the Radio application."
  task :install => :environment do
    radio = RadioApp.get

    puts "You are about to install Radio! We're going to ask you some questions to get everything set up. After installation, you'll be able to change these settings whenever you want to."
    puts "Press enter to continue and you'll be done in no time..."
    STDIN.gets

    print "What do you want your Radio to be called? "
    radio.name = STDIN.gets.chomp

    print "What is the root location of all your music files? "
    entered_music_path = STDIN.gets.chomp
    while File.exists?(entered_music_path) === false do
      print "- That doesn't look right. Please try that again: "
      entered_music_path = STDIN.gets.chomp
    end
    radio.music_path = entered_music_path

    print "What image do you want as your background (full path to the file)? "
    entered_background_path = STDIN.gets.chomp
    while File.exists?(entered_background_path) === false do
      print "- That doesn't look right. Please try that again: "
      entered_background_path = STDIN.gets.chomp
    end
    radio.background = File.open entered_background_path

    user = User.new
    puts ""
    print "Now we need to create a user for you. What is your first name? "
    user.first_name = STDIN.gets.chomp
    print "And your last name? "
    user.last_name = STDIN.gets.chomp
    print "What image do you want as your personal display picture (full path to the file)? "
    entered_avatar_path = STDIN.gets.chomp
    while File.exists?(entered_avatar_path) === false do
      print "- That doesn't look right. Please try that again: "
      entered_avatar_path = STDIN.gets.chomp
    end
    user.picture = File.open entered_avatar_path

    puts ""
    puts "Please hold..."
    puts "Employing DJs..."

    Dir.glob("#{Rails.root}/app/models/djs/**/*.rb").each do |model_file|
      require_or_load model_file
    end
    DJ.send(:descendants).each do |dj_class|
      dj_class.create! unless dj_class.get
    end

    radio.dj = RandomGenreDJ.get

    puts "Discovering tracks and genres in the music directory..."
    Track.discover radio.music_path

    puts "The DJ is building the first playlist..."
    radio.dj.run

    puts ""

    if radio.save && user.save
      puts "Radio created!"
      puts "Radio name: #{radio.name}."
      puts "Radio music path: #{radio.music_path}"
      puts "You have been set up with the default DJ (#{radio.dj.name})."
      puts "#{Track.count} tracks have been found, in #{Genre.count} genres."
      puts "And the DJ has built up his playlist."
      puts "Also, your account has been created, so you can now use the app!"
    else
      puts "Couldn't create your Radio for the following reasons:"
      (radio.errors.full_messages + user.errors.full_messages).each do |message|
        puts "- #{message}"
      end
      puts "You'll have to start again :("
    end
  end
end

require "json"
require "open-uri"

module LastFm
  API_KEY = "f72e45685382f281ab7ff35dff816377"

  # Simple wrapper for the LastFM API. Method as first argument, and anything required by LastFM as a hash afterwards.
  def self.poll(method, options)
    JSON.parse(open("http://ws.audioscrobbler.com/2.0/?method=#{method}&api_key=#{API_KEY}&format=json&#{options.map{|key, value| "#{key}=#{value.gsub(' ', '%20')}"}.join("&")}").read)
  end

  # If we can, use the "extralarge" image from LastFM. If not, take the biggest one we can find.
  def self.pick_image(images)
    extra_large_image = images.detect{|image| image["size"] == "extralarge"}["#text"]
    if extra_large_image.empty?
      images.reverse.each do |image|
        if not image["#text"].empty?
          return image["#text"]
        end
      end
      return ""
    else
      return extra_large_image
    end
  end
end

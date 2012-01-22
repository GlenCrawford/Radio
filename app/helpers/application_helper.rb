module ApplicationHelper
  def time_ago_in_words(time)
    time ? "#{super(time).capitalize} ago" : "Never"
  end
end

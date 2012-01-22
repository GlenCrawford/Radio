module UsersHelper
  def user_picture(user, size = :medium)
    width, height = {
      :small => [45, 45],
      :medium => [80, 80]
    }[size]
    image_tag user.picture.url, :alt => user.name, :size => "#{width}x#{height}"
  end
end

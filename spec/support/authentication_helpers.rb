module SpecHelpers
  module Authentication
    def sign_in(user)
      cookies = mock "cookies"
      controller.stub(:cookies).and_return cookies
      cookies.should_receive(:[]).once.with(:user_id).and_return user.id
    end
  end
end

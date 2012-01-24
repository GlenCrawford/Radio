require 'spec_helper'

describe Admin::BaseHelper do
  describe :form_line do
    it "should render a form line container with form fields inside it" do
      field = helper.text_field_tag :first_name
      helper.form_line(&lambda {field}).should == "<div class=\"form_field\">#{field}<div class=\"clear\"></div></div>"
    end
  end

  describe :form_buttons do
    it "should render form buttons container with buttons inside it" do
      button = helper.submit_tag "Save"
      helper.form_buttons(&lambda {button}).should == "<div class=\"form_buttons\">#{button}</div>"
    end
  end
end

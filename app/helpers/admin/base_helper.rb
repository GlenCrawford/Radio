module Admin::BaseHelper
  def form_line(&block)
    str = ''
    str << '<div class="form_field">'
    str << capture(&block)
    str << '<div class="clear"></div>'
    str << '</div>'
    raw str
  end

  def form_buttons(&block)
    str = ''
    str << '<div class="form_buttons">'
    str << capture(&block)
    str << '</div>'
    raw str
  end
end

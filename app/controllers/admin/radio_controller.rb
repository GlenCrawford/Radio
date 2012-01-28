class Admin::RadioController < Admin::BaseController
  def index
    #
  end

  def update
    params[:radio_app][:dj] = DJ.find(params[:dj][:id])
    if @radio.update_attributes params[:radio_app]
      redirect_to admin_radio_index_path, :notice => "Radio settings have been updated!"
    else
      render :action => "index"
    end
  end
end

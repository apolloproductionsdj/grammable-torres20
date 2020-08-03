class ApplicationController < ActionController::Base

  def gram_not_found(status=:not_found)
    render plain: "#{status.to_s.titleize} :(", status: status
  end
  
end

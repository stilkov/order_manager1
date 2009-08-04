# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def base_uri
    controller.request.protocol + controller.request.host_with_port + '/'
  end
  
  def request_uri
    controller.request.request_uri
  end
end

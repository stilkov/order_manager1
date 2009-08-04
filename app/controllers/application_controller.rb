# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time            
  
  # Reconstruct a date object from date_select helper form params
  def build_date_from_params(field_name, params)
    if field = params["#{field_name.to_s}"] then
      Date.new(field["(1i)"].to_i, 
               field["(2i)"].to_i, 
               field["(3i)"].to_i)
    end
  end
  
end

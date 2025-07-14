class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # for page that is unaccessible f
 def require_session_key(key, redirect_path = page_unaccessible_path)
  puts "DEBUG: session[#{key.inspect}] = #{session[key].inspect} | session = #{session.to_hash.inspect}"
    unless session[key]
      flash[:alert] = "Cannot access page."
      redirect_to redirect_path and return
    end
  end

end

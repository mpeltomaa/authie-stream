require 'securerandom'
require 'authie/session'

module Authie
  class ControllerDelegate

    def initialize(controller)
      @controller = controller
    end

    # Set a random browser ID for this browser.
    def set_browser_id
      until cookies[Authie.config.browser_id_cookie_name]
        proposed_browser_id = SecureRandom.uuid
        unless Authie::Session.where(:browser_id => proposed_browser_id).exists?
          cookies[Authie.config.browser_id_cookie_name] = {
            :value => proposed_browser_id,
            :expires => 5.years.from_now,
            :httponly => true,
            :secure => @controller.request.ssl?
          }
          # Dispatch an event when the browser ID is set.
          Authie.config.events.dispatch(:set_browser_id, proposed_browser_id)
        end
      end
    end

    # Touch the auth session on each request if logged in
    def touch_stream_session
      if stream_in?
        stream_session.touch!
      end
    end

    # Return the currently logged in user object
    def current_stream
      stream_in? ? stream_session.user : nil
    end

    # Set the currently logged in user
    def current_stream=(user)
      create_stream_session(user)
      user
    end

    # Create a new session for the given user
    def create_stream_session(user)
      if user
        @stream_session = Authie::Session.start(@controller, :user => user)
      else
        stream_session.invalidate! if stream_in?
        @stream_session = :none
      end
    end

    # Invalidate an existing auth session
    def invalidate_stream_session
      if stream_in?
        stream_session.invalidate!
        @stream_session = :none
        true
      else
        false
      end
    end

    # Is anyone currently logged in?
    def stream_in?
      stream_session.is_a?(Session)
    end

    # Return the currently logged in user session
    def stream_session
      @stream_session ||= Authie::Session.get_session(@controller)
      @stream_session == :none ? nil : @stream_session
    end

    private

    # Return cookies for the controller
    def cookies
      @controller.send(:cookies)
    end

  end
end

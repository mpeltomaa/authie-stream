require 'authie/controller_delegate'

module Authie
  module ControllerExtension

    def self.included(base)
      base.helper_method :stream_in?, :current_stream, :stream_session
      before_action_method = base.respond_to?(:before_action) ? :before_action : :before_filter
      base.public_send(before_action_method, :set_browser_id, :touch_stream_session)
    end

    private

    def stream_session_delegate
      @stream_session_delegate ||= Authie::ControllerDelegate.new(self)
    end

    def set_browser_id
      stream_session_delegate.set_browser_id
    end

    def touch_stream_session
      stream_session_delegate.touch_stream_session
    end

    def current_stream
      stream_session_delegate.current_stream
    end

    def current_stream=(user)
      stream_session_delegate.current_stream = user
    end

    def create_stream_session(user)
      stream_session_delegate.create_stream_session(user)
    end

    def invalidate_stream_session
      stream_session_delegate.invalidate_stream_session
    end

    def stream_in?
      stream_session_delegate.stream_in?
    end

    def stream_session
      stream_session_delegate.stream_session
    end

  end
end

require 'authie/controller_delegate'

class ControllerDelegateTest < Minitest::Test

  def setup
    @controller = FakeController.new
    @delegate = Authie::ControllerDelegate.new(@controller)
  end

  def test_users_can_be_stream_in
    # Test nobody is logged in by default
    assert_equal false, @delegate.stream_in?
    # Create a user and log them in
    user = User.create(:username => 'tester')
    @delegate.create_stream_session(user)
    # Test that we're now logged in
    assert_equal true, @delegate.stream_in?
    assert_equal user, @delegate.current_stream
    assert_equal Authie::Session, @delegate.stream_session.class
  end

  def test_users_can_be_stream_in_by_setting_current_stream
    # Test nobody is logged in by default
    assert_equal false, @delegate.stream_in?
    # Create a user and log them in
    user = User.create(:username => 'tester')
    @delegate.current_stream = user
    # Test that we're now logged in
    assert_equal true, @delegate.stream_in?
    assert_equal user, @delegate.current_stream
    assert_equal Authie::Session, @delegate.stream_session.class
  end

  def test_stream_sessions_can_be_invalidated
    user = User.create(:username => 'tester')
    @delegate.create_stream_session(user)
    # Test that we're now logged in
    assert_equal true, @delegate.stream_in?
    # Test we can invalidate session
    assert_equal true, @delegate.invalidate_stream_session
    assert_equal nil, @delegate.stream_session
    assert_equal false, @delegate.stream_in?
    assert_equal nil, @delegate.current_stream
  end

  def test_browser_id_can_be_set
    # Test that there's no browser ID to begin
    assert_equal nil, @controller.cookies[:browser_id]
    # Set the browser ID
    @delegate.set_browser_id
    # Test the browser ID looks like a UUID
    assert @controller.cookies[:browser_id] =~ /\A[a-f0-9\-]{36}\z/
    assert_equal true, @controller.cookies.raw[:browser_id][:httponly]
    assert_equal true, @controller.cookies.raw[:browser_id][:secure]
  end

  def test_touching_stream_sessions
    @delegate.current_stream = User.create(:username => 'dave')
    assert_equal nil, @delegate.stream_session.last_activity_at
    @delegate.touch_stream_session
    assert_equal Time, @delegate.stream_session.last_activity_at.class
    assert_equal '127.0.0.1', @delegate.stream_session.last_activity_ip
  end

  def test_touching_stream_sessions_raises_errors
    @delegate.current_stream = User.create(:username => 'dave')
    assert @delegate.stream_session.invalidate!
    assert_raises Authie::Session::InactiveSession do
      @delegate.touch_stream_session
    end
  end

  def test_user_impersonation
    user1 = User.create(:username => 'steve')
    user2 = User.create(:username => 'mike')
    @delegate.current_stream = user1
    # Test the current user is our current user
    assert_equal user1, @delegate.current_stream
    # Test that we can impersonate the other user
    assert @delegate.stream_session.impersonate!(user2)
    # The current user remained unchanged. This is the desired behavour.
    assert_equal user1, @delegate.current_stream
  end

  def test_current_stream_returns_nil_when_not_stream_in
    assert_equal nil, @delegate.current_stream
  end

end

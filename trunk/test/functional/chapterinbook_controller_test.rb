require File.dirname(__FILE__) + '/../test_helper'
require 'chapterinbook_controller'

# Re-raise errors caught by the controller.
class ChapterinbookController; def rescue_action(e) raise e end; end

class ChapterinbookControllerTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  include AuthenticatedTestHelper

  fixtures :chapterinbooks

  def setup
    @controller = ChapterinbookController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_login_and_redirect
    post :login, :login => 'quentin', :password => 'quentin'
    assert session[:chapterinbook]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :login, :login => 'quentin', :password => 'bad password'
    assert_nil session[:chapterinbook]
    assert_response :success
  end

  def test_should_allow_signup
    old_count = Chapterinbook.count
    create_chapterinbook
    assert_response :redirect
    assert_equal old_count+1, Chapterinbook.count
  end

  def test_should_require_login_on_signup
    old_count = Chapterinbook.count
    create_chapterinbook(:login => nil)
    assert assigns(:chapterinbook).errors.on(:login)
    assert_response :success
    assert_equal old_count, Chapterinbook.count
  end

  def test_should_require_password_on_signup
    old_count = Chapterinbook.count
    create_chapterinbook(:password => nil)
    assert assigns(:chapterinbook).errors.on(:password)
    assert_response :success
    assert_equal old_count, Chapterinbook.count
  end

  def test_should_require_password_confirmation_on_signup
    old_count = Chapterinbook.count
    create_chapterinbook(:password_confirmation => nil)
    assert assigns(:chapterinbook).errors.on(:password_confirmation)
    assert_response :success
    assert_equal old_count, Chapterinbook.count
  end

  def test_should_require_email_on_signup
    old_count = Chapterinbook.count
    create_chapterinbook(:email => nil)
    assert assigns(:chapterinbook).errors.on(:email)
    assert_response :success
    assert_equal old_count, Chapterinbook.count
  end

  def test_should_logout
    login_as :quentin
    get :logout
    assert_nil session[:chapterinbook]
    assert_response :redirect
  end
  
  protected
  def create_chapterinbook(options = {})
    post :signup, :chapterinbook => { :login => 'quire', :email => 'quire@example.com', 
                             :password => 'quire', :password_confirmation => 'quire' }.merge(options)
  end
end

require File.dirname(__FILE__) + '/../test_helper'
require 'packages_controller'

# Re-raise errors caught by the controller.
class PackagesController; def rescue_action(e) raise e end; end

class PackagesControllerTest < Test::Unit::TestCase
  def setup
    @controller = PackagesController.new
    request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

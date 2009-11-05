require File.dirname(__FILE__) + '/../test_helper'
require 'pricing_controller'

# Re-raise errors caught by the controller.
class PricingController; def rescue_action(e) raise e end; end

class PricingControllerTest < Test::Unit::TestCase
  def setup
    @controller = PricingController.new
    request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

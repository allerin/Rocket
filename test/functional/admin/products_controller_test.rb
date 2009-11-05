require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/products_controller'

# Re-raise errors caught by the controller.
class Admin::ProductsController; def rescue_action(e) raise e end; end

class Admin::ProductsControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::ProductsController.new
    request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

require 'test_helper'

class UsuarioControllerTest < ActionController::TestCase
  test "should get crear_usuario" do
    get :crear_usuario
    assert_response :success
  end

end

require 'test_helper'

class ArchivosControllerTest < ActionController::TestCase
  test "should get subir_archivos" do
    get :subir_archivos
    assert_response :success
  end

  test "should get listar_archivos" do
    get :listar_archivos
    assert_response :success
  end

  test "should get borrar_archivos" do
    get :borrar_archivos
    assert_response :success
  end

  test "should get guardar_comentarios" do
    get :guardar_comentarios
    assert_response :success
  end

end

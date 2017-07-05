require 'test_helper'

class SalevaluesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @salevalue = salevalues(:one)
  end

  test "should get index" do
    get salevalues_url
    assert_response :success
  end

  test "should get new" do
    get new_salevalue_url
    assert_response :success
  end

  test "should create salevalue" do
    assert_difference('Salevalue.count') do
      post salevalues_url, params: { salevalue: {  } }
    end

    assert_redirected_to salevalue_url(Salevalue.last)
  end

  test "should show salevalue" do
    get salevalue_url(@salevalue)
    assert_response :success
  end

  test "should get edit" do
    get edit_salevalue_url(@salevalue)
    assert_response :success
  end

  test "should update salevalue" do
    patch salevalue_url(@salevalue), params: { salevalue: {  } }
    assert_redirected_to salevalue_url(@salevalue)
  end

  test "should destroy salevalue" do
    assert_difference('Salevalue.count', -1) do
      delete salevalue_url(@salevalue)
    end

    assert_redirected_to salevalues_url
  end
end

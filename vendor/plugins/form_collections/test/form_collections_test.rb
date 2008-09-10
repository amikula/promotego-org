ENV['RAILS_ENV'] = 'test'

require 'test/unit'
# XXX: nasty nasty nasty nasty!
require(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'config', 'boot')))
require(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'config', 'environment')))
require 'test_help'

class SaneParameterParsingTest < Test::Unit::TestCase
  REQUEST_CLASS = ActionController::AbstractRequest

  def test_parse_simple_key
    hash = ActionController::AbstractRequest.parse_query_parameters("key=value")
    assert_equal "value", hash["key"]
  end

  def test_parse_array_key
    hash = ActionController::AbstractRequest.parse_query_parameters("key[]=value")
    assert_equal ["value"], hash["key"]
  end

  def test_parse_array_key_with_index
    hash = ActionController::AbstractRequest.parse_query_parameters("key[3]=value")
    assert_equal [nil, nil, nil, "value"], hash["key"]
  end

  def test_parse_hash_key
    hash = ActionController::AbstractRequest.parse_query_parameters("key[subkey]=value")
    assert_equal({"subkey" => "value"}, hash["key"])
  end

  def test_parse_nested_collection
    hash = ActionController::AbstractRequest.parse_query_parameters("key[0][4][1]=value")
    assert_equal({"key" => [[nil, nil, nil, nil, [nil, "value"]]]}, hash)
  end

  def test_parse_simple_nested_collections
    hash = ActionController::AbstractRequest.parse_query_parameters(
      "key[0][name]=value1&key[0][description]=value2"
    )
    assert_equal({"key" => [{"name" => "value1", "description" => "value2"}]}, hash)
  end

  def test_parse_complex_nested_collections
    input = "a[b][0][c][]=d&a[b][0][c][]=e&a[b][1]=test"
    expected = {
      "a" => {
        "b" => [{"c" => ["d", "e"]}, "test"],
      },
    }
    hash = ActionController::AbstractRequest.parse_query_parameters(input)
    assert_equal(expected, hash)
  end

  def test_type_error_for_ambiguous_keys
    input = "a[b][0]=1&a[b][c]=2"
    assert_raises(TypeError) {
      ActionController::AbstractRequest.parse_query_parameters(input)
    }
  end
end

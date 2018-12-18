require 'test_helper'
require 'json'
require 'tempfile'

class JSONLTest < Minitest::Test
  def setup
    @path = File.expand_path('../fixtures/source.jsonl', __FILE__)

    @source = File.read(@path)
    @parsed = JSONL.parse(@source)
    @generated = JSONL.generate(@parsed)

    @true = [{"name" => "Gilbert", "wins" => [["straight", "7♣"], ["one pair", "10♥"]]},
             {"name" => "Alexa", "wins" => [["two pair", "4♠"], ["two pair", "9♠"]]},
             {"name" => "May", "wins" => []},
             {"name" => "Deloise", "wins" => [["three of a kind", "5♣"]]}]
  end

  def test_reader
    jsonl_reader = JSONL.open(@path)
    i = 0
    jsonl_reader.each do |obj|
      assert_equal obj, @true[i]
      i += 1
    end
    jsonl_reader.close
  end

  def test_writer_new
    output = StringIO.new
    jsonl_writer = JSONL.new(output)
    @parsed.each do |obj|
      jsonl_writer << obj
    end
  end

  def test_writer_open
    jsonl_writer = JSONL.open(File.expand_path('../fixtures/target.jsonl', __FILE__), 'w')
    @parsed.each do |obj|
      jsonl_writer << obj
    end
    jsonl_writer.close
  end

  def test_generate_type_error
    e = assert_raises(TypeError) { JSONL.generate('invalid type') }
    assert_equal 'can\'t generate from String', e.message
  end

  def test_generate_generated_type
    assert_instance_of String, @generated
  end

  def test_generate_generated_count
    assert_equal 4, @generated.split("\n").count
  end

  def test_generate_generated_can_parse
    assert JSONL.parse(@generated)
  end

  def test_generate_parsed_equals_to_the_original
    assert_equal @parsed, JSONL.parse(@generated)
  end

  def test_parse_parsed_class
    assert_instance_of Array, @parsed
  end

  def test_parse_parsed_count
    assert_equal 4, @parsed.count
  end

  def test_parse_parsed_equals_to_json_parse
    source = @source.split("\n")[0]
    assert_equal JSON.parse(source), @parsed[0]
  end
end

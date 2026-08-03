require "minitest/autorun"

class FormulaeTest < Minitest::Test
  FORMULAE = Dir[File.expand_path("../Formula/*.rb", __dir__)].freeze

  def test_prototype_contains_four_formulae
    assert_equal 4, FORMULAE.length
  end

  def test_formulae_pin_sources_and_include_tests
    FORMULAE.each do |path|
      contents = File.read(path)
      assert_match %r{url "https://github\.com/[^/]+/[^/]+/archive/[0-9a-f]{40}\.tar\.gz"}, contents, path
      assert_match /sha256 "[0-9a-f]{64}"/, contents, path
      assert_includes contents, "test do", path
      RubyVM::InstructionSequence.compile_file(path)
    end
  end
end

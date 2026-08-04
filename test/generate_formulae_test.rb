require "minitest/autorun"
require "tmpdir"

load File.expand_path("../bin/generate-formulae", __dir__)

class ActionFormulaTest < Minitest::Test
  def test_name_and_class_name_normalise_case_and_separators
    f = formula(owner: "JS-DevTools", repo: "npm-publish")
    assert_equal "js-devtools-npm-publish", f.name
    assert_equal "JsDevtoolsNpmPublish", f.class_name
  end

  def test_simple_formula_ruby
    f = formula(owner: "actions", repo: "checkout", version: "4.2.2",
                sha: "abc123", sha256: "deadbeef", using: "node24",
                description: "Checkout a repository", license: "MIT")
    rb = f.to_ruby
    assert_match "class ActionsCheckout < Formula", rb
    assert_match 'desc "Checkout a repository"', rb
    assert_match 'url "https://codeload.github.com/actions/checkout/tar.gz/abc123"', rb
    assert_match 'version "4.2.2"', rb
    assert_match 'sha256 "deadbeef"', rb
    assert_match 'license "MIT"', rb
    refute_match "depends_on", rb
    refute_match "inreplace", rb
    assert_match 'assert_path_exists prefix/"action.yml"', rb
  end

  def test_composite_emits_depends_on_and_inreplace
    f = formula(owner: "codecov", repo: "codecov-action",
                uses: [{ owner: "actions", repo: "github-script", subdir: nil,
                         ref: "abc", raw: "uses: actions/github-script@abc" }])
    rb = f.to_ruby
    assert_match 'depends_on "actions-github-script"', rb
    assert_match 'inreplace "action.yml"', rb
    assert_match '"uses: actions/github-script@abc"', rb
    assert_match '"uses: ./../actions-github-script"', rb
  end

  def test_composite_with_subdir_keeps_path_in_rewrite
    f = formula(owner: "gradle", repo: "gradle-build-action",
                uses: [{ owner: "gradle", repo: "actions", subdir: "setup-gradle",
                         ref: "v3.5.0", raw: "uses: gradle/actions/setup-gradle@v3.5.0" }])
    rb = f.to_ruby
    assert_match 'depends_on "gradle-actions"', rb
    assert_match '"uses: ./../gradle-actions/setup-gradle"', rb
  end

  def test_duplicate_uses_collapse_to_one_dependency
    f = formula(uses: [
      { owner: "actions", repo: "cache", subdir: nil, ref: "v5", raw: "uses: actions/cache@v5" },
      { owner: "actions", repo: "cache", subdir: nil, ref: "v5", raw: "uses: actions/cache@v5" }
    ])
    assert_equal ["actions-cache"], f.dependencies
  end

  def formula(overrides = {})
    ActionFormula.new(**{
      owner: "actions", repo: "example", version: "1.0.0", sha: "abc",
      sha256: "0" * 64, description: "Example", license: "MIT",
      action_file: "action.yml", using: "composite", uses: []
    }.merge(overrides))
  end
end

class FormulaGeneratorTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir
    @gen = FormulaGenerator.new(output: File.join(@dir, "out"), cache: File.join(@dir, "cache"))
  end

  def teardown
    FileUtils.remove_entry(@dir)
  end

  def test_parse_ref_owner_repo
    r = @gen.parse_ref("actions/cache@v4")
    assert_equal "actions", r[:owner]
    assert_equal "cache", r[:repo]
    assert_nil r[:subdir]
    assert_equal "v4", r[:ref]
    assert_equal "uses: actions/cache@v4", r[:raw]
  end

  def test_parse_ref_with_subdir
    r = @gen.parse_ref("gradle/actions/setup-gradle@v3.5.0")
    assert_equal "gradle", r[:owner]
    assert_equal "actions", r[:repo]
    assert_equal "setup-gradle", r[:subdir]
  end

  def test_parse_ref_ignores_local_and_docker
    assert_nil @gen.parse_ref("./local/action")
    assert_nil @gen.parse_ref("$/local/action")
    assert_nil @gen.parse_ref("docker://alpine:3")
    assert_nil @gen.parse_ref(nil)
  end

  def test_parse_uses_only_for_composite
    assert_empty @gen.parse_uses({ "runs" => { "using" => "node24", "main" => "dist/index.js" } })
  end

  def test_parse_uses_extracts_and_dedupes
    action = {
      "runs" => {
        "using" => "composite",
        "steps" => [
          { "uses" => "actions/cache@v5" },
          { "run" => "echo hi" },
          { "uses" => "actions/cache@v5" },
          { "uses" => "./local" }
        ]
      }
    }
    uses = @gen.parse_uses(action)
    assert_equal 1, uses.length
    assert_equal "actions", uses.first[:owner]
  end

  def test_clean_desc
    assert_equal "GitHub Action for Foo", @gen.clean_desc("A GitHub Action for Foo.")
    assert_nil @gen.clean_desc(nil)
    long = "x" * 100
    assert_equal 80, @gen.clean_desc(long).length
  end
end

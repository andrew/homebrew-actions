require "json"
require "minitest/autorun"
require "stringio"
require "tmpdir"

load File.expand_path("../bin/setup-actions", __dir__)

class ActionsSetupTest < Minitest::Test
  def setup
    @directory = Dir.mktmpdir("homebrew-actions-test")
    @prefixes = File.join(@directory, "prefixes")
    @destination = File.join(@directory, "workspace", ".brew-actions")
    @brewfile = File.join(@directory, "Actionfile")
    @config = File.join(@directory, "brew.json")
    @brew = File.join(@directory, "brew")

    create_formula("pre-commit-action", "uses: ./.brew-actions/actions-cache\n")
    create_formula("actions-cache", "runs:\n  using: node20\n")
    File.write(File.join(@prefixes, "actions-cache", ".metadata"), "copied\n")
    File.write(@brewfile, <<~RUBY)
      tap "andrew/actions"
      brew "andrew/actions/pre-commit-action"
    RUBY
    File.write(@config, JSON.generate(
      "prefixes" => {
        "andrew/actions/pre-commit-action" => File.join(@prefixes, "pre-commit-action"),
        "andrew/actions/actions-cache" => File.join(@prefixes, "actions-cache")
      },
      "dependencies" => {
        "andrew/actions/pre-commit-action" => ["andrew/actions/actions-cache"],
        "andrew/actions/actions-cache" => []
      }
    ))
    File.write(@brew, fake_brew)
    FileUtils.chmod("+x", @brew)
  end

  def teardown
    FileUtils.remove_entry(@directory)
  end

  def test_installs_requested_actions_and_their_action_dependencies
    output = StringIO.new
    ENV["FAKE_BREW_CONFIG"] = @config

    ActionsSetup.new(
      brewfile: @brewfile,
      destination: @destination,
      brew: @brew,
      stdout: output
    ).run

    assert File.exist?(File.join(@destination, "pre-commit-action", "action.yml"))
    assert File.exist?(File.join(@destination, "actions-cache", "action.yml"))
    assert File.exist?(File.join(@destination, "actions-cache", ".metadata"))
    assert_includes output.string, "Installed pre-commit-action"
    assert_includes output.string, "Installed actions-cache"
  ensure
    ENV.delete("FAKE_BREW_CONFIG")
  end

  def test_rejects_a_brewfile_without_formulae
    File.write(@brewfile, "tap \"andrew/actions\"\n")
    ENV["FAKE_BREW_CONFIG"] = @config

    error = assert_raises(RuntimeError) do
      ActionsSetup.new(
        brewfile: @brewfile,
        destination: @destination,
        brew: @brew
      ).run
    end

    assert_match "No action formulae found", error.message
  ensure
    ENV.delete("FAKE_BREW_CONFIG")
  end

  def create_formula(name, action_yml)
    prefix = File.join(@prefixes, name)
    FileUtils.mkdir_p(prefix)
    File.write(File.join(prefix, "action.yml"), action_yml)
  end

  def fake_brew
    <<~'RUBY'
      #!/usr/bin/env ruby
      require "json"

      config = JSON.parse(File.read(ENV.fetch("FAKE_BREW_CONFIG")))
      case ARGV.first
      when "bundle"
        exit 0
      when "--prefix"
        puts config.fetch("prefixes").fetch(ARGV.fetch(1))
      when "deps"
        formula = ARGV.last
        puts config.fetch("dependencies").fetch(formula).join("\\n")
      else
        warn "Unexpected brew command: #{ARGV.join(" ")}"
        exit 1
      end
    RUBY
  end
end

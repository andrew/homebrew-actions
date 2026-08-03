class ActionsCache < Formula
  desc "Cache dependencies and build outputs in GitHub Actions workflows"
  homepage "https://github.com/actions/cache"
  url "https://github.com/actions/cache/archive/1bd1e32a3bdc45362d1e726936510720a7c30a57.tar.gz"
  version "4.2.0"
  sha256 "4e293cf261538771f29a01801c30be0a2d3bef2b391526f1e574badb79214a59"
  license "MIT"

  def install
    prefix.install Dir.children(".")
  end

  test do
    assert_path_exists prefix/"action.yml"
  end
end

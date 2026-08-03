class ActionsCache < Formula
  desc "Cache dependencies and build outputs in GitHub Actions workflows"
  homepage "https://github.com/actions/cache"
  url "https://github.com/actions/cache/archive/1bd1e32a3bdc45362d1e726936510720a7c30a57.tar.gz"
  version "4.2.0"
  sha256 "04523be49fd8fac671770ad0c12f5c4cc68aaf03e01e8ca8dd6b641a9548b4e7"
  license "MIT"

  def install
    prefix.install Dir.children(".")
  end

  test do
    assert_path_exists prefix/"action.yml"
  end
end

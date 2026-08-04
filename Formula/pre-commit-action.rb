class PreCommitAction < Formula
  desc "Run pre-commit in a GitHub Actions workflow"
  homepage "https://github.com/pre-commit/action"
  url "https://github.com/pre-commit/action/archive/2c7b3805fd2a0fd8c1884dcaebf91fc102a13ecd.tar.gz"
  version "3.0.1"
  sha256 "efab91d340ab4de9e2d18e0d1f3ab2c4a05ed9e3cfaddd781d20fde5e22f8e6a"
  license "MIT"

  depends_on "andrew/actions/actions-cache"

  def install
    inreplace "action.yml",
      "uses: actions/cache@v4",
      "uses: $/../actions-cache"
    prefix.install Dir.children(".")
  end

  test do
    assert_match "uses: $/../actions-cache", (prefix/"action.yml").read
  end
end

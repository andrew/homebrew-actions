class PreCommitAction < Formula
  desc "Run pre-commit in a GitHub Actions workflow"
  homepage "https://github.com/pre-commit/action"
  url "https://github.com/pre-commit/action/archive/2c7b3805fd2a0fd8c1884dcaebf91fc102a13ecd.tar.gz"
  version "3.0.1"
  sha256 "040ddd3b2259e51dd75cd71657281b0bcc8e58a5ee9d2dc592c2e19a1971ec9b"
  license "MIT"

  depends_on "andrew/actions/actions-cache"

  def install
    inreplace "action.yml",
      "uses: actions/cache@v4",
      "uses: ./../actions-cache"
    prefix.install Dir.children(".")
  end

  test do
    assert_match "uses: ./../actions-cache", (prefix/"action.yml").read
  end
end

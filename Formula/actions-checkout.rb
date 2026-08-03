class ActionsCheckout < Formula
  desc "Checkout a Git repository at a particular version"
  homepage "https://github.com/actions/checkout"
  url "https://github.com/actions/checkout/archive/3d3c42e5aac5ba805825da76410c181273ba90b1.tar.gz"
  version "7.0.1"
  sha256 "03ff5a6d7c5bdee7e3c1d9eee1453a3e980a9ef6666cee3687a427e9ec913af9"
  license "MIT"

  def install
    prefix.install Dir.children(".")
  end

  test do
    assert_path_exists prefix/"action.yml"
  end
end

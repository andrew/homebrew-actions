class ActionsCheckout < Formula
  desc "Checkout a Git repository at a particular version"
  homepage "https://github.com/actions/checkout"
  url "https://github.com/actions/checkout/archive/3d3c42e5aac5ba805825da76410c181273ba90b1.tar.gz"
  version "7.0.1"
  sha256 "b59292069298c7be5ffd9c636431a229faff70ece00e0c24fd31baeb7b309fa3"
  license "MIT"

  def install
    prefix.install Dir.children(".")
  end

  test do
    assert_path_exists prefix/"action.yml"
  end
end

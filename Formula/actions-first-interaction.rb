class ActionsFirstInteraction < Formula
  desc "Greet contributors when they open their first issue or pull request"
  homepage "https://github.com/actions/first-interaction"
  url "https://github.com/actions/first-interaction/archive/34f15e814fe48ac9312ccf29db4e74fa767cbab7.tar.gz"
  version "1.3.0"
  sha256 "399d7824aa439780486f357b28bf60f06ca6662f24174e87c263084a2e8ace72"
  license "MIT"

  def install
    prefix.install Dir.children(".")
  end

  test do
    assert_path_exists prefix/"action.yml"
    assert_path_exists prefix/"Dockerfile"
  end
end

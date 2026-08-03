class ActionsFirstInteraction < Formula
  desc "Greet contributors when they open their first issue or pull request"
  homepage "https://github.com/actions/first-interaction"
  url "https://github.com/actions/first-interaction/archive/34f15e814fe48ac9312ccf29db4e74fa767cbab7.tar.gz"
  version "1.3.0"
  sha256 "a01ff8594422dbf0a26ae686a6699650da8476fed8b9157dc07202aefa64ce96"
  license "MIT"

  def install
    prefix.install Dir.children(".")
  end

  test do
    assert_path_exists prefix/"action.yml"
    assert_path_exists prefix/"Dockerfile"
  end
end

class Sqlc < Formula
  desc "Generate type safe Go from SQL"
  homepage "https://sqlc.dev/"
  url "https://github.com/kyleconroy/sqlc/archive/v1.7.0.tar.gz"
  sha256 "bdd425c6087d8115b622a1e0f9251a2d7c645ac2b1a3519621e4a39983a57387"
  license "MIT"
  head "https://github.com/kyleconroy/sqlc.git"

  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "0e3aefdd8b650ac9e29021a2ab29188902a1d3296eaa63f7150c22da26474de1"
    sha256 cellar: :any_skip_relocation, big_sur:       "67ec941540b1c125e991d493eb418cddadda8a0c4cebd6b7f4ac9e32947b1fea"
    sha256 cellar: :any_skip_relocation, catalina:      "5463145e573a3c4e79fb4b8a5ba22432962bf28e8f4594ca8914dfa18ba62b56"
    sha256 cellar: :any_skip_relocation, mojave:        "8ecd01378e5828f38cc5a2082a2a3e5e586a68d7046e3ef0008687a2fd7fc095"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args, "-ldflags", "-s -w", "./cmd/sqlc"
  end

  test do
    (testpath/"sqlc.json").write <<~SQLC
      {
        "version": "1",
        "packages": [
          {
            "name": "db",
            "path": ".",
            "queries": "query.sql",
            "schema": "query.sql",
            "engine": "postgresql"
          }
        ]
      }
    SQLC

    (testpath/"query.sql").write <<~EOS
      CREATE TABLE foo (bar text);

      -- name: SelectFoo :many
      SELECT * FROM foo;
    EOS

    system bin/"sqlc", "generate"
    assert_predicate testpath/"db.go", :exist?
    assert_predicate testpath/"models.go", :exist?
    assert_match "// Code generated by sqlc. DO NOT EDIT.", File.read(testpath/"query.sql.go")
  end
end

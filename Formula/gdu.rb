class Gdu < Formula
  desc "Disk usage analyzer with console interface written in Go"
  homepage "https://github.com/dundee/gdu"
  url "https://github.com/dundee/gdu/archive/v5.1.1.tar.gz"
  sha256 "fb1a76562947e34fec16fd650f03793ccc5afe04fa6ba817639d92f55a1f927b"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "4b3a6376a2a2506a371627bc1645afe36dd049a7cd22c552297485ad2867f0ac"
    sha256 cellar: :any_skip_relocation, big_sur:       "0a3a45756fc7c6cf55c0514d2db1ff50e13a5a253096d914a1325270ba125a67"
    sha256 cellar: :any_skip_relocation, catalina:      "e702c4c3d87925b5c05df167b491a62fdfff055799260cb74b6ee3876f052f70"
    sha256 cellar: :any_skip_relocation, mojave:        "ab55faf95a13af48b2c6b319e74fbbd15e328cc230c36c36c85fd9f05a304abc"
  end

  depends_on "go" => :build

  conflicts_with "coreutils", because: "both install `gdu` binaries"

  def install
    ENV["TZ"] = "UTC"
    time = Time.at(ENV["SOURCE_DATE_EPOCH"].to_i)
    user = Utils.safe_popen_read("id", "-u", "-n")
    major = version.major

    ldflags = %W[
      -s -w
      -X "github.com/dundee/gdu/v#{major}/build.Version=v#{version}"
      -X "github.com/dundee/gdu/v#{major}/build.Time=#{time}"
      -X "github.com/dundee/gdu/v#{major}/build.User=#{user}"
    ]

    system "go", "build", *std_go_args(ldflags: ldflags.join(" ")), "github.com/dundee/gdu/v#{major}/cmd/gdu"
  end

  test do
    mkdir_p testpath/"test_dir"
    (testpath/"test_dir"/"file1").write "hello"
    (testpath/"test_dir"/"file2").write "brew"

    assert_match version.to_s, shell_output("#{bin}/gdu -v")
    assert_match "colorized", shell_output("#{bin}/gdu --help 2>&1")
    assert_match "4.0 KiB file1", shell_output("#{bin}/gdu --non-interactive --no-progress #{testpath}/test_dir 2>&1")
  end
end

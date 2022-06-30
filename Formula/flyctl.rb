class Flyctl < Formula
  desc "Command-line tools for fly.io services"
  homepage "https://fly.io"
  url "https://github.com/superfly/flyctl.git",
      tag:      "v0.0.344",
      revision: "c46f5c3a6464b7b1b7a6d686e4caf8fedf7c96e1"
  license "Apache-2.0"
  head "https://github.com/superfly/flyctl.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "931b21c1831415b1fc978db240a82f52677561f4fcc422c72e7bc5e73c94c8ac"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "931b21c1831415b1fc978db240a82f52677561f4fcc422c72e7bc5e73c94c8ac"
    sha256 cellar: :any_skip_relocation, monterey:       "b1df2885b385bf52e8197e5ce83b24450e74d79bbac69e43bb31599f15c61433"
    sha256 cellar: :any_skip_relocation, big_sur:        "b1df2885b385bf52e8197e5ce83b24450e74d79bbac69e43bb31599f15c61433"
    sha256 cellar: :any_skip_relocation, catalina:       "b1df2885b385bf52e8197e5ce83b24450e74d79bbac69e43bb31599f15c61433"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "deb4d3ef414f6c5e9a65a119fe6434e7272fe1c4c540988aaa7bdee21f70e9bb"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -s -w
      -X github.com/superfly/flyctl/internal/buildinfo.environment=production
      -X github.com/superfly/flyctl/internal/buildinfo.buildDate=#{time.iso8601}
      -X github.com/superfly/flyctl/internal/buildinfo.version=#{version}
      -X github.com/superfly/flyctl/internal/buildinfo.commit=#{Utils.git_short_head}
    ]
    system "go", "build", *std_go_args(ldflags: ldflags)

    bin.install_symlink "flyctl" => "fly"

    bash_output = Utils.safe_popen_read("#{bin}/flyctl", "completion", "bash")
    (bash_completion/"flyctl").write bash_output
    zsh_output = Utils.safe_popen_read("#{bin}/flyctl", "completion", "zsh")
    (zsh_completion/"_flyctl").write zsh_output
    fish_output = Utils.safe_popen_read("#{bin}/flyctl", "completion", "fish")
    (fish_completion/"flyctl.fish").write fish_output
  end

  test do
    assert_match "flyctl v#{version}", shell_output("#{bin}/flyctl version")

    flyctl_status = shell_output("flyctl status 2>&1", 1)
    assert_match "Error No access token available. Please login with 'flyctl auth login'", flyctl_status
  end
end

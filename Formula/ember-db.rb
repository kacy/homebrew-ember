class EmberDb < Formula
  desc "low-latency, memory-efficient distributed cache"
  homepage "https://github.com/kacy/ember"
  url "https://github.com/kacy/ember/archive/refs/tags/v0.4.5.tar.gz"
  sha256 "31e45f01607215fb968e2228af74136751a908781b55c849254ea32971ef37f8"
  license "MIT"
  head "https://github.com/kacy/ember.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "build", "--release",
      "--manifest-path", "Cargo.toml",
      "--bin", "ember-server",
      "--bin", "ember-cli"

    bin.install "target/release/ember-server"
    bin.install "target/release/ember-cli"
  end

  service do
    run [opt_bin/"ember-server"]
    keep_alive true
    log_path var/"log/ember.log"
    error_log_path var/"log/ember.log"
  end

  test do
    port = free_port
    pid = spawn bin/"ember-server", "--port", port.to_s, "--host", "127.0.0.1"
    sleep 1
    assert_match "PONG", shell_output("#{bin}/ember-cli -p #{port} PING")
  ensure
    Process.kill("TERM", pid)
  end
end

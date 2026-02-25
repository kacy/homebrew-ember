class EmberDb < Formula
  desc "low-latency, memory-efficient distributed cache"
  homepage "https://github.com/kacy/ember"
  url "https://github.com/kacy/ember/archive/refs/tags/v0.4.8.tar.gz"
  sha256 "e3b6e5592effd83a9a2ecd74d2ec08deccbfd6ee6ed5284218a4f995144bcbee"
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

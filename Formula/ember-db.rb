class EmberDb < Formula
  desc "low-latency, memory-efficient distributed cache"
  homepage "https://github.com/kacy/ember"
  url "https://github.com/kacy/ember/archive/refs/tags/v0.4.7.tar.gz"
  sha256 "fc8712d9afa72eb3995b9246f8dd62aca5b8e7be3b37de316e37bb520ce9acad"
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

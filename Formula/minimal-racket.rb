class MinimalRacket < Formula
  desc "Modern programming language in the Lisp/Scheme family"
  homepage "https://racket-lang.org/"
  url "https://mirror.racket-lang.org/installers/8.0/racket-minimal-8.0-src-builtpkgs.tgz"
  sha256 "ef1a2dc5af4e68938a12f5fc25d1a9b3a0344e133da9c4d79132e23ac116493c"
  license any_of: ["MIT", "Apache-2.0"]

  livecheck do
    url "https://download.racket-lang.org/all-versions.html"
    regex(/>Version ([\d.]+)/i)
  end

  bottle do
    sha256 big_sur:  "e505c77a1703d75d214e081250cff9cbdbb13d604f8995703bd96f5a5454803d"
    sha256 catalina: "68ce8bdaed9890086696fe63ce655c994848e58da24040363441bdc6eaa0d9d6"
    sha256 mojave:   "4fd0070df83c2d0761bc64e31b479f776f9cee55fe51a770811748706742e528"
  end

  uses_from_macos "libffi"

  # these two files are amended when (un)installing packages
  skip_clean "lib/racket/launchers.rktd", "lib/racket/mans.rktd"

  def install
    # configure racket's package tool (raco) to do the Right Thing
    # see: https://docs.racket-lang.org/raco/config-file.html
    inreplace "etc/config.rktd", /\)\)\n$/, ") (default-scope . \"installation\"))\n"

    cd "src" do
      args = %W[
        --disable-debug
        --disable-dependency-tracking
        --enable-origtree=no
        --enable-macprefix
        --prefix=#{prefix}
        --mandir=#{man}
        --sysconfdir=#{etc}
        --enable-useprefix
      ]

      system "./configure", *args
      system "make"
      system "make", "install"
    end
  end

  def caveats
    <<~EOS
      This is a minimal Racket distribution.
      If you want to build the DrRacket IDE, you may run:
        raco pkg install --auto drracket

      The full Racket distribution is available as a cask:
        brew install --cask racket
    EOS
  end

  test do
    output = shell_output("#{bin}/racket -e '(displayln \"Hello Homebrew\")'")
    assert_match /Hello Homebrew/, output

    # show that the config file isn't malformed
    output = shell_output("'#{bin}/raco' pkg config")
    assert $CHILD_STATUS.success?
    assert_match Regexp.new(<<~EOS), output
      ^name:
        #{version}
      catalogs:
        https://download.racket-lang.org/releases/#{version}/catalog/
        https://pkgs.racket-lang.org
        https://planet-compats.racket-lang.org
      default-scope:
        installation
    EOS
  end
end

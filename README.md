# httpbinner
A tool to group urls based on similarity

## Installation

### Prebuilt binaries

Download the archive for your platform from
[GitHub Releases](https://github.com/Gustavo-Blois/httpbinner/releases):

| Archive | Platform | Runtime dependencies |
| --- | --- | --- |
| `httpbinner-linux-x86_64.tar.gz` | Ubuntu 22.04 or newer, x86_64 | `libgmp10`, OpenSSL 3, CA certificates |
| `httpbinner-macos-x86_64.tar.gz` | macOS 15 or newer, Intel | Homebrew `gmp` and `openssl@3` |
| `httpbinner-macos-arm64.tar.gz` | macOS 15 or newer, Apple Silicon | Homebrew `gmp` and `openssl@3` |

Install runtime dependencies on Ubuntu 22.04:

```sh
sudo apt-get update
sudo apt-get install libgmp10 libssl3 ca-certificates
```

On Ubuntu 24.04, use `libssl3t64` instead of `libssl3`. On macOS:

```sh
brew install gmp openssl@3
```

Extract your downloaded archive and put the executable on your PATH. For example,
on Linux:

```sh
tar -xzf httpbinner-linux-x86_64.tar.gz
mkdir -p "$HOME/.local/bin"
install -m 755 httpbinner "$HOME/.local/bin/httpbinner"
export PATH="$HOME/.local/bin:$PATH"
httpbinner --help
```

Add the PATH setting to your shell configuration to keep it across sessions.
Archives include the license, README, and a list of linked libraries.
Releases include `SHA256SUMS`; verify downloads with `sha256sum --check
--ignore-missing SHA256SUMS` on Linux, or `shasum -a 256` on macOS and compare
the result with the matching entry. macOS binaries are not notarized or signed
with an Apple Developer certificate.

### Build from source

With Git and opam installed and an OCaml switch configured, install from the
repository (tested with OCaml 5.4.1):

```sh
git clone https://github.com/Gustavo-Blois/httpbinner.git
cd httpbinner
opam install .
eval "$(opam env)"
httpbinner --help
```

opam installs the dependencies and builds the `httpbinner` executable. If you
have not initialized opam yet, run `opam init` first.

## Usage

Read one URL per line from standard input:

```sh
cat urls.txt | httpbinner -t 20 -H 'Accept: text/html' -c 4 -s -o bins.txt
```

- `-t, --threshold INT`: group fingerprints with a Hamming distance below this value (default: 20; nonnegative).
- `-H, --header HEADER`: add a `Name: Value` request header; may be repeated.
- `-c, --concurrency INT`: maximum concurrent requests (default: 4; positive).
- `-o, --output FILE`: write results to this file, replacing its contents, instead of stdout.
- `-s, --silent`: output only one representative URL per bin and suppress request errors.

Without `--silent`, each bin prints its representative URL, fingerprint, and
semicolon-separated member URLs on three lines. Empty input lines are ignored.
Failed requests and responses with no tokens are excluded from bins.

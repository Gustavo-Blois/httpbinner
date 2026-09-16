# httpbinner
A tool to group urls based on similarity

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

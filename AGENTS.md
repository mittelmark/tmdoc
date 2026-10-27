# AGENTS.md

Guidance for coding agents working in this repository.

## What this project is

**tmdoc** is a Tcl package and standalone application for **literate
programming**: it evaluates embedded code chunks inside documentation files
(Markdown, AsciiDoc, Typst, Quarkdown, LaTeX) and writes the results back into
the document. It supports code chunks for R, Python, Octave, Julia, Tcl and
Shell, plus extensions for:

- **Diagrams** via the Kroki web service (`dia2kroki`, local `dot`/`plantuml`
  check),
- **LaTeX equations** (MathJax / `math.vercel.app`),
- **YAML abbreviations** (`--abbrev file.yml` expands `{.abbrev}`),
- **Citations / bibliography** (BibTeX files, via the `citer` package),
- **CSV tables** (`tmdoc::csv`),
- **Chemical equations** (`filter-tcrd`),
- **chord shapes and string-instrument chords** (`filter-tcrd`),
- **Markdown alerts**, **block diagrams** (`tblocks`),
- **table of contents** generation (`--toc true`).

Current version: **0.20.0**. License: **BSD-3-Clause** (file `LICENSE`).
Upstream: <https://github.com/mittelmark/tmdoc>. The companion package
**mndoc** (a separate repo, <https://github.com/mittelmark/mndoc>) converts the
resulting Markdown/AsciiDoc/Typst to HTML; `mndoc` is **not** bundled here.

`tmdoc` started as an extension of the Tcllib `mkdoc` package.

## Repository layout

| Path | Purpose |
| --- | --- |
| `modules/tmdoc/tmdoc.tcl` | **Main source of truth**: library + CLI logic + embedded manual (`#'` comments) |
| `modules/tmdoc/pkgIndex.tcl` | Package index; version used by the Makefile |
| `modules/tmdoc/filter-*.tcl` | language/output filters (Julia, R, Octave, Python, tcl, tcrd, mtex, abbrev) |
| `modules/tmdoc/filter-*.tmd`, `.html` | test inputs / reference outputs for the filters |
| `modules/tmdoc/abbrev.yml` | sample YAML abbreviation file |
| `modules/tmdoc/assets/` | data files used by tests (`class.pml`, `table.pml`, `music.txt`) |
| `modules/tmdoc/tmdoc.test` | tcltest regression suite (the supported test entry point) |
| `modules/tmdoc/tmdoc.sty` | LaTeX template fragment |
| `modules/tmdoc/Makefile` | builds docs (weasyprint) and runs `tmdoc.test` |
| `apps/tmdoc` | launcher: `package require tmdoc; ::tmdoc::main $argv` |
| `apps/tmdoc.man`, `apps/tmdoc.html` | Doctools man page and generated HTML |
| `Makefile` | top-level build (`make app|docu|test`) |
| `bin/install-tmdoc.sh`, `bin/tmdoc-update` | installer and self-updater for `~/.local/bin` |
| `bin/encoding.tcl` | encoding helper script |
| `examples/` | sample `.tmd`/`.tdoc`/`.ttyp`/`.tqd` inputs and reference HTML |
| `tests/` | a few small test fixtures (`empty.tmd`, `umlauts.Rmd`) |

## Dependencies and sibling checkouts

The source tree itself only tracks `modules/tmdoc/`. The **build** and the
**test** assume a specific local directory layout (all paths are
`~/workspace/...`):

- Tcllib modules are vendored into `modules/<name>/` on demand by the Makefile
  targets (`fileutil`, `cmdline`, `bibtex`, `markdown`, `textutil`, `yaml`
  are downloaded from Tcllib; `citer`, `tdot`, `tsvg`, `tblocks`, `tcrd`
  from their own repos). The Makefile also copies from `~/workspace/tcllib`
  and `~/workspace/tcrd`, `~/workspace/tsvg`, `~/workspace/tblocks` for the
  `app` target.
- **The fetched `modules/` subdirectories are NOT tracked in git** (see
  `.gitignore`). They are downloaded on demand from **pinned commits** — the
  `*_REF` variables at the top of the `Makefile`. To reproduce a build, the
  pins must match; to bump a dependency, update the corresponding `*_REF` and
  re-run the fetch target.
- `modules/tmdoc/Makefile` and `examples/Makefile` call `~/workspace/mndoc`
  (a sibling of this repo) to convert `.md` to HTML, and
  `~/workspace/tcllib` for `dtlite`.

Consequences:

- `make test` / `make docu` / `make app` are **developer-environment
  specific** and assume a `~/workspace/` layout of sibling checkouts. On this
  machine only `~/workspace/mndoc` exists; `tcllib`, `tcrd`, `tsvg` and
  `tblocks` are missing, so `make app`/`make docu` will fail here. Do not
  assume these targets run in isolation.
- To run the *package* tests only:
  ```sh
  cd modules/tmdoc
  TCLLIBPATH=.. tclsh tmdoc.test
  ```
  This needs the vendored dependency modules under `modules/` (see above).

## Run from source

The launcher `apps/tmdoc` needs the bundled package on the path:

```sh
export TCLLIBPATH="$PWD/modules"
tclsh apps/tmdoc input.tmd output.md --mode weave
tclsh apps/tmdoc input.tmd --mode tangle          # extract Tcl code only
tclsh apps/tmdoc input.tmd output.md --abbrev abbrev.yml --toc true
tclsh apps/tmdoc --help
```

`--mode weave` evaluates the code chunks; `--mode tangle` extracts Tcl code.
If the output file is not given (or is `-`), output goes to stdout.

Prebuilt standalone binary (requires an installed Tcl/Tk):

```sh
tmdoc-0.20.0.bin input.tmd output.html --css tmdoc.css
```

## Build

```sh
make app
```

What it does (top-level `Makefile`):

1. Creates `app-build/tmdoc.vfs/lib/` with subdirs for `tmdoc`, `bibtex`,
   `citer`, `cmdline`, `fileutil`, `markdown`, `textutil`, `yaml`, `tdot`,
   `tcrd`, `tsvg`, `tblocks`.
2. Copies `modules/tmdoc/*.tcl` and `tmdoc.sty` into the VFS, plus the
   vendored dependency modules (downloaded on demand into `modules/` by the
   sub-targets `fileutil`, `cmdline`, `bibtex`, `markdown`, `yaml`, `textutil`,
   `citer`, `tdot tsvg tblocks`).
3. Runs `tpack wrap tmdoc.tapp --lz4` (the `tpack` bundler from a sibling
   checkout) to produce the single-file `tmdoc.tapp`, and copies it to
   `bin/tmdoc-<version>.bin`.

Consequences:

- The build needs **`tpack` on the PATH** (from the `~/workspace/tpack`
  sibling), network access for the vendored modules, and `tclsh`.
- `make app` **overwrites** `app-build/` and `bin/tmdoc-*.bin`. Do not
  hand-edit generated artifacts.
- `TCL9` in the Makefile points at `~/.local/opt/bin/tclsh9.0`; the package is
  Tcl 8.6+ and Tcl 9 aware.

## Documentation (`make docu`)

```sh
make docu
```

Uses `../tcllib/apps/dtplite` to render `modules/tmdoc/tmdoc.man` →
`modules/tmdoc/tmdoc.html` and `apps/tmdoc.man` → `apps/tmdoc.html`, then runs
`weasyprint` to produce `tmdoc.pdf` and `tmdoc-tutorial.pdf`. Requires the
`tcllib` sibling and `weasyprint`; it will fail without them.

The manual is also embedded in `modules/tmdoc/tmdoc.tcl` as `#'` comments; the
`doctools` man pages (`tmdoc.man`) are the canonical form.

## Tests

The supported test entry point is the tcltest suite:

```sh
cd modules/tmdoc && TCLLIBPATH=.. tclsh -encoding cp1252 tmdoc.test
```

(all 64 tests pass on a machine with `octave`, `julia`, `dot`/graphviz and
`plantuml` installed — the external-tool tests fail without them.)

- 60+ `tcltest::test` cases cover `tmdoc::tmeval`, `include`, code-chunk
  options (`echo=false`, `eval=false`), abbreviations, CSV tables, tcrd
  (chords / chemical equations) and tsvg output.
- The file is **ISO-8859-1 / cp1252 encoded** (umlauts). A plain UTF-8
  `tclsh` rejects it with "invalid or incomplete multibyte character", so run
  it with `-encoding cp1252`. `make test` already passes this flag.
- `tests/` holds small standalone fixtures; `modules/tmdoc/test-man.tman`
  validates the Doctools man page (`tclsh ../../apps/tmdoc test-man.tman
  test-man.man`).

## Version bumps

The version appears in several independent places. Update all of them:

1. `modules/tmdoc/tmdoc.tcl` — history header at the top, both `package
   provide` lines, and the `CHANGES` section near the end.
2. `modules/tmdoc/pkgIndex.tcl` — both `package ifneeded` lines (the Makefile
   reads the version from here).
3. `modules/tmdoc/tmdoc.man` and `apps/tmdoc.man` — `[vset VERSION ...]`.
4. `README.md` — ChangeLog / version notes.

Regenerate the manual/HTML/PDF via `make docu` after the bump.

## Code conventions

- Tcl 8.6-compatible code; `package require Tcl 8.6-`. Keep Tcl 9 working.
- 4-space indentation, opening brace on the same line.
- Public entry points:
  - `::tmdoc::tmdoc infile outfile ?--mode weave|tangle? ?--abbrev f.yml?
    ?--toc true?` — the document processor,
  - `::tmdoc::tmeval text ?ext tmd?` — evaluate a code chunk / filter string,
  - `::tmdoc::main argv` — command-line handling.
- Options are `--long-option value` pairs; keep the option list in `main`
  (`valid_args`/`GetOpts`) and the `Usage` text in sync.
- The manual is embedded in `modules/tmdoc/tmdoc.tcl` as `#'` comments;
  user-facing behaviour changes should be documented there and in `README.md`.
- HTML is assembled with `string map`/`subst`/regexes. Keep changes small and
  test against `modules/tmdoc/filter-*` and `examples/`.

## Known issues and pitfalls

- `make test` needs the sibling checkouts
  (`mndoc`, `tcllib`, `tcrd`, `tsvg`, `tblocks`) to exist in `~/workspace/`;
  use the direct `modules/tmdoc` invocation with `TCLLIBPATH=..` instead for
  the package tests.
- `tmdoc.test` is cp1252/ISO-8859-1 encoded; a plain UTF-8 `tclsh` may reject
  it ("invalid or incomplete multibyte character"). Use `-encoding cp1252`.
- `README.md` install snippets still reference older pinned binaries
  (`v0.19.1`, `v0.14.1`, `v0.17.2`); the current version is **0.20.0**.
- The fetched `modules/` dependencies are pinned to specific commits in the
  `Makefile` (`TCLLIB_REF`, `CITER_REF`, `TDOT_REF`, `TBLOCKS_REF`, `TSVG_REF`,
  `TCRD_REF`); bump a pin only when you intentionally need a newer dependency
  version.
- `mndoc` is a separate repository (sibling `~/workspace/mndoc`); it is not
  vendored here, so HTML conversion steps in the examples need it present.

## Useful one-liners

```sh
# run the regression suite from source
cd modules/tmdoc && TCLLIBPATH=.. tclsh -encoding cp1252 tmdoc.test

# convert a .tmd to markdown, then to HTML with mndoc
TCLLIBPATH="$PWD/modules" tclsh apps/tmdoc examples/c.tmd /tmp/c.md --mode weave
TCLLIBPATH="$HOME/workspace/mndoc/modules" tclsh "$HOME/workspace/mndoc/apps/mndoc" /tmp/c.md /tmp/c.html --css modules/tmdoc/tmdoc.css

# show version / help
TCLLIBPATH="$PWD/modules" tclsh apps/tmdoc --version
TCLLIBPATH="$PWD/modules" tclsh apps/tmdoc --help
```

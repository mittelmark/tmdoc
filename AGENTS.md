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

Current version: **0.20.1**. License: **BSD-3-Clause** (file `LICENSE`).
Upstream: <https://github.com/mittelmark/tmdoc>. The companion package
**mndoc** (a separate repo, <https://github.com/mittelmark/mndoc>) converts the
resulting Markdown/AsciiDoc/Typst to HTML; `mndoc` is **not** bundled here.
The `install-tmdoc.sh` installer installs both `tmdoc` **and** the latest
`mndoc` release, so a full installation also picks up mndoc fixes (e.g. the
non-ISO date normalizer in mndoc 0.15.5) without bundling mndoc.

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
| `modules/mndoc/` | **fetched, not tracked**: pinned mndoc source (v0.17.0) + launcher `mndoc-app.tcl` used by the `.md` → HTML steps (see `make mndoc`) |
| `tools/dtplite.tcl` | lightweight doctools man-page → HTML generator (replaces the tcllib-sibling `dtlite`) |
| `tools/doctools/` | vendored Tcllib doctools package + `mpformats/` (used by `dtlite.tcl`; self-contained, no tcllib sibling needed) |

## Dependencies and sibling checkouts

The source tree itself only tracks `modules/tmdoc/`. The **build** and the
**test** assume a specific local directory layout (all paths are
`~/workspace/...`):

- Tcllib modules are vendored into `modules/<name>/` on demand by the Makefile
  targets (`fileutil`, `cmdline`, `bibtex`, `markdown`, `textutil`, `yaml`
  are downloaded from Tcllib; `citer`, `tdot`, `tsvg`, `tblocks`, `tcrd`
  from their own repos; `mndoc` from the mndoc repo, pinned to
  `MNDOC_REF` = v0.17.0). Each is pinned to a commit in the `Makefile`.
- **The fetched `modules/` subdirectories are NOT tracked in git** (see
  `.gitignore`). They are downloaded on demand from **pinned commits** — the
  `*_REF` variables at the top of the `Makefile`. To reproduce a build, the
  pins must match; to bump a dependency, update the corresponding `*_REF` and
  re-run the fetch target.
- `make app` and the man-page HTML step of `make docu` are **self-contained**:
  they fetch the vendored modules from the network and use `tools/dtplite.tcl`
  + the vendored `tools/doctools`. No sibling checkouts are required.
- The `.md` → HTML steps of `modules/tmdoc/Makefile` (tutorial, `filter-*`,
  `test-eq`) and `examples/Makefile` use the **fetched mndoc source**
  (`modules/mndoc/`, via `make mndoc`) instead of a sibling `~/workspace/mndoc`
  checkout. The mndoc fetch targets are prerequisites of those make targets,
  so a plain `make` of them fetches mndoc on demand (network, first run only).
  mndoc is **not** part of the tmdoc app bundle; `install-tmdoc.sh` installs
  the mndoc release binary separately.

Consequences:

- `make test` is fully self-contained: it fetches the vendored modules and
  runs the tcltest suite (with `-encoding cp1252`). It needs network on the
  first run only.
- `make app` and the man-page HTML of `make docu` are self-contained too;
  they need `tclsh` (+ `weasyprint` for the PDFs) and the `tpack` bundler
  (`~/.local/bin/tpack` or the `~/workspace/tpack` sibling).
- `make docu`'s tutorial steps (in `modules/tmdoc/Makefile`) need the
  fetched mndoc source (`make mndoc`, pinned to `MNDOC_REF`) plus
  `weasyprint`; the fetch happens automatically as a make prerequisite.
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
tmdoc-0.20.1.bin input.tmd output.html --css tmdoc.css
```

## Build

```sh
make app
```

What it does (top-level `Makefile`):

1. Creates a top-level `tmdoc.vfs/lib/` with subdirs for `tmdoc`, `bibtex`,
   `citer`, `cmdline`, `fileutil`, `markdown`, `textutil`, `yaml`, `tdot`,
   `tcrd`, `tsvg`, `tblocks`.
2. Copies `modules/tmdoc/*.tcl` + `tmdoc.sty` and every vendored dependency
   module (`modules/<name>/`, fetched on demand by the sub-targets and pinned
   to commits) into the VFS.
3. Wraps it into a single-file `tmdoc.tapp` (lz4-compressed) using `tpack`
   (resolved from `~/.local/bin/tpack` or the `~/workspace/tpack` sibling),
   and copies it to `bin/tmdoc-<version>.bin`.

Consequences:

- The build is **self-contained** with respect to the module sources: it
  archives a top-level `tmdoc.vfs/` (not an `app-build/` wrapper), so the
  tpack loader finds `main.tcl` at the right level.
- It needs **`tpack`** (`~/.local/bin/tpack` or `~/workspace/tpack/tpack-b64.tcl`),
  network access for the vendored modules (only on first fetch), and `tclsh`.
- `make app` **overwrites** `tmdoc.vfs/`, `tmdoc.tapp`, `tmdoc.tcl` and
  `bin/tmdoc-*.bin`. Do not hand-edit generated artifacts.
- `TCL9` in the Makefile points at `~/.local/opt/bin/tclsh9.0`; the package is
  Tcl 8.6+ and Tcl 9 aware.

## Documentation (`make docu`)

```sh
make docu
```

Uses `tools/dtplite.tcl` (a lightweight doctools man-page → HTML generator
backed by the vendored `tools/doctools` package + `modules/textutil`) to
render `modules/tmdoc/tmdoc.man` → `modules/tmdoc/tmdoc.html` and
`apps/tmdoc.man` → `apps/tmdoc.html`. Needs only `tclsh` + the repo's vendored
`modules/textutil` — it no longer requires the `tcllib` sibling. The
`tmdoc-tutorial.html`/`tmdoc.pdf` steps (in `modules/tmdoc/Makefile`) use the
fetched mndoc source (`make mndoc`, pinned to `MNDOC_REF`) plus `weasyprint`
— no `~/workspace/mndoc` sibling needed.

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
- `make test` also runs shell-level CLI checks after the tcltest suite:
  identical output for options given before / between / after the file
  arguments, single-file stdout, the `-` outfile marker, unknown-option
  refusal, plus the `--upgrade` help entry and the refusal path (run with
  `env -i PATH=` so no curl/wget exists: status 1, "needs curl or wget";
  no live GitHub check, by design).

## Version bumps

The version appears in several independent places. Update all of them:

1. `modules/tmdoc/tmdoc.tcl` — history header at the top and both `package
   provide` lines (the version notes live in that header; there is no
   separate CHANGES section).
2. `modules/tmdoc/pkgIndex.tcl` — both `package ifneeded` lines (the Makefile
   reads the version from here).
3. `modules/tmdoc/tmdoc.man` and `apps/tmdoc.man` — `[vset VERSION ...]`.
4. `README.md` — ChangeLog / version notes.

Regenerate the manual/HTML/PDF via `make docu` after the bump.

## Code conventions

- Tcl 8.6-compatible code; `package require Tcl 8.6-`. Keep Tcl 9 working.
- 4-space indentation, opening brace on the same line.
- Public entry points:
  - `::tmdoc::tmdoc infile outfile ?-mode weave|tangle? ?-abbrev f.yml?
    ?-toc true?` — the document processor,
  - `::tmdoc::tmeval text ?ext tmd?` — evaluate a code chunk / filter string,
  - `::tmdoc::main argv` — command-line handling.
- CLI options are `--long-option value` pairs and may be given **before,
  between or after** the file arguments (single-pass parser in `main`, the
  mndoc 0.17.0 style): every dash argument must be in `valid_args` and
  consumes the argument right behind it as its value. `-` (the stdout marker
  for OUTFILE) is the only dash argument treated as a file. OUTFILE is
  optional; without it the output goes to stdout. Keep the `valid_args`
  list in `main` and the `Usage` text in sync.
- Value-less flags (`--help`, `--version`, `--license`, `--upgrade`) are
  handled by early `lsearch` branches in `main` and are deliberately **not**
  part of `valid_args` (which only feeds the value-pairing parse loop).
  `--upgrade` must **`exit` and never return** from `main`: the installer it
  runs may replace the very `tmdoc-*.bin` the interpreter is executing.
- CLI changes belong into the doctools man pages (`apps/tmdoc.man`,
  `modules/tmdoc/tmdoc.man`, regenerated via `make docu`) and `README.md`;
  there is no `#'` embedded manual in `tmdoc.tcl` (contrary to the older
  note in this file's layout table).
- HTML is assembled with `string map`/`subst`/regexes. Keep changes small and
  test against `modules/tmdoc/filter-*` and `examples/`.

## Known issues and pitfalls

- `make test` is self-contained (fetches the vendored modules, runs with
  `-encoding cp1252`); only the external-tool tests need `octave`, `julia`,
  `dot`/graphviz and `plantuml` installed.
- `make docu`'s man-page HTML step is self-contained (`tools/dtplite.tcl`);
  the tutorial/PDF steps in `modules/tmdoc/Makefile` need the fetched mndoc
  source (`make mndoc`, a make prerequisite there) and `weasyprint`.
- `tmdoc.test` is cp1252/ISO-8859-1 encoded; a plain UTF-8 `tclsh` may reject
  it ("invalid or incomplete multibyte character"). Use `-encoding cp1252`.
- `README.md` install snippets still reference older pinned binaries
  (`v0.19.1`, `v0.14.1`, `v0.17.2`); the current version is **0.20.1**.
- The fetched `modules/` dependencies are pinned to specific commits in the
  `Makefile` (`TCLLIB_REF`, `CITER_REF`, `TDOT_REF`, `TBLOCKS_REF`, `TSVG_REF`,
  `TCRD_REF`, `MNDOC_REF`); bump a pin only when you intentionally need a newer
  dependency version. The `tools/doctools` snapshot is likewise a pinned copy of
  Tcllib's doctools — refresh its `*.tcl` files and the `mpformats/` dir
  together if you bump doctools.
- `mndoc` is a separate repository; its source is fetched on demand into
  `modules/mndoc/` (pinned `MNDOC_REF` = v0.17.0) for the `.md` → HTML steps,
  but it is **not** bundled into the tmdoc app — `install-tmdoc.sh` installs
  the mndoc release binary separately. A sibling `~/workspace/mndoc` checkout
  is no longer required.
- `tmdoc --upgrade` (like `mndoc --upgrade`) needs `curl` (or `wget`) and
  network access; it refreshes only the standalone binaries in
  `~/.local/bin` (a source checkout uses `git pull`). The `--upgrade` branch
  in `main` must **`exit`, never return** (see code conventions).
- Tcl ARE quirk (hit while writing `latest-version`): a non-greedy `.*?`
  before a capture shortens the *whole* match, so the greedy star behind it
  collapses — `location:.*?/tag/v([0-9]...)` captures only the leading
  digit. The patterns in `latest-version` must stay greedy (a comment in
  the code says so).

## Useful one-liners

```sh
# run the regression suite from source
cd modules/tmdoc && TCLLIBPATH=.. tclsh -encoding cp1252 tmdoc.test

# convert a .tmd to markdown, then to HTML with the fetched mndoc
TCLLIBPATH="$PWD/modules" tclsh apps/tmdoc examples/c.tmd /tmp/c.md --mode weave
make mndoc
TCLLIBPATH="$PWD/modules" tclsh modules/mndoc/mndoc-app.tcl /tmp/c.md /tmp/c.html --css modules/tmdoc/tmdoc.css

# show version / help
TCLLIBPATH="$PWD/modules" tclsh apps/tmdoc --version
TCLLIBPATH="$PWD/modules" tclsh apps/tmdoc --help
```

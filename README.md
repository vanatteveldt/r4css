# Text Analysis in R for Media and Communication

An interactive Quarto book covering computational text analysis for media and communication researchers. Interactive code examples run directly in the browser via [quarto-live](https://r-wasm.github.io/quarto-live/) (WebAssembly — no server required).

## Prerequisites

| Tool | Minimum version | Install |
|---|---|---|
| R | 4.3 | [cran.r-project.org](https://cran.r-project.org/) |
| Quarto | 1.4 | [quarto.org](https://quarto.org/docs/get-started/) |
| renv | 1.0 | `install.packages("renv")` in R |

## Installation

### 1. Clone the repository

```sh
git clone https://github.com/your-org/your-repo.git
cd your-repo
```

### 2. Install the quarto-live extension

```sh
quarto add r-wasm/quarto-live
```

This downloads the extension into `_extensions/r-wasm/live/`. The `_extensions/` directory should be committed to version control so collaborators do not need to re-run this step.

### 3. Install R packages

Open R in the project directory (or open the project in RStudio). renv activates automatically via `.Rprofile`.

**To render the book** (production dependencies only — matches CI):

```r
renv::restore()
```

This installs the exact package versions pinned in `renv.lock` into the project-local library (`renv/library/`). It does not affect your system-wide R packages.

**To develop the book** (production + development dependencies, e.g. `languageserver` for VS Code):

```r
renv::install()
```

This reads [`DESCRIPTION`](DESCRIPTION) and installs everything under `Imports` *and* `Suggests`.

> **First time on a machine?** If renv itself is not yet installed, run `install.packages("renv")` first.

## Rendering the book

### Preview locally (live reload)

```sh
quarto preview
```

Opens the book in your browser and rebuilds changed chapters automatically.

### Full render

```sh
quarto render
```

Output goes to `_book/`. Open `_book/index.html` in any browser.

### Render a single chapter

```sh
quarto render chapters/06-sentiment.qmd
```

### Freeze behaviour

`_quarto.yml` sets `execute: freeze: auto`. Quarto caches chunk output in `_freeze/` and only re-executes a chapter when its source changes. Commit `_freeze/` to version control so collaborators get pre-computed output without re-running all code.

## Package management

This project uses [renv](https://rstudio.github.io/renv/) with [`DESCRIPTION`](DESCRIPTION) as the declarative source of truth — analogous to `pyproject.toml` with uv.

### Two kinds of dependencies

Both are declared in [`DESCRIPTION`](DESCRIPTION):

- **`Imports:`** — *production* dependencies. Packages used by the book itself (e.g. `tidyverse`). These go into `renv.lock` and are installed by CI when rendering the book.
- **`Suggests:`** — *development* dependencies. Tooling that is useful while authoring but not needed to render (e.g. `languageserver` for VS Code / LSP support). These are **not** written to `renv.lock` and are not installed in CI.

The separation is enforced by the `snapshot.dev: false` setting in [`renv/settings.json`](renv/settings.json), which tells `renv::snapshot()` to ignore `Suggests` when writing the lockfile.

### Adding a new package

1. Add the package to [`DESCRIPTION`](DESCRIPTION):
   - Under `Imports:` if it's used in the book itself.
   - Under `Suggests:` if it's only needed for development (editor tooling, linters, etc.).
2. Install it locally:
   ```r
   renv::install()
   ```
3. Refresh the lockfile:
   ```r
   renv::snapshot()
   ```
   This updates `renv.lock` for production packages. Dev-only packages (under `Suggests`) are deliberately not written to the lockfile, so this is a no-op for them.

### Everyday commands

| Task | Command |
|---|---|
| Install production deps only (matches CI) | `renv::restore()` |
| Install production + development deps | `renv::install()` |
| Record current production versions to `renv.lock` | `renv::snapshot()` |
| Check for drift between library and lockfile | `renv::status()` |
| Update a package to its latest version | `renv::update("pkg")` then `renv::snapshot()` |

### What is and is not committed

```
committed:
  DESCRIPTION        # declared dependencies (Imports = prod, Suggests = dev)
  renv.lock          # pinned versions of production deps only
  renv/settings.json # renv configuration (snapshot.dev: false)
  renv/activate.R    # renv bootstrapper
  .Rprofile          # activates renv on project open

not committed (in .gitignore):
  renv/library/      # installed binaries — rebuilt per machine/OS
  renv/staging/
```

## Repository structure

```
.
├── _quarto.yml             # Book configuration and render settings
├── index.qmd               # Preface
├── chapters/
│   ├── 01-introduction.qmd
│   ├── 02-getting-started.qmd
│   ├── 03-data-collection.qmd
│   ├── 04-preprocessing.qmd
│   ├── 05-exploratory.qmd
│   ├── 06-sentiment.qmd
│   ├── 07-topic-modeling.qmd
│   ├── 08-content-analysis.qmd
│   ├── 09-word-embeddings.qmd
│   └── references.qmd
├── references.bib          # BibTeX bibliography
├── DESCRIPTION             # Declared dependencies (Imports / Suggests)
├── renv.lock               # Pinned versions of production deps
├── renv/
│   ├── settings.json       # renv configuration
│   ├── activate.R          # renv bootstrapper
│   └── .gitignore
├── .Rprofile               # Activates renv on startup
├── .gitignore
└── data/                   # Local data files (gitignored)
```

## Contributing

1. Create a branch, make changes, run `quarto render` to check output.
2. If you added packages, follow the steps under [Adding a new package](#adding-a-new-package) and commit the resulting changes to `DESCRIPTION` (and `renv.lock` if it changed).
3. If you added chapters, update the `chapters:` list in `_quarto.yml`.
4. Open a pull request.

## License

*Add license here.*

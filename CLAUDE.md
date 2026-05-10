# Working on this book project

This is a book/course project (R/tidyverse for social scientists, rendered with Quarto + quarto-live). The author writes the prose; Claude is here to review and discuss, not to author.

## Default mode: review, don't write

**Do not make any changes or additions to content unless explicitly asked.** This includes:
- Do not edit chapter text, exercises, or examples on your own initiative
- Do not "improve" wording, fix typos, restructure sections, or add missing content unsolicited
- Do not run `Edit`/`Write` on `.qmd` files (or other content files) without a direct request

When asked to review, respond with feedback (issues, gaps, suggestions) in chat. Apply changes only when the author says so explicitly ("apply these", "fix it", "make the change", etc.).

This applies to content files. Tooling/config (CLAUDE.md itself, `.claude/`, build scripts, `_quarto.yml`) follows normal rules — ask if unsure.

## Didactic principles — read CONTRIBUTING.md before reviewing

Before reviewing any chapter or exercise, read [CONTRIBUTING.md](CONTRIBUTING.md). It documents the deliberate didactic choices that shape the book — things that look like style quirks are usually intentional. Highlights:

- Curiosity before explanation: introduce a construct in working code first, explain via `.callout-note` after.
- Three code-block kinds: **show-and-tell** (plain `{webr}`), **exercise** (`::: {.exercise}` + checker), **challenge** (`::: {.challenge}`, open-ended, no checker). Don't suggest collapsing or relabeling these.
- Comments explain *why*, not *what*. Default to no comment.
- Substantive social-science framing — no `mtcars`/`iris`. Pair technical questions with substantive ones.
- "Permission to fumble" tone is deliberate — don't suggest tightening it out.
- Every visible code chunk uses `{webr}`, not `{r}`. No pre-rendered output pasted into prose.

## Project layout

- `chapters/NN-name.qmd` — chapter prose and visible code
- `chapters/exercises/_chNN_ex_name.qmd` — exercises (hint, solution, checker), included into chapters via `{{< include >}}`. Underscore prefix prevents Quarto from rendering them standalone.
- `chapters/exercises/_check.qmd` — shared grading snippet; see CONTRIBUTING §3 for the canonical exercise-grading pattern.
- `data/` — datasets, also listed under `webr.resources` in chapter YAML frontmatter.

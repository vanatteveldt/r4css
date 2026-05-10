# Contributing

This document covers the **didactic principles** of the book — the choices behind how chapters are structured, how code is presented, and how data is loaded. The goal is a shared frame of reference so that chapters written by different contributors feel like the same book to a student.

For the technical side of contributing (branches, `renv`, package management, PR workflow), see the [Contributing section of the README](README.md#contributing).

This is a living document. Several points below are flagged as **open questions** — please raise them in a PR or issue rather than silently diverging.

## Audience

We assume a reader who is:

- a beginner-to-intermediate R user, often with a social-science background rather than a computer-science one;
- working through the book linearly, in the browser, without installing anything locally;
- more interested in *what the code lets them learn about the world* than in the code as such.

The book can be used as a standalone resource, but in general we would expect it to be accompanied by exercises where the students are asked to apply the learned skills to new data sets or questions.

## Didactic Principle

The main didactic principle of the book is to make students curious about something before explaining it to them. Thus, rather than starting with a technical explanation of e.g. tidverse and ggplot we start off with an example of what you can do with it. In many places we use a new construct (such as `|>`) first and only then explain it. We try to use interesting substantive social science questions to motivate the visualizations or analyses we do. **Where possible, create a question in the head of the reader before giving them an answer**

## Concrete Implementation

### 1. Every code example is interactive

All R code lives in `{webr}` chunks rendered by [quarto-live](https://r-wasm.github.io/quarto-live/). Nothing is pre-rendered: a student sees an empty output area until they click `► Run Code`.

**Why:** we want the code to feel *runnable* from the first chapter. A student who reads through pre-rendered output is reading prose; a student who has to click is — even minimally — interacting. The hope is that "click run" turns into "click run, then change something" without ever feeling like a step up.

**How to apply:**
- Use `{webr}` chunks, not `{r}` chunks, for everything a student should see.
- Don't paste expected output into the prose. If a result is worth discussing, discuss it *after* the chunk and trust the student to have run it.
- The one exception is hidden setup chunks (`#| include: false`, `#| setup: true`) that prepare data for an exercise — see principle 8.

### 2. Three kinds of code blocks: show-and-tell, exercise, challenge

We use three distinct framings, and the distinction matters:

| Kind | Marker | What it asks of the student | Has a checker? |
|---|---|---|---|
| **Show-and-tell** | plain `{webr}` chunk | "Run this. Look at the output." | No |
| **Exercise** (✏️) | `::: {.exercise}` block + `{webr}` with `#| exercise:` | "Modify the code to get a specific result." | Yes — see principle 3 |
| **Challenge** (🧩) | `::: {.challenge}` block | "Think about / play with the code. There's no single right answer." | No |

Concrete examples in chapter 2:
- Show-and-tell: the [`votes` data frame at line 42](chapters/02-funwithr.qmd#L42).
- Exercise: [`_ch02_ex_filter.qmd`](chapters/exercises/_ch02_ex_filter.qmd) — single accepted answer, with hint and solution.
- Challenge: ["Can you guess what the columns mean?"](chapters/02-funwithr.qmd#L58) — open-ended.

**Why three rather than two:** challenges and exercises both ask for engagement, but they pull in different directions. Exercises reward closing in on a known answer; challenges reward exploration even if the student never lands anywhere specific. Mixing them under one label loses the permission to wander that the challenge format gives.

**How to apply:**
- Reach for **show-and-tell** when introducing a new command or piece of data — the cognitive load of "what is this?" is already enough.
- Reach for an **exercise** when a single small modification cleanly tests whether the student understood the previous block. Keep the diff small (rename a column, change a filter value, swap an argument). Always include a hint and a solution.
- Reach for a **challenge** when the right response is *thinking* (interpreting a graph, predicting a result, picking your own variable to plot). Do not write a checker for it.
- The first time a chapter introduces each of the three, point at the format with a callout note (see [the info callout at line 91](chapters/02-funwithr.qmd#L91) for how chapter 2 explains the exercise format).

**Open question:** is "exercise vs. challenge" pulling its weight, or could we collapse to two categories? I think three is right but happy to be argued out of it.

### 3. Exercise grading is layered: custom checks → result equality → code-feedback fallback

Every exercise's `#| check: true` chunk follows the same shape: optional custom `fail_if()` checks for anticipated mistakes, then a shared `_check.qmd` snippet (via `{{< include >}}`) that handles result equality and code-level feedback. See [`_ch03_ex_select.qmd`](chapters/exercises/_ch03_ex_select.qmd) and the shared [`_check.qmd`](chapters/exercises/_check.qmd) for the canonical example

**Why:**  This can give custom feedback to students for anticipated mistakes,
but even without the custom feedback it is better than the default `grade_this_code()` because it also passes if the results are equal but the code is not (with a hint to compare to the "official" solution)

**How to apply:**
Follow this pattern for all exercise grading chunks:

```r
#| exercise: exercise_name
#| check: true

gradethis::grade_this({
  if (is.data.frame(.result)) {
    gradethis::fail_if(!"GDP" %in% names(.result), "Did you rename gdp to GDP?")
  }

  {{< include exercises/_check.qmd >}}
})
```

Note: Guard structural checks like the `"GDP" %in% names(.result)` with `if (is.data.frame(.result))` — when student code errors, .result is an error object, and unguarded checks fire misleading messages.

### 4. Permission to fumble

Throughout the book we explicitly tell students that mistakes are fine, the code can't break anything, they can start over, and even the autograder is sometimes wrong. This affective scaffolding is deliberate, not just friendly tone.

Concrete instances in chapter 2:
- ["Note that you cannot break anything in these example code boxes!" at line 63](chapters/02-funwithr.qmd#L63).
- ["Don't worry about making mistakes, you can try as often as you want" at line 91](chapters/02-funwithr.qmd#L91).
- Honesty about the grader: ["if you're sure you're getting the right results but R won't give you full grades for it, just congratulate yourself for being original!" at line 100](chapters/02-funwithr.qmd#L100).

**Why:** beginning R users (especially those who didn't come to coding by inclination) tend to read errors as personal failures and stop. Cheap, repeated reassurance lowers the cost of trying — which is the precondition for learning anything. Being honest about tool limitations (the autograder makes mistakes too) also models the right relationship to the tools.

**How to apply:**
- The first time a chapter introduces a new interactive mechanism (run code, exercise, autograder), include a callout that says mistakes are recoverable and how to recover from them.
- Don't oversell tool reliability. If a checker can be wrong, say so once, in plain language.
- Frame corrections as "try again" rather than "incorrect."

### 5. Examples use social-science data, and prompt about the substance

Data sets should be recognisable as something a social scientist would actually look at: voting results, demographics, (social) media content, survey responses. Do not use non-social toy data sets like `mtcars`/`iris`.

We also try to ask substantive questions alongside the technical ones, to reinforce the idea that data is linked to actual questions. See for instance the [scatter-plot challenge at line 258](chapters/02-funwithr.qmd#L258): "What does each dot represent? Is there a relation between population density and voting for the Farmer's party? Is it a linear relationship?" — the student practices reading a `ggplot` *and* reads a graph about Dutch politics.

**Why:** the book is meant to be read by people who picked up R because they want to answer a research question, not because they wanted to learn R. Examples that double as miniature substantive arguments respect that motivation. They also give the student a reason to keep tinkering after the technical exercise is done.

**How to apply:**
- Prefer one well-curated dataset that recurs across a chapter to a parade of new ones.
- When introducing a dataset, gloss the columns (see [the collapsible "Columns in the voting data" callout at line 71](chapters/02-funwithr.qmd#L71)) so the substantive meaning is at hand.
- In challenges, ask a substantive interpretation question alongside any technical one.

### 6. Code should be readable; comments explain *why*, not *what*

Make code as clear and readable as possible. Where possible, avoid difficult technical steps unless they are the focus of the example (e.g. by preprocessing the data before introducting it). Use comments only when the code itself can't carry the meaning -- the default is to let the code speak.

Compare the two annotated lines in chapter 2:
- [Line 153](chapters/02-funwithr.qmd#L153): `# Note: fct_reorder reorders the factor levels in party by ascending vote` — useful, because `fct_reorder` is unfamiliar and its effect on the plot isn't obvious.
- [Line 297](chapters/02-funwithr.qmd#L297): `# Use 100 - v43_nl so low values means fewer migrants` — useful, because it explains a non-obvious choice (*why* the subtraction) rather than restating the syntax.

A comment that says `# filter the votes data to Amsterdam` above `filter(municipality == "Amsterdam")` is the kind we don't want.

**Why:** the comments serve double duty as a model. We're trying to teach students to *read* code, and to write comments that survive refactors. Restating the syntax in English trains them to do the opposite of both.

**How to apply:**
- Keep code clear, readable, and focused.
- Default to no comment.
- Add a comment when the code involves a non-obvious choice, an unfamiliar function whose effect isn't visible from the name, or a workaround.
- Pick variable and column names that make the comment unnecessary where you can.

### 7. Concept callouts arrive just-in-time, in the prose

When a new R or tidyverse construct first carries weight in code, follow up with a small `.callout-note` that names and explains it — *not* before. The student should see the construct doing something useful first, then read the explanation, then encounter the construct again later as a familiar tool.

Concrete examples in chapter 2:
- [The pipe `|>` callout at line 127](chapters/02-funwithr.qmd#L127) appears immediately after the first pipeline that does interesting work.
- [The ggplot aesthetic-mapping callout at line 167](chapters/02-funwithr.qmd#L167) appears after the first `ggplot(...) + geom_col(...)`, not before.
- [The "joining on different columns" callout at line 243](chapters/02-funwithr.qmd#L243) appears after `inner_join()` has produced visible output.

**Why:** this is the in-prose implementation of the central didactic principle. A callout placed *before* the code is a definition the student has no reason to remember; the same callout placed *after* answers a question the student has just formed ("what's that arrow thing?", "what does `aes` mean?"). Placement is the difference between a glossary and an answer.

**How to apply:**
- Don't open a chapter or section with a vocabulary list. Introduce constructs by using them.
- When a new construct first appears, write the chunk so the construct is doing visible work, then add a `.callout-note` immediately after that names and explains it.
- It's often fine to *not* explain a construct on its first appearance if the student can pattern-match from context. Save the callout for the second or third appearance — the moment the student is most likely to be wondering.

### 8. Data loading: visible chunks are self-contained via `download.file()`

Every visible chunk that uses a dataset should bring its own data — so a student who copy-pastes the chunk into a local RStudio session can run it immediately, with no preceding "make sure you've downloaded X first" instruction.

In practice this means: in the *visible* chunk where a dataset is first introduced, we use `download.file()` to fetch the file from this repo's `data/` folder on GitHub into the working directory, and then `read_csv()` it from there. In the *hidden* setup chunks (`#| setup: true`) that prepare data for downstream exercises, we read directly from the local `data/` folder, which quarto-live exposes via the `webr.resources` frontmatter (see [the YAML header at line 3](chapters/02-funwithr.qmd#L3)).

Concrete examples:
- Foreground introduction: [lines 42–48](chapters/02-funwithr.qmd#L42-L48) — `download.file(...)` then `read_csv("dutch_elections_2023.csv")`.
- Hidden setup for an exercise: [lines 113–118](chapters/02-funwithr.qmd#L113-L118) — `read_csv("data/dutch_elections_2023.csv")`, no download.

**Why two patterns:**
- The visible chunk needs to run in **two contexts**: in the browser (where `read_csv("https://...")` would be the obvious one-liner, but quarto-live's WebAssembly runtime has no `libcurl` so it doesn't work) *and* in a copy-pasted local RStudio session (where the file isn't there yet). `download.file()` followed by `read_csv()` runs in both, and it's also genuine, portable R that the student can keep using long after this book.
- Hidden setup chunks only ever run in the browser, where the file is already bundled via `webr.resources`. Re-downloading on every `► Run Code` would add latency for no pedagogical gain, so we skip it.

**How to apply:**
- When a dataset is first shown to the student, introduce it with `download.file(URL, "filename.csv")` followed by `read_csv("filename.csv")`. The URL should point to the raw GitHub copy in this repo's `data/` folder.
- List that file under `webr.resources` in the chapter's YAML frontmatter so it's available in the browser sandbox.
- In `#| setup: true` chunks (hidden boilerplate that re-prepares state for a downstream exercise), skip the download and read directly from `data/filename.csv`.

**Open question:** should we add a callout, probably in chapter 2, that mentions `read_csv(url)` as the pattern students will encounter in the wild and recommends RStudio Projects for local work? `download.file()` is portable on its own, but `read_csv(url)` is more idiomatic outside the webR sandbox and worth flagging once.

## Style conventions

These are downstream of the principles above and should mostly be invisible:

- Use tidyverse pipelines (`|>`, base R pipe) over nested calls when there's more than one step.
- Use `#| warning: false` on chunks where startup messages would otherwise clutter the output (e.g. `library(sjPlot)`).
- Hide setup chunks with `#| setup: true` and the matching `#| exercise:` ID(s); never with `#| include: false` and a manual re-definition — the `setup` mechanism is what quarto-live re-runs on `↻ Start Over`.

## What goes where

- **Chapter prose and visible code** → `chapters/NN-name.qmd`.
- **Exercises with hint/solution/checker** → `chapters/exercises/_chNN_ex_name.qmd`, included from the chapter via `{{< include exercises/_chNN_ex_name.qmd >}}`. Filenames are prefixed with `_` so Quarto does not render them as standalone pages.
- **Datasets** → `data/`, referenced from the chapter's `webr.resources` frontmatter and from raw-GitHub URLs in `download.file()`.

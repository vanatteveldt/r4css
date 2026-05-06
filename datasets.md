# Gapminder

Availability: R package (dslabs::gapminder), CC0 or CC-BY

Pro: accessible, easy to understand, somewhat interesting, many possible questions
Con: perhaps overused?

Description: Health and income outcomes for 184 countries from 1960 to 2016.

Colnames:
```
[1] "country"          "year"             "infant_mortality" "life_expectancy"  "fertility"        "population"
[7] "gdp"              "continent"        "region"
```

Possible RQs:
- Fertility per country in EU (=filter + arrange)
- Relation between GDP per capita and fertility (=mutate, filter, cor.test)
- Average and deviation from average / z-score within a region or country (groupby+summarize/mutate)
- Change over time within a country or region (=pivot)

# Bechdel

Availability: R Package (fivethirtyeight::bechdel), CC-BY

Pro: accessible, 'woke', perhaps more interesting than statistics, can reproduce graphs from article
Con, perhaps fewer interesting tidyverse operations?

Description: do films pass the bechdel test? Data from article:
https://fivethirtyeight.com/features/the-dollar-and-cents-case-against-hollywoods-exclusion-of-women/


Possible RQs:
- What are the highest grossing films? That pass the test? (=filter, arrange)
- return on investment (mutate)
- Budget per test outcome,
- Distribution over time (group-by+summarize)
- If we redistribute with fewer columns: re-create 'clean' columns (mutate, str_remove, recode), decade 'code'

# General social survey sample (gss_cat, gss_sm, gss)

Availability: available via forcats (gss_cat), socvic (gss_sm), infer (gss)

Description: Different selections of data from the general social survey

Pro: Lots of interesting and relevant variabls
Con: US-centric, perhaps overused

Columns:
- gss_cat: (21483x9) mostly factors (income, party, religion), some numerical (age, tv_hours)
- gss_sm: (2867x32) mostly a supserset of gss_cat with age, children, siblings, voting (obama)
- gss: (500x11) seems a smallish subset of gss_cat

Possible RQs:
- Factor handling (mutate with recoding, grouping), e.g. recoding voting (lean democrat -> ?)
- Voting behaviour (recode vote, recode explainers, group_by+summarize),
  lots of variables for student-driven rqs (e.g. tvhours vs siblings/education/race)
- Interesting relations to plot (filter, perhaps summarize, ggplot), e.g.
  Relation between cohort/generation and other aspects;
  relation between hapiness and other factors, social/educational mobility

# Eurobarometer

Availability: Publicly accessible via GESIS, R package eurobarometer (not on CRAN), requires registration

Pro: Highly prestigious, essential EU topics (climate, democracy, trust), cross-national comparisons.
Con: Data cleaning nightmare: sav files with complex labeling, variables change over time. Probably needs extensive cleaning and redistribution by us -> nominally not allowed, but probably OK for a small sample

columns: many and variable, but has respondent demographics, trust, opinion on climate etc

Possible rqs:
- lesson on data cleaning (rename, filter, etc)
- opinions per country (filter/groupby/summarize)
- climate concern by generation (bin age into factor)
- longitudinal shifts (pivot)

# Our world in data

Availability: Free `.csv` download from site, license unclear

Description: Country-level data with various indicators on different pages, e.g. hapiness, GDP, etc.

Pro: clean panel data, country comparisons, many interesting indicators, can compare to online version of report, good opportunity for teaching 'join'
Con: each indicator is it's own file, unclear redistribution license

Columns: Country, year, substantive columns

Possible RQs:
- Show changes in single indicator/year (filter, arrange)
- Reshape so country or year is column (pivot)
- Combine two data sets, e.g. hapiness vs gdp (join)
- Interesting ggplot options (maps, over time graphs, scatter plots)

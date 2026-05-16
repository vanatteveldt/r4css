# Data for R4CSS

We ship a number of data files in cases where data was not avaiable in a standard R package, or for didactic reason we preferred a different version of the data. Below are short descriptions, attributions, and links to the original data sets. Where possible, the code to produce the shipped version in included as well.

## Bechdel test data

- **File**: [bechdel.csv](bechdel.csv)
- **Source**: [Fivethirtyeight](https://github.com/fivethirtyeight/data/tree/master/bechdel)
- **Description**: This folder contains data and code behind the story *The Dollar-And-Cents Case Against Hollywood’s Exclusion of Women* ([archive.ph](https://archive.ph/sqXLq))
- **License**: CC-BY

Code:
```{r}
bechdel <- as_tibble(fivethirtyeight::bechdel) |>
  dplyr::select(imdb, year, title, test, budget, domgross, intgross) |>
  readr::write_csv(here::here("data/bechdel.csv"))
```


## Dutch demographics

- **File**: [dutch_demographics.csv](dutch_demographics.csv)
- **Source**: [CBS](https://www.cbs.nl/) (collected via the [cbsodataR](https://github.com/edwindj/cbsodataR) API)
- **Description**: Demographic and socioeconomic indicators per Dutch municipality (population, density, share with Dutch nationality, disposable income, wealth, pensions, distances to hospitals and schools, restaurant density, and share aged 65+). Column names prefixed with `v` use CBS variable codes.
- **License**: CC-BY 4.0

## Dutch elections data

- **File**: [dutch_elections_2023.csv](dutch_elections_2023.csv)
- **Source**: [Kiesraad](https://www.verkiezingsuitslagen.nl/verkiezingen/detail/TK20231122) (results of the 2023 Tweede Kamer election; collected via scraping)
- **Description**: Per-municipality results of the 2023 Dutch parliamentary election, with both vote share (`votes`) and raw count (`count`) for each party.
- **License**: Public information (Kiesraad)


## Dutch municipality shapes

- **File**: [shapes_nl.rds](shapes_nl.rds)
- **Source**: [CBS](https://www.cbs.nl/) (gemeentegrenzen / WijkBuurtkaart)
- **Description**: Geographic boundaries of Dutch municipalities as an `sf` object, suitable for `geom_sf` maps. The file required preprocessing to reconcile the boundary set with the municipality codes used in the other files, since Dutch municipalities are merged and renumbered fairly often.
- **License**: CC-BY 4.0 (per CBS open data policy)

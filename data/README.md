# Data for R4CSS

We ship a number of data files in cases where data was not avaiable in a standard R package, or for didactic reason we preferred a different version of the data. Below are short descriptions, attributions, and links to the original data sets. Where possible, the code to produce the shipped version in included as well.

## Bechdel test data

- **File**: [bechdel.csv](bechdel.csv)
- **Source**: [Fivethirtyeight](https://github.com/fivethirtyeight/data/tree/master/bechdel)
- **Description**: This folder contains data and code behind the story *The Dollar-And-Cents Case Against Hollywood’s Exclusion of Women* ([archive.ph](https://archive.ph/sqXLq))
- **License**: CC-BY

Code:
```{r}
as_tibble(fivethirtyeight::bechdel) |>
  dplyr::mutate(foreign_gross=intgross_2013 - domgross_2013) |>
  dplyr::select(imdb, year, title, test, budget=budget_2013, domestic_gross=domgross_2013, foreign_gross) |>
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

## Global CO2 and greenhouse gas emissions

- **File**: [co2_emissions.csv](co2_emissions.csv)
- **Source**: [Our World in Data](https://github.com/owid/co2-data), based on the [Global Carbon Budget](https://globalcarbonbudgetdata.org/) (Global Carbon Project) and [National contributions to climate change](https://zenodo.org/records/7636699/latest) (Jones et al.)
- **Description**: Annual greenhouse gas emissions per country from 1850 onwards: CO2 (total, per capita, and cumulative since 1750), methane and nitrous oxide (both in CO2 equivalents), and total greenhouse gases. Global, regional and income-group aggregates were dropped, as were the energy columns from the original dataset.
- **License**: CC-BY 4.0

Code:
```{r}
readr::read_csv("https://owid-public.owid.io/data/co2/owid-co2-data.csv") |>
  dplyr::filter(!is.na(iso_code), year >= 1850) |>
  dplyr::select(country, year, population, co2, co2_per_capita, cumulative_co2,
                methane, nitrous_oxide, total_ghg) |>
  dplyr::mutate(population = round(population),
                dplyr::across(dplyr::where(is.numeric) & !c(year, population),
                              \(x) round(x, 2))) |>
  arrange(-year) |>
  readr::write_csv(here::here("data/co2_emissions.csv"))
```

## Global temperature anomaly

- **File**: [temperature_anomaly.csv](temperature_anomaly.csv)
- **Source**: [HadCRUT5](https://www.metoffice.gov.uk/hadobs/hadcrut5/) (Met Office Hadley Centre), via [Our World in Data](https://ourworldindata.org/grapher/temperature-anomaly)
- **Description**: Average land-sea surface temperature per year from 1850 to 2025, expressed as the difference in degrees Celsius from the 1861-1890 (pre-industrial) mean, with the bounds of the 95% confidence interval. Reported separately for the world as a whole and for the Northern and Southern Hemispheres. Note that Our World in Data re-based the series from HadCRUT's native 1961-1990 baseline to 1861-1890, so the values differ from the Met Office original.
- **License**: Open Government Licence v3. HadCRUT.5.1.0.0 data were obtained from http://www.metoffice.gov.uk/hadobs/hadcrut5 on 10 August 2026 and are © British Crown Copyright, Met Office 2020, provided under an Open Government License, http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/

Code:
```{r}
readr::read_csv("https://ourworldindata.org/grapher/temperature-anomaly.csv?csvType=full") |>
  dplyr::filter(Year <= 2025) |>
  dplyr::select(region = Entity, year = Year, temp_anomaly = Average,
                temp_lower = `Lower bound`, temp_upper = `Upper bound`) |>
  dplyr::arrange(year) |>
  readr::write_csv(here::here("data/temperature_anomaly.csv"))
```

## World Bank income groups

- **File**: [income_groups.csv](income_groups.csv)
- **Source**: [World Bank](https://datahelpdesk.worldbank.org/knowledgebase/articles/906519-world-bank-country-and-lending-groups) country and lending groups, via [Our World in Data](https://ourworldindata.org/grapher/world-bank-income-groups)
- **Description**: The World Bank's classification of each country as `Low-income`, `Lower-middle-income`, `Upper-middle-income`, or `High-income`, for every year from 1987 to 2025. The World Bank re-assesses the thresholds annually, and 144 of the 226 countries change group at some point, so joining on `country` alone gives a different answer than joining on `country` and `year`. Venezuela has no classification for 2020-2024. The suffix ` countries` was removed from the category labels, which are ordered and so need an explicit `factor()` before plotting.
- **License**: CC-BY 4.0

Code:
```{r}
readr::read_csv("https://ourworldindata.org/grapher/world-bank-income-groups.csv?csvType=full") |>
  dplyr::select(country = Entity, year = Year,
                income_group = `World Bank's income classification`) |>
  dplyr::mutate(income_group = stringr::str_remove(income_group, " countries$")) |>
  readr::write_csv(here::here("data/income_groups.csv"))
```


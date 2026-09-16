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

## US Presidential election results

- **File**: [us-president.csv](us-president.csv)
- **Source**: [MIT Election Lab](https://electionlab.mit.edu/data)
- **Description***: This data file contains constituency (state-level) returns for elections to the U.S. presidency from 1976 to 2024.
- ** License**: CC0 1.0 / Public Domain

Code:
```{r}
library(tidyverse)
# Download from https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/42MVDX
# For some reason they require a guestbook signing to download a CC-0 file... :( 
read_csv("~/Downloads/1976-2024-president.csv") |>
  select(year, state, state_po, candidate, party=party_simplified, votes=candidatevotes, totalvotes) |>
  replace_na(list(party="Other")) |>
  mutate(candidate=str_to_title(candidate), party=str_to_title(party), state=str_to_title(state),
         party=if_else(party=="Libertarian", "Other", party)) |>
  write_csv(here::here("data/us-president.csv))
```

## US county-level demographics

- **File**: [us-counties.csv](us-counties.csv)
- **Source**: US Census Bureau, American Community Survey (ACS) 2020-2024 5-year estimates, via the [Census Data API](https://www.census.gov/data/developers/data-sets/acs-5year.html) and the [tidycensus](https://walker-data.com/tidycensus/) package
- **Description**: County-level demographic and socioeconomic indicators for the US (population, non-white share, female share, age brackets under 30/65+, median household income, unemployment, and share with a bachelor's degree or higher), identified by 5-digit FIPS code (kept as a string, not an integer, to preserve leading zeros). Puerto Rico is excluded.
- **License**: Public Domain (US Government Work). This product uses the Census Bureau Data API but is not endorsed or certified by the Census Bureau.

Code:
```{r}
library(tidycensus)
library(tidyverse)

# Needs a free Census API key (https://api.census.gov/data/key_signup.html),
# stored as CENSUS_API_KEY in .Renviron
census_api_key(Sys.getenv("CENSUS_API_KEY"))

acs_year <- 2024  # = the 2020-2024 5-year file, released 2026-01-29

simple <- get_acs(
  geography = "county",
  variables = c(
    total_population = "B01003_001",  # total population
    median_hh_inc    = "B19013_001",  # median household income
    race_total       = "B03002_001",  # total, Hispanic-origin-by-race table
    nhwhite          = "B03002_003",  # not Hispanic/Latino, white alone
    female           = "B01001_026",  # total female
    clf              = "B23025_003",  # civilian labor force (16+)
    unemployed       = "B23025_005"   # civilian labor force, unemployed
  ),
  year = acs_year, survey = "acs5", output = "wide"
) |>
  select(GEOID, NAME, ends_with("E")) |>          # drop margins of error
  rename_with(\(x) str_remove(x, "E$"), .cols = -c(GEOID, NAME))

# Age groups: sum the relevant brackets of B01001 (sex by age)
# male   under 30 = _003 .. _011,  65+ = _020 .. _025
# female under 30 = _027 .. _035,  65+ = _044 .. _049
under30 <- sprintf("B01001_%03d", c(3:11, 27:35))
plus65  <- sprintf("B01001_%03d", c(20:25, 44:49))

age <- get_acs(geography = "county", table = "B01001",
               year = acs_year, survey = "acs5") |>
  filter(variable %in% c(under30, plus65)) |>
  mutate(group = if_else(variable %in% under30, "under30", "plus65")) |>
  summarise(n = sum(estimate), .by = c(GEOID, group)) |>
  pivot_wider(names_from = group, values_from = n)

# Education: B15003 is educational attainment for the population 25+
# _001 = total 25+;  _022 .. _025 = bachelor's, master's, professional, doctorate
edu <- get_acs(geography = "county", table = "B15003",
               year = acs_year, survey = "acs5") |>
  filter(variable %in% c("B15003_001", sprintf("B15003_%03d", 22:25))) |>
  mutate(group = if_else(variable == "B15003_001", "adults25", "bachelor_plus")) |>
  summarise(n = sum(estimate), .by = c(GEOID, group)) |>
  pivot_wider(names_from = group, values_from = n)

# Suffixes to strip so "Autauga County" becomes "Autauga".
# Longest first; note "Planning Region" only occurs in Connecticut.
county_suffix <- paste0(
  " (City and Borough|Census Area|Planning Region|Municipality|",
  "Municipio|County|Parish|Borough|city|City)$"
)

simple |>
  left_join(age, by = "GEOID") |>
  left_join(edu, by = "GEOID") |>
  separate_wider_delim(NAME, delim = ", ",
                       names = c("county", "state"), too_many = "merge") |>
  mutate(
    fips              = GEOID,
    county            = str_remove(county, county_suffix),
    nonwhite_pct      = 100 * (1 - nhwhite / race_total),
    female_pct        = 100 * female / total_population,
    age29andunder_pct = 100 * under30 / total_population,
    age65andolder_pct = 100 * plus65 / total_population,
    clf_unemploy_pct  = 100 * unemployed / clf,
    college_pct       = 100 * (bachelor_plus / adults25)
  ) |>
  filter(!str_starts(fips, "72")) |>   # drop Puerto Rico
  select(fips, state, county, total_population, nonwhite_pct, female_pct,
         age29andunder_pct, age65andolder_pct, median_hh_inc,
         clf_unemploy_pct, college_pct) |>
  arrange(fips) |>
  write_csv(here::here("data/us-counties.csv"))
```

## US State level metadata

- **File**: [us-president.csv](us-states.csv)
- **Source**: [MIT Election Lab](https://electionlab.mit.edu/data)
- **Description***: The data file election-context-2018.csv contains demographic and past election data at the county level that can easily be merged with 2018 election returns to analyze the 2018 election. Data for Alaska is not included.
- ** License**: MIT

Code:
```{r}
read_csv("https://raw.githubusercontent.com/MEDSL/2018-elections-unoffical/refs/heads/master/election-context-2018.csv") |>
  select(state, total_population, white_pct, age29andunder_pct, age65andolder_pct, lesscollege_pct, median_hh_inc) |>
  group_by(state) |>
  summarize(population=sum(total_population, na.rm=T), 
            across(white_pct:median_hh_inc, \(x) sum(x*total_population, na.rm=T)/population)) |>
  mutate(college_pct=1-lesscollege_pct) |>
  select(-lesscollege_pct) |>
  write_csv(here::here("data/us-states.csv"))
```

## Brazilian Bluesky posts

- **File**: [bluesky_brazil_elections_2024.csv](bluesky_brazil_elections_2024.csv)
- **Source**: Scraped directly from Bluesky
- **Description**: All 2024 bluesky posts in Portuguese mentioning the elections hashtag
- **License**: (c) individual authors; collected via public API for non-commercial educational use.
Code:
```{r}
atrrr::auth(user = Sys.getenv("BSKY_HANDLE"), password = Sys.getenv("BSKY_APP_PASSWORD"))
posts <- atrrr::search_post("eleições2024", lang="pt", since = "2024-01-01", until = "2024-12-31", limit = 10000)

posts |> 
  dplyr::select(uri, author_handle:text, created_at, indexed_at, reply_count:quotes) |> 
  readr::write_csv("data/bluesky_brazil_elections_2024.csv")
```
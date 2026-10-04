# Records real LLM answers into data/llm_recorded.csv, which the interactive book replays
# (see chapters/exercises/_llm_mock.qmd). Run locally, with real API keys in ~/.Renviron.
# Requests are sent one at a time, as parallel requests fail on some servers.
# Run from the project root (the working directory when you open the RStudio project).
library(tidyverse)
library(ellmer)

# overwrite = TRUE re-records these texts, e.g. after changing the model settings,
# which are not stored in the file
record_llm <- function(chat, prompt, texts, file = "data/llm_recorded.csv", overwrite = FALSE) {
  recorded <- if (file.exists(file)) read_csv(file, show_col_types = FALSE) else
    tibble(model = character(), prompt = character(), text = character(), answer = character())
  model <- chat$get_model()
  if (overwrite) {
    recorded <- filter(recorded, !(.data$model == .env$model & .data$prompt == .env$prompt & text %in% texts))
  }
  todo <- setdiff(unique(texts), recorded$text[recorded$model == model & recorded$prompt == prompt])
  message(model, ": ", length(todo), " new texts to record")
  answers <- map_chr(todo, \(text) {
    chat$clone()$set_turns(list())$set_system_prompt(prompt)$chat(text, echo = "none")
  }, .progress = TRUE)
  bind_rows(recorded, tibble(model = model, prompt = prompt, text = todo, answer = answers)) |>
    write_csv(file)
}

headlines <- read_csv("data/dutch_sentiment.csv", show_col_types = FALSE)

prompt <- str_c(
    "Does this economic news headline describe the economy as ",
    "doing well (positive), poorly (negative), or neither (neutral)? ",
    "Answer with only one word: positive, negative, or neutral.")

# Use exactly the settings shown in the book, as the mock does not check them
haiku <- chat_anthropic(model = "claude-haiku-4-5")
llama <- chat_ollama(model = "llama3.2:3b", params = params(temperature = 0))
gemma <- chat_ollama(model = "gemma4:e4b")

# One-off (2026-10-04): the first llama answers were recorded at the default temperature
# via a server; re-record them locally at temperature 0, as the book shows
# record_llm(llama, prompt, headlines$translation, overwrite = TRUE)
# record_llm(llama, prompt, headlines$headline, overwrite = TRUE)

# All headlines, English translation and Dutch original, for the validation section
# (also covers the first-10 examples in sections "LLMs in the social sciences" and "Using hosted LLMs")
for (chat in list(llama, haiku, gemma)) {
  record_llm(chat, prompt, headlines$translation)
  record_llm(chat, prompt, headlines$headline)
}

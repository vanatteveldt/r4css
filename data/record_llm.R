# Records real LLM answers into data/llm_recorded.csv, which the interactive book replays
# (see chapters/exercises/_llm_mock.qmd). Run locally, with real API keys in ~/.Renviron.
# Requests are sent one at a time, as parallel requests fail on some servers.
# Run from the project root (the working directory when you open the RStudio project).
library(tidyverse)
library(ellmer)

# Each row of the file is one model + system prompt + user message, with the model's answer.
# The book puts all instructions in the user message, so the system prompt is normally empty.
# overwrite = TRUE re-records these messages, e.g. after changing the model settings,
# which are not stored in the file
record_llm <- function(chat, messages, system_prompt = "", file = "data/llm_recorded.csv", overwrite = FALSE) {
  recorded <- if (file.exists(file)) read_csv(file, show_col_types = FALSE) else
    tibble(model = character(), prompt = character(), text = character(), answer = character())
  # An empty system prompt is stored as an empty field, which read_csv turns into NA
  recorded <- mutate(recorded, prompt = coalesce(prompt, ""))
  messages <- as.character(messages)
  model <- chat$get_model()
  if (overwrite) {
    recorded <- filter(recorded, !(.data$model == .env$model & .data$prompt == system_prompt & text %in% messages))
  }
  todo <- setdiff(unique(messages), recorded$text[recorded$model == model & recorded$prompt == system_prompt])
  message(model, ": ", length(todo), " new messages to record")
  answers <- map_chr(todo, \(message) {
    chat <- chat$clone()$set_turns(list())
    if (system_prompt != "") chat$set_system_prompt(system_prompt)
    chat$chat(message, echo = "none")
  }, .progress = TRUE)
  bind_rows(recorded, tibble(model = model, prompt = system_prompt, text = todo, answer = answers)) |>
    write_csv(file)
}

headlines <- read_csv("data/dutch_sentiment.csv", show_col_types = FALSE)

# Exactly as in the book: the instruction followed by the headline, in a single user message
instruction <- str_c(
  "Does this economic news headline describe the economy as ",
  "doing well (positive), poorly (negative), or neither (neutral)? ",
  "Answer with only one word: positive, negative, or neutral.")
template <- "{{instruction}}\n\nThe headline: {{headline}}"
english <- interpolate(template, instruction = instruction, headline = headlines$translation)
dutch <- interpolate(template, instruction = instruction, headline = headlines$headline)

# The improved prompt from the 'Writing a good prompt' section, based on the codebook for human coders
instruction_codebook <- str_c(
  "You are classifying newspaper headlines by their sentiment about the economy, ",
  "as in a content analysis of economic news. ",
  "Judge only the headline itself, not anything else you may know about the events it refers to. ",
  "Codebook: positive = the headline evaluates the economy or economic conditions as good or improving; ",
  "negative = as bad or worsening; ",
  "neutral = the headline gives no evaluation of economic conditions, or is ambiguous or mixed. ",
  "Answer with only one word, in lowercase: positive, negative, or neutral.")
english_codebook <- interpolate(template, instruction = instruction_codebook, headline = headlines$translation)
dutch_codebook <- interpolate(template, instruction = instruction_codebook, headline = headlines$headline)

# Use exactly the settings shown in the book, as the mock does not check them
haiku <- chat_anthropic(model = "claude-haiku-4-5")
llama <- chat_ollama(model = "llama3.2:3b")
gemma <- chat_ollama(model = "gemma4:e4b")
gpt <- chat_openai(model = "gpt-4.1-nano")

# All headlines, English translation and Dutch original, for the examples and the validation section
for (chat in list(llama, haiku, gemma, gpt)) {
  record_llm(chat, english)
  record_llm(chat, dutch)
  record_llm(chat, english_codebook)
  record_llm(chat, dutch_codebook)
}

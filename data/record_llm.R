# Records real LLM answers into data/llm_recorded.csv, which the interactive book replays
# (see chapters/exercises/_llm_mock.qmd). Run locally, with real API keys in ~/.Renviron.
# Requests are sent one at a time, as parallel requests fail on some servers.
# Run from the project root (the working directory when you open the RStudio project).
library(tidyverse)
library(ellmer)

# The JSON schema of the structured output in a request body, or "" for plain text.
# Must give the same result as request_schema() in chapters/exercises/_llm_mock.qmd
request_schema <- function(body) {
  schema <- body$output_config$format$schema
  if (is.null(schema)) schema <- body$text$format$schema
  if (is.null(schema)) {
    tool <- Filter(\(t) identical(t$name, "_structured_tool_call"), body$tools)
    if (length(tool) > 0) schema <- tool[[1]]$input_schema$properties$data
  }
  if (is.null(schema) && is.list(body$format)) schema <- body$format
  if (is.null(schema)) "" else as.character(jsonlite::toJSON(schema, auto_unbox = TRUE))
}

# The schema the mock will see when the book asks for this type. Uses ellmer internals to build
# the request without sending it, so this may need updating for future ellmer versions
type_schema <- function(chat, type) {
  if (is.null(type)) return("")
  provider <- chat$get_provider()
  type <- ellmer:::wrap_type_if_needed(type, ellmer:::type_needs_wrapper(type, provider))
  req <- ellmer:::chat_request(provider = provider, model = chat$get_model_object(),
    turns = list(ellmer:::user_turn("schema")), type = type, stream = FALSE)
  request_schema(req$body$data)
}

# All columns are text; read_csv would otherwise guess the mostly empty schema column as logical,
# silently turning all schemas into NA (and losing them when the file is written again)
read_recorded <- function(file) read_csv(file, col_types = cols(.default = "c"))

# Each row of the file is one model + system prompt + user message + schema, with the model's answer.
# The book puts all instructions in the user message, so the system prompt is normally empty.
# overwrite = TRUE re-records these messages, e.g. after changing the model settings,
# which are not stored in the file.
# With a type, the answers are recorded with chat_structured and stored as the JSON text the API returns,
# which the mock replays as is. The type's schema is stored as well, as it is part of what the model sees;
# for plain text answers the schema is empty.
record_llm <- function(chat, messages, system_prompt = "", type = NULL, file = "data/llm_recorded.csv", overwrite = FALSE) {
  recorded <- if (file.exists(file)) read_recorded(file) else
    tibble(model = character(), prompt = character(), text = character(), answer = character(), schema = character())
  # An empty system prompt or schema is stored as an empty field, which read_csv turns into NA
  recorded <- mutate(recorded, prompt = coalesce(prompt, ""), schema = coalesce(schema, ""))
  messages <- as.character(messages)
  model <- chat$get_model()
  schema <- type_schema(chat, type)
  same_setup <- recorded$model == model & recorded$prompt == system_prompt & recorded$schema == schema
  if (overwrite) {
    recorded <- recorded[!(same_setup & recorded$text %in% messages), ]
    same_setup <- recorded$model == model & recorded$prompt == system_prompt & recorded$schema == schema
  }
  todo <- setdiff(unique(messages), recorded$text[same_setup])
  message(model, ": ", length(todo), " new messages to record")
  answers <- map_chr(todo, \(message) {
    chat <- chat$clone()$set_turns(list())
    if (system_prompt != "") chat$set_system_prompt(system_prompt)
    if (is.null(type)) return(chat$chat(message, echo = "none"))
    chat$chat_structured(message, type = type)
    json <- Filter(\(content) inherits(content, "ellmer::ContentJson"), chat$last_turn()@contents)
    json[[1]]@string
  }, .progress = TRUE)
  bind_rows(recorded, tibble(model = model, prompt = system_prompt, text = todo, answer = answers, schema = schema)) |>
    write_csv(file)
}

# Records a conversation: the messages are sent one after another in the same chat, so later messages
# are answered in the context of the earlier ones. The mock only looks at the last message,
# so a follow-up message like "Are you sure?" must not also be used elsewhere in the book
record_conversation <- function(chat, messages, file = "data/llm_recorded.csv") {
  recorded <- read_recorded(file) |>
    mutate(prompt = coalesce(prompt, ""), schema = coalesce(schema, ""))
  model <- chat$get_model()
  plain <- recorded$model == model & recorded$prompt == "" & recorded$schema == ""
  if (all(messages %in% recorded$text[plain])) {
    message(model, ": conversation already recorded")
    return(invisible())
  }
  message(model, ": recording a conversation of ", length(messages), " messages")
  chat <- chat$clone()$set_turns(list())
  answers <- map_chr(messages, \(message) chat$chat(message, echo = "none"))
  recorded[!(plain & recorded$text %in% messages), ] |>
    bind_rows(tibble(model = model, prompt = "", text = messages, answer = answers, schema = "")) |>
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
codes <- c(
  positive = "the headline evaluates the economy or economic conditions as good or improving",
  negative = "the headline evaluates the economy or economic conditions as bad or worsening",
  neutral = "the headline gives no evaluation of economic conditions, or is ambiguous or mixed")
codebook <- str_glue("- {names(codes)} = {codes}") |> str_c(collapse="\n")
task <- "You are classifying newspaper headlines by their sentiment about the economy, as in a content analysis of economic news."
context <- "Judge only the headline itself, not anything else you may know about the events it refers to."
answer <- "Answer with only one word, in lowercase: positive, negative, or neutral."
instruction_codebook <- str_glue("{task} {context}\n\nCodebook:\n{codebook}\n\n{answer}")
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

# The 'Structured output' section: a reason and a value per headline, using the codebook instruction
# without the answer format. The type must be exactly as in the book, as its schema is part of what the mock checks
type_reasoned <- type_object(
  reason = type_string(description="Your interpretation of the headline and reason for coding it"),
  value = type_enum(values=names(codes), description="The sentiment of the headline")
)
instruction_noanswer <- str_glue("{task} {context}\n\nCodebook:\n{codebook}")
example_structured <- interpolate("{{instruction_noanswer}}\n\nThe headline: They have won a great election victory")
english_structured <- interpolate(template, instruction = instruction_noanswer, headline = headlines$translation)
dutch_structured <- interpolate(template, instruction = instruction_noanswer, headline = headlines$headline)
record_llm(haiku, c(example_structured, english_structured, dutch_structured), type = type_reasoned)

# The type_array example: economic indicators per headline. Prompt and type must stay identical to the book.
# All headlines are recorded, so the book can show any subset of them
economic_indicator <- type_object(
  indicator = type_string(str_c(
    "An economic variable or policy measure that can increase or decrease, ",
    "such as unemployment, prices, interest rates, profits, taxes, budget cuts or restrictions. ",
    "Also include variables whose change is only implied, e.g. layoffs mean jobs go down. ",
    "Name the variable itself, not the event. Never use 'none' or an empty string.")),
  direction = type_enum("The factual change in this variable, regardless of whether that is good or bad",
                        values=c("up", "down", "stable", "unclear")),
  evaluation = type_enum("Whether the headline presents this change as good or bad for the economy",
                        values=c("good", "bad", "neutral"))
)
type_indicator_list <- type_array(
  "All economic variables mentioned in the headline. Return an empty list if there are none.",
  items = economic_indicator)
indicators <- interpolate("List the economic variables and policy measures mentioned in this headline.\n\nThe headline: {{translation}}",
  translation = headlines$translation)
record_llm(haiku, indicators, type = type_indicator_list)

# The first example in the chapter: a short conversation, showing that the chat remembers its history
record_conversation(gemma, c(
  "Is this headline positive or negative? Headline: 'The economy just crashed'",
  "Are you sure?"))

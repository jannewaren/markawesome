# frozen_string_literal: true

module Markawesome
  # Whitespace tokenization that keeps `key:"…"` / `key:'…'` (spaces included)
  # together as one token, plus the matching unquote. Shared by the `[[[ … ]]]`
  # transformers (date, counter, number ticker).
  module QuotedTokens
    TOKEN_REGEX = /[a-z-]+:"[^"]*"|[a-z-]+:'[^']*'|\S+/
    QUOTED_REGEX = /\A"([^"]*)"\z|\A'([^']*)'\z/

    module_function

    def split(string)
      string.to_s.scan(TOKEN_REGEX)
    end

    # Strip one pair of matching surrounding quotes ("…" or '…'), if present.
    def unquote(value)
      match = QUOTED_REGEX.match(value)
      match ? (match[1] || match[2]) : value
    end
  end
end

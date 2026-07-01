require "html"

module Marten
  module SEO
    # HTML and JSON escaping for safe template rendering using only stdlib.
    # Implements Ruby's ERB::Util.json_escape escaping semantics.
    module Escaping
      extend self

      # Characters safe in JSON but unsafe in an HTML <script> context: prevents
      # </script> breakout, <!-- injection, and mXSS via U+2028/U+2029.
      # Replacements are \uXXXX sequences, which are valid JSON string escapes.
      HTML_UNSAFE_IN_SCRIPT = {
        '<'      => "\\u003c",
        '>'      => "\\u003e",
        '&'      => "\\u0026",
        ' ' => "\\u2028",
        ' ' => "\\u2029",
      }

      # Escapes a JSON string for safe embedding inside a <script> element.
      # Replaces the five chars that can break out of or corrupt the script context.
      def escape_json(json : String) : String
        json.gsub(HTML_UNSAFE_IN_SCRIPT)
      end

      # Escapes a plain-text string for safe embedding in HTML attribute values
      # and text content. Crystal stdlib equivalent of Ruby's CGI.escapeHTML.
      def escape_html(text : String) : String
        HTML.escape(text)
      end
    end
  end
end

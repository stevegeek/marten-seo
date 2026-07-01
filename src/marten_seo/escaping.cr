require "web_escape"

module Marten
  module SEO
    # HTML and JSON escaping for safe template rendering. Delegates to the shared
    # `web-escape` shard (WebEscape), which provides byte-identical semantics to
    # the original inline implementation (matching ERB::Util.json_escape semantics).
    module Escaping
      extend self

      # Escapes a JSON string for safe embedding inside a <script> element.
      # Replaces the five chars that can break out of or corrupt the script context.
      # Delegates to `WebEscape.escape_json`.
      def escape_json(json : String) : String
        WebEscape.escape_json(json)
      end

      # Escapes a plain-text string for safe embedding in HTML attribute values
      # and text content. Crystal stdlib equivalent of Ruby's CGI.escapeHTML.
      # Delegates to `WebEscape.escape_html`.
      def escape_html(text : String) : String
        WebEscape.escape_html(text)
      end
    end
  end
end

module Marten
  module SEO
    module Spec
      # Minimal stand-in used by the localized "home"/"about" routes so that
      # reverse-routing and alternate_urls have real named routes to resolve.
      class PlainHandler < Marten::Handler
        def get
          respond("ok", content_type: "text/plain")
        end
      end
    end
  end
end

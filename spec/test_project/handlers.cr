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

      # Exercises the Page concern: sets `seo` in `get`, renders a template that
      # relies on the concern's before_render injection.
      class SeoPageHandler < Marten::Handler
        include Marten::SEO::Page

        def get
          seo.title = "Concern Title"
          seo.description = "Injected by the concern"
          render("seo_page.html")
        end
      end
    end
  end
end

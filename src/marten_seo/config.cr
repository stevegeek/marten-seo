require "marten"

module Marten
  module SEO
    # Process-wide SEO defaults, configured once at boot via `Marten::SEO.configure`.
    # Per-page values set on a `PageMeta` in handlers override these.
    class Config
      property site_name : String = ""
      property default_og_image : String? = nil
      property default_robots : String = "index,follow"
      property robots_user_agent : String = "*"
      property robots_allow : Array(String) = ["/"]
      property robots_disallow : Array(String) = [] of String

      # Absolute origin (scheme + host, no trailing slash) used to build sitemap
      # and hreflang URLs. When empty, handlers fall back to the request origin.
      getter base_url : String = ""

      def base_url=(value : String) : String
        @base_url = value.rstrip("/")
      end
    end

    @@config = Config.new

    def self.config : Config
      @@config
    end

    def self.configure(&) : Nil
      yield @@config
    end
  end
end

require "marten"

module Marten
  module SEO
    # One indexable URL for the sitemap. `params` are passed to `reverse` to build
    # the path per locale; `lastmod` is an optional W3C date string.
    struct SitemapEntry
      getter route_name : String
      getter params : Hash(String, String)
      getter changefreq : String
      getter priority : Float64
      getter lastmod : String?

      def initialize(
        @route_name : String,
        @params : Hash(String, String) = {} of String => String,
        @changefreq : String = "weekly",
        @priority : Float64 = 0.5,
        @lastmod : String? = nil,
      )
      end
    end

    # Registry of indexable routes that drive the sitemap. Supports static entries
    # (`register`) and dynamic enumerators (`register_dynamic`) for DB/catalog
    # content. Process-global; call `clear` between specs.
    module PageRegistry
      extend self

      @@static = [] of SitemapEntry
      @@dynamic = [] of Proc(Array(SitemapEntry))

      def register(
        route_name : String,
        priority : Float64 = 0.5,
        changefreq : String = "weekly",
        lastmod : String? = nil,
        params : Hash(String, String) = {} of String => String,
      ) : Nil
        @@static << SitemapEntry.new(route_name, params, changefreq, priority, lastmod)
      end

      def register_dynamic(&block : -> Array(SitemapEntry)) : Nil
        @@dynamic << block
      end

      # Static entries first, then each dynamic enumerator evaluated fresh.
      def entries : Array(SitemapEntry)
        result = @@static.dup
        @@dynamic.each { |producer| result.concat(producer.call) }
        result
      end

      def clear : Nil
        @@static.clear
        @@dynamic.clear
      end
    end
  end
end

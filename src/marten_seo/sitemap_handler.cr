require "marten"
require "./page_registry"
require "./alternates"
require "./escaping"

module Marten
  module SEO
    # Emits sitemap.xml. Iterates the PageRegistry, emitting one <url> per locale
    # for each entry, each carrying the full set of xhtml:link hreflang alternates
    # plus an x-default pointing at the default-locale URL.
    # Entries whose route cannot be reversed in any locale are silently skipped.
    class SitemapHandler < Marten::Handler
      def get
        respond(build_xml(sitemap_base), "application/xml")
      end

      private def sitemap_base : String
        configured = Marten::SEO.config.base_url
        configured.empty? ? "#{request.scheme}://#{request.host}" : configured
      end

      private def build_xml(base : String) : String
        String.build do |io|
          io << %(<?xml version="1.0" encoding="UTF-8"?>\n)
          io << %(<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" )
          io << %(xmlns:xhtml="http://www.w3.org/1999/xhtml">\n)

          Marten::SEO::PageRegistry.entries.each do |entry|
            begin
              urls = Marten::SEO.alternate_urls(entry.route_name, entry.params, base)
              if entry_locales = entry.locales
                urls = urls.select { |locale, _| entry_locales.includes?(locale) }
              end
              next if urls.empty?
              emit_url_set(io, urls, entry.changefreq, entry.priority, entry.lastmod)
            rescue Marten::Routing::Errors::NoReverseMatch
              next
            end
          end

          io << "</urlset>\n"
        end
      end

      # One <url> per locale, each carrying every locale's alternate plus x-default.
      private def emit_url_set(
        io : IO,
        urls : Hash(String, String),
        changefreq : String,
        priority : Float64,
        lastmod : String?,
      ) : Nil
        default_locale = Marten.settings.i18n.default_locale
        urls.each do |_loc, loc_url|
          io << "  <url>\n"
          io << "    <loc>" << Escaping.escape_html(loc_url) << "</loc>\n"
          urls.each do |alt_loc, alt_url|
            io << %(    <xhtml:link rel="alternate" hreflang=")
            io << Escaping.escape_html(alt_loc)
            io << %(" href=")
            io << Escaping.escape_html(alt_url)
            io << %("/>\n)
          end
          if default_url = urls[default_locale]?
            io << %(    <xhtml:link rel="alternate" hreflang="x-default" href=")
            io << Escaping.escape_html(default_url)
            io << %("/>\n)
          end
          io << "    <lastmod>" << Escaping.escape_html(lastmod) << "</lastmod>\n" if lastmod
          io << "    <changefreq>" << Escaping.escape_html(changefreq) << "</changefreq>\n"
          io << "    <priority>" << Escaping.escape_html(priority.to_s) << "</priority>\n"
          io << "  </url>\n"
        end
      end
    end
  end
end

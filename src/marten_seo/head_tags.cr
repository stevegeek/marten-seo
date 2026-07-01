require "marten"
require "json"
require "./escaping"

module Marten
  module SEO
    # Renders a PageMeta into a `<head>` HTML fragment. Framework-agnostic: returns
    # a plain String so it can be embedded by an ECR template (via {% seo_tags %}),
    # a Blueprint component (`raw safe(...)`), or written directly to a response.
    class HeadTags
      def initialize(@meta : PageMeta, @config : Config = Marten::SEO.config)
      end

      def render_to_s : String
        String.build { |io| render_to(io) }
      end

      def render_to(io : IO) : Nil
        if title = @meta.title
          io << "<title>" << Escaping.escape_html(title) << "</title>\n"
        end
        meta_tag(io, "description", @meta.description)

        robots = @meta.robots || @config.default_robots
        meta_tag(io, "robots", robots) unless robots.empty?

        if canonical = @meta.canonical
          io << %(<link rel="canonical" href=") << Escaping.escape_html(canonical) << %("/>\n)
        end

        render_open_graph(io)
        render_twitter(io)
        render_json_ld(io)
      end

      private def render_open_graph(io : IO) : Nil
        og = @meta.og
        property_tag(io, "og:title", og.title || @meta.title)
        property_tag(io, "og:description", og.description || @meta.description)
        property_tag(io, "og:type", og.type)
        property_tag(io, "og:url", og.url || @meta.canonical)
        property_tag(io, "og:image", og.image || @config.default_og_image)
        property_tag(io, "og:site_name", @config.site_name.empty? ? nil : @config.site_name)
      end

      private def render_twitter(io : IO) : Nil
        tw = @meta.twitter
        meta_tag(io, "twitter:card", tw.card)
        meta_tag(io, "twitter:title", tw.title || @meta.title)
        meta_tag(io, "twitter:description", tw.description || @meta.description)
        meta_tag(io, "twitter:image", tw.image || @meta.og.image || @config.default_og_image)
      end

      private def render_json_ld(io : IO) : Nil
        @meta.json_ld.each do |node|
          json = node.is_a?(String) ? node : node.to_json
          io << %(<script type="application/ld+json">)
          # Escape chars that could break out of the <script> context.
          io << Escaping.escape_json(json)
          io << "</script>\n"
        end
      end

      private def meta_tag(io : IO, name : String, content : String?) : Nil
        return if content.nil?
        io << %(<meta name=") << name << %(" content=") << Escaping.escape_html(content) << %("/>\n)
      end

      private def property_tag(io : IO, property : String, content : String?) : Nil
        return if content.nil?
        io << %(<meta property=") << property << %(" content=") << Escaping.escape_html(content) << %("/>\n)
      end
    end
  end
end

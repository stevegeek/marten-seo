require "marten"
require "./head_tags"

module Marten
  module SEO
    # `{% seo_tags %}` renders the request's PageMeta (the `seo` context variable
    # by default) into head tags. `{% seo_tags my_meta %}` reads a different var.
    # A thin adapter over `HeadTags`; emits nothing if the value isn't a PageMeta.
    class SeoTagsTag < Marten::Template::Tag::Base
      include Marten::Template::Tag::CanSplitSmartly

      def initialize(parser : Marten::Template::Parser, source : String)
        parts = split_smartly(source)
        var = parts.size > 1 ? parts[1] : "seo"
        @meta_expression = Marten::Template::FilterExpression.new(var)
      end

      def render(context : Marten::Template::Context) : String
        meta = @meta_expression.resolve(context).raw
        return "" unless meta.is_a?(Marten::SEO::PageMeta)
        Marten::SEO::HeadTags.new(meta).render_to_s
      end
    end
  end
end

Marten::Template::Tag.register("seo_tags", Marten::SEO::SeoTagsTag)

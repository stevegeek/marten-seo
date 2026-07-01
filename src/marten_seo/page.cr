require "marten"
require "./page_meta"

module Marten
  module SEO
    # Handler concern. Include it to get a per-request `seo` PageMeta that is
    # injected into the template context (as `seo`) just before rendering.
    #
    # The `before_render` callback is registered from `macro included`; this works
    # for handlers because `Marten::Handler` sets up its per-class `CALLBACKS`
    # constant (via its own `inherited` hook) before the `include` is processed.
    # If a future Marten change makes the callback no-op, declare
    # `before_render :_inject_seo_into_context` directly in the host handler.
    module Page
      macro included
        before_render :_inject_seo_into_context
      end

      # The mutable SEO metadata for the current request. Lazily created.
      def seo : Marten::SEO::PageMeta
        @_seo ||= Marten::SEO::PageMeta.new
      end

      private def _inject_seo_into_context : Nil
        context[:seo] = seo
      end
    end
  end
end

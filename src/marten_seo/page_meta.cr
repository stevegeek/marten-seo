require "marten"
require "json"

module Marten
  module SEO
    # OpenGraph metadata. Nil fields fall back to the parent PageMeta's
    # title/description/canonical at render time.
    class OpenGraph
      include Marten::Template::Object

      property title : String?
      property description : String?
      property image : String?
      property type : String = "website"
      property url : String?

      template_attributes :title, :description, :image, :type, :url
    end

    # Twitter Card metadata. Nil fields fall back at render time.
    class TwitterCard
      include Marten::Template::Object

      property card : String = "summary_large_image"
      property title : String?
      property description : String?
      property image : String?

      template_attributes :card, :title, :description, :image
    end

    # A JSON-LD node is either a pre-serialized JSON string or a Hash that the
    # renderer serializes with `#to_json`.
    alias JsonLdNode = String | Hash(String, JSON::Any)

    # Mutable per-request SEO metadata holder. One instance lives on each handler
    # that includes `Marten::SEO::Page`; `HeadTags` turns it into head tags.
    class PageMeta
      include Marten::Template::Object

      property title : String?
      property description : String?
      property canonical : String?
      property robots : String?
      getter og : OpenGraph
      getter twitter : TwitterCard
      property json_ld : Array(JsonLdNode)

      template_attributes :title, :description, :canonical, :robots, :og, :twitter

      def initialize
        @og = OpenGraph.new
        @twitter = TwitterCard.new
        @json_ld = [] of JsonLdNode
      end
    end
  end
end

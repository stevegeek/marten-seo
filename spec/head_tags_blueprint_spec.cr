require "./spec_helper"
require "blueprint"
require "blueprint/html"

private class SeoHeadComponent
  include Blueprint::HTML

  def initialize(@meta : Marten::SEO::PageMeta)
  end

  private def blueprint
    head do
      raw safe(Marten::SEO::HeadTags.new(@meta).render_to_s)
    end
  end
end

describe "HeadTags Blueprint interop" do
  it "embeds head tags inside a Blueprint component without re-escaping" do
    meta = Marten::SEO::PageMeta.new
    meta.title = "Hi"
    html = SeoHeadComponent.new(meta).to_s
    html.should contain("<head><title>Hi</title>")
  end
end

require "./spec_helper"

describe Marten::SEO::Page do
  it "exposes a per-handler seo PageMeta" do
    handler = Marten::SEO::Spec::SeoPageHandler.new(
      Marten::HTTP::Request.new(
        ::HTTP::Request.new("GET", "/seo-page")
      )
    )
    handler.seo.should be_a(Marten::SEO::PageMeta)
    handler.seo.should be(handler.seo) # same instance across calls
  end

  it "injects seo into the rendered template context" do
    response = Marten::Spec.client.get("/seo-page")
    response.status.should eq(200)
    response.content.should contain("<title>Concern Title</title>")
    response.content.should contain(%(<meta name="description" content="Injected by the concern"/>))
  end
end

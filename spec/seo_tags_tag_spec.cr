require "./spec_helper"

describe "{% seo_tags %} template tag" do
  it "renders head tags from the default `seo` context variable" do
    meta = Marten::SEO::PageMeta.new
    meta.title = "Tagged"
    template = Marten::Template::Template.new("<head>{% seo_tags %}</head>")
    output = template.render({"seo" => meta})
    output.should contain("<head><title>Tagged</title>")
  end

  it "renders from an explicitly named variable" do
    meta = Marten::SEO::PageMeta.new
    meta.title = "Named"
    template = Marten::Template::Template.new("{% seo_tags page_meta %}")
    output = template.render({"page_meta" => meta})
    output.should contain("<title>Named</title>")
  end

  it "renders nothing when the variable is not a PageMeta" do
    template = Marten::Template::Template.new("[{% seo_tags %}]")
    output = template.render({"seo" => "not-a-page-meta"})
    output.should eq("[]")
  end
end
